# 2. Verilog básico

[← Metodología](01_Metodologia.md) · [Fundamentos](README.md) · [Siguiente: Lógica secuencial →](03_Logica_secuencial.md)

Verilog es un **lenguaje de descripción de hardware** (HDL). No es un lenguaje de programación como C o Python: un programa se ejecuta línea por línea, mientras que un código Verilog describe un circuito en el que **todas las partes funcionan al mismo tiempo**. Cada línea que escriben se convierte en compuertas, cables y flip-flops dentro de la FPGA.

---

## Contenido

1. [El módulo: una caja con pines](#1-el-módulo-una-caja-con-pines)
2. [Comentarios](#2-comentarios)
3. [Números](#3-números)
4. [Cables y variables: `wire` y `reg`](#4-cables-y-variables-wire-y-reg)
5. [Buses: varios bits juntos](#5-buses-varios-bits-juntos)
6. [`assign`: conexiones combinacionales](#6-assign-conexiones-combinacionales)
7. [`always`: qué significa y sus dos formas](#7-always-qué-significa-y-sus-dos-formas)
8. [`=` y `<=`: las dos asignaciones](#8--y--las-dos-asignaciones)
9. [Decisiones: `if`, `case` y `? :`](#9-decisiones-if-case-y--)
10. [Operadores](#10-operadores)
11. [Parámetros: `parameter` y `localparam`](#11-parámetros-parameter-y-localparam)
12. [Usar un módulo dentro de otro (instanciación)](#12-usar-un-módulo-dentro-de-otro-instanciación)
13. [Lo que solo existe en simulación](#13-lo-que-solo-existe-en-simulación)
14. [Errores frecuentes](#14-errores-frecuentes)

---

## 1. El módulo: una caja con pines

Todo diseño en Verilog se organiza en **módulos**. Un módulo es como un circuito integrado: tiene un nombre, unos pines de entrada y salida (los **puertos**) y un contenido interno.

```verilog
module led_con_boton (          // nombre del módulo
    input  wire boton,          // puerto de entrada de 1 bit
    output wire led             // puerto de salida de 1 bit
);

    assign led = boton;         // contenido: el LED copia al botón

endmodule                       // fin del módulo
```

- `input`: el módulo recibe esa señal desde afuera.
- `output`: el módulo entrega esa señal hacia afuera.
- El módulo superior de un diseño (el que se conecta a los pines de la FPGA) se llama **módulo top**.

## 2. Comentarios

Los comentarios no generan hardware; sirven para explicar el código a quien lo lee (incluidos ustedes mismos dentro de un mes).

```verilog
// Comentario de una línea: todo lo que sigue a // se ignora

/* Comentario de varias líneas:
   útil para explicar un bloque completo */
```

Comenten **por qué** se hace algo, no solo qué hace. `cnt <= 0; // pone cnt en cero` no aporta; `cnt <= 0; // terminó el periodo de 20 ms` sí.

## 3. Números

Un número en Verilog puede indicar su **ancho en bits** y su **base**:

| Escritura | Significado | Valor decimal |
|---|---|---|
| `4'b1010` | 4 bits, binario | 10 |
| `8'd25` | 8 bits, decimal | 25 |
| `16'hFF` | 16 bits, hexadecimal | 255 |
| `1'b0`, `1'b1` | 1 bit, 0 o 1 | 0, 1 |
| `25_000_000` | sin ancho: entero de 32 bits | 25 000 000 |

El guion bajo `_` solo separa dígitos para leerlos mejor: `25_000_000` es lo mismo que `25000000`.

## 4. Cables y variables: `wire` y `reg`

| Tipo | Qué representa | Quién le da valor |
|---|---|---|
| `wire` | Un **cable**: no guarda nada, solo conecta | Un `assign` o la salida de otro módulo |
| `reg` | Una **variable** a la que se le asigna valor dentro de un `always` | Un bloque `always` |

**Cuidado con el nombre:** `reg` **no** significa necesariamente "registro" ni "flip-flop". Un `reg` asignado en `always @(posedge clk)` se convierte en flip-flops; un `reg` asignado en `always @(*)` se convierte en lógica combinacional, sin memoria. Lo que decide es el tipo de `always`, no la palabra `reg`.

```verilog
wire       a;         // cable de 1 bit
reg  [3:0] cuenta;    // variable de 4 bits (se asigna en un always)
```

## 5. Buses: varios bits juntos

Un **bus** agrupa varios bits bajo un nombre. `[3:0]` significa "4 bits, numerados del 3 (el más significativo) al 0 (el menos significativo)".

```verilog
wire [3:0] btn;       // 4 bits: btn[3], btn[2], btn[1], btn[0]

btn[0]                // un solo bit
btn[3:2]              // los dos bits más significativos
```

## 6. `assign`: conexiones combinacionales

`assign` describe una conexión permanente: la salida se recalcula **inmediatamente** cada vez que cambia algo a la derecha del `=`. Es lógica combinacional.

```verilog
assign y       = a & b;          // y es la AND de a y b, siempre
assign btn     = ~btn_n;         // btn es la negación de btn_n, siempre
assign en_alto = (cnt < t_on);   // en_alto vale 1 mientras cnt sea menor que t_on
```

Un `assign` solo puede dar valor a un `wire` (o a una salida declarada `output wire`).

## 7. `always`: qué significa y sus dos formas

`always` significa **"cada vez que ocurra el evento indicado, ejecute este bloque"**. El símbolo `@( ... )` indica **cuál es ese evento**: se lee "en el momento de...".

En este laboratorio solo se usan dos formas:

| Forma | Se lee | Qué hardware produce | Asignación |
|---|---|---|---|
| `always @(posedge clk)` | "en cada flanco de subida del reloj" | **Flip-flops**: lógica secuencial, con memoria | `<=` |
| `always @(*)` | "cada vez que cambie cualquier señal que se lee adentro" | **Lógica combinacional**, sin memoria | `=` |

`posedge` significa *positive edge*: el instante en que el reloj pasa de 0 a 1. Existe también `negedge` (de 1 a 0), pero en este laboratorio no se usa.

**Forma 1: secuencial.** El bloque se ejecuta una vez por flanco de reloj; entre flancos, los valores se mantienen guardados.

```verilog
// Contador: suma 1 en cada flanco de subida del reloj
always @(posedge clk) begin
    if (rst)
        cnt <= 0;        // con reset, vuelve a cero
    else
        cnt <= cnt + 1;  // si no, avanza
end
```

**Forma 2: combinacional.** El `*` le dice a la herramienta "incluye todas las señales que leo". El bloque describe una tabla de verdad.

```verilog
// Mux 2:1: elige a o b según sel
always @(*) begin
    if (sel)
        y = b;
    else
        y = a;
end
```

`begin` y `end` agrupan varias instrucciones, como las llaves `{ }` en C. Si el bloque tiene una sola instrucción, se pueden omitir.

## 8. `=` y `<=`: las dos asignaciones

| Símbolo | Nombre | Dónde se usa |
|---|---|---|
| `<=` | Asignación **no bloqueante** | En `always @(posedge clk)` |
| `=` | Asignación **bloqueante** | En `always @(*)` |

Con `<=`, todas las asignaciones del bloque leen los valores **de antes del flanco** y se actualizan **al mismo tiempo**, igual que flip-flops reales. Este ejemplo intercambia `a` y `b` en cada flanco:

```verilog
always @(posedge clk) begin
    a <= b;   // a toma el valor ANTERIOR de b
    b <= a;   // b toma el valor ANTERIOR de a: se intercambian
end
```

Si se escribiera con `=`, la segunda línea leería el valor **ya modificado** de `a`, y ambos terminarían iguales. Para no equivocarse, sigan la regla de la tabla sin excepciones.

## 9. Decisiones: `if`, `case` y `? :`

```verilog
// if / else if / else: la primera condición verdadera gana
if (btn[1])
    codigo = 2'd1;
else if (btn[0])
    codigo = 2'd0;
else
    codigo = 2'd0;

// case: compara una señal contra varios valores (como una tabla de verdad)
case (sel)
    2'd0:    y = a;
    2'd1:    y = b;
    default: y = c;      // cualquier otro valor
endcase

// operador condicional: condicion ? valor_si_1 : valor_si_0
assign y = sel ? b : a;
```

`if` y `case` solo pueden usarse dentro de un `always`. El operador `? :` puede usarse en un `assign`.

## 10. Operadores

| Operador | Tipo | Ejemplo | Resultado |
|---|---|---|---|
| `~` `&` `\|` `^` | Bit a bit: NOT, AND, OR, XOR | `4'b1100 & 4'b1010` | `4'b1000` |
| `!` `&&` `\|\|` | Lógicos: el resultado es 1 bit | `(a == 1) && (b == 0)` | 1 o 0 |
| `==` `!=` | Igualdad, desigualdad | `cnt == 9` | 1 si cnt vale 9 |
| `<` `<=` `>` `>=` | Comparación de magnitud | `cnt < t_on` | 1 o 0 |
| `+` `-` | Suma, resta | `cnt + 1` | |
| `*` | Multiplicación (preferiblemente por constantes) | `sw * PASO` | |
| `<<` `>>` | Desplazamiento | `4'b0001 << 2` | `4'b0100` |
| `{ }` | Concatenación | `{2'b10, 2'b01}` | `4'b1001` |
| `{n{ }}` | Repetición | `{4{1'b1}}` | `4'b1111` |

Ojo: dentro de un `always`, `<=` es asignación; dentro de una condición, como `if (a <= b)`, es "menor o igual". El contexto define el significado.

## 11. Parámetros: `parameter` y `localparam`

Un **parámetro** es una constante con nombre. No ocupa hardware: la herramienta reemplaza su valor al sintetizar.

```verilog
module base_tiempo #(
    parameter CLK_FREQ  = 25_000_000,   // se puede cambiar al usar el módulo
    parameter TICK_FREQ = 1
)( ... );

    localparam N = CLK_FREQ / TICK_FREQ;   // constante interna, calculada
    reg [$clog2(N)-1:0] cnt;               // $clog2: bits necesarios para contar hasta N-1
```

- `parameter`: puede cambiarse desde afuera al instanciar el módulo (por ejemplo, el testbench usa otro `CLK_FREQ`).
- `localparam`: constante interna; no se cambia desde afuera.
- `$clog2(N)`: logaritmo en base 2 redondeado hacia arriba. Da el número de bits necesario.

Las divisiones entre constantes (como `CLK_FREQ / TICK_FREQ`) **no generan divisores** en el hardware: se calculan una sola vez al sintetizar.

## 12. Usar un módulo dentro de otro (instanciación)

Un diseño grande se arma conectando módulos pequeños, como se conectan chips en una protoboard. En este ejemplo, `base_tiempo` sería un módulo escrito por ustedes que genera un pulso por segundo.

```verilog
wire tick_1s;                          // cable que sale del módulo

base_tiempo #(                         // nombre del módulo que se usa
    .CLK_FREQ (CLK_FREQ),              // parámetros: .nombre(valor)
    .TICK_FREQ(1)
) u_tick_1s (                          // nombre de esta copia (instancia)
    .clk (clk),                        // puertos: .puerto_del_módulo(señal_de_aquí)
    .rst (rst),
    .tick(tick_1s)
);
```

Pueden usar el mismo módulo varias veces con nombres de instancia distintos (`u_tick_1s`, `u_tick_1ms`, ...).

## 13. Lo que solo existe en simulación

Algunas instrucciones solo tienen sentido en un **testbench** (el archivo que prueba el diseño) y la síntesis las ignora o las rechaza:

| Instrucción | Para qué sirve en simulación | En el diseño |
|---|---|---|
| `#10` | Esperar 10 unidades de tiempo | No usar: el tiempo se mide con contadores |
| `initial` | Ejecutar algo una sola vez al inicio | No usar para dar valores: usar `rst` |
| `$display(...)` | Imprimir un mensaje en la terminal | No genera hardware |
| `$dumpfile`, `$dumpvars` | Guardar las formas de onda | No genera hardware |
| `$finish` | Terminar la simulación | No genera hardware |

## 14. Errores frecuentes

| Error | Síntoma | Solución |
|---|---|---|
| Usar `=` en `always @(posedge clk)` | La simulación y la FPGA no coinciden | `<=` con reloj, `=` sin reloj |
| `if` sin `else` en `always @(*)` | La síntesis avisa "latch inferred" | Dar un valor por defecto al inicio del bloque |
| Asignar la misma señal en dos `always` | Error de "multiple drivers" | Cada señal se asigna en un solo bloque |
| Bus de ancho insuficiente | El contador se desborda antes de tiempo | Calcular los bits con $\lceil \log_2 N \rceil$ |
| Escribir números a mano (`25000`) | Todo falla al cambiar de tarjeta | Calcular a partir de `CLK_FREQ` |
| Usar una señal cualquiera como reloj | Fallas intermitentes | Un solo reloj y pulsos de habilitación ([Contadores y tiempo](04_Contadores_y_tiempo.md)) |

---

[← Metodología](01_Metodologia.md) · [Fundamentos](README.md) · [Siguiente: Lógica secuencial →](03_Logica_secuencial.md)
