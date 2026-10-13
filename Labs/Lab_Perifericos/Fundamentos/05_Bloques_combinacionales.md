# 5. Bloques combinacionales

[← Contadores y tiempo](04_Contadores_y_tiempo.md) · [Fundamentos](README.md) · [Siguiente: Señales periódicas y PWM →](06_Senales_periodicas_PWM.md)

Un bloque combinacional calcula sus salidas solo a partir de sus entradas actuales: no tiene memoria, y todo su comportamiento cabe en una **tabla de verdad**. Cinco bloques clásicos resuelven gran parte de los problemas de este laboratorio: decodificadores, codificadores, multiplexores, demultiplexores y comparadores.

---

## Contenido

1. [De la tabla de verdad al Verilog](#1-de-la-tabla-de-verdad-al-verilog)
2. [Decodificador](#2-decodificador)
3. [Codificador de prioridad](#3-codificador-de-prioridad)
4. [Multiplexor y mux de constantes](#4-multiplexor-y-mux-de-constantes)
5. [Demultiplexor y multiplexación en el tiempo](#5-demultiplexor-y-multiplexación-en-el-tiempo)
6. [Comparadores](#6-comparadores)

---

## 1. De la tabla de verdad al Verilog

| Forma | Cuándo usarla | Ejemplo |
|---|---|---|
| `assign` con una ecuación | Funciones pequeñas | `assign y = a & ~b;` |
| `assign` con `? :` | Elegir entre dos valores | `assign y = sel ? b : a;` |
| `case` dentro de `always @(*)` | Copiar una tabla de verdad fila por fila | ver abajo |

```verilog
reg [3:0] y;

always @(*) begin            // se reevalúa cada vez que cambia sel
    y = 4'b0000;             // 1) valor por defecto: evita latches
    case (sel)               // 2) una línea por fila de la tabla
        2'd0: y = 4'b0001;
        2'd1: y = 4'b0010;
        2'd2: y = 4'b0100;
        2'd3: y = 4'b1000;
    endcase
end
```

**Reglas para `always @(*)`:** usar `=`, nunca `<=`; dar a cada salida un valor por defecto o asegurar que reciba valor en todos los casos. Si falta un caso, la herramienta crea un latch ([por qué](03_Logica_secuencial.md#7-flip-flop-y-latch-no-son-lo-mismo)).

**Las tablas de verdad son parte del diseño.** Cada bloque combinacional del sistema debe tener su tabla en la bitácora, incluidos los casos especiales. Las combinaciones que no pueden ocurrir se marcan con **X** (no importa). Esas tablas son también la lista de casos que el testbench debe verificar.

## 2. Decodificador

Un **decodificador n a 2ⁿ** recibe un número de n bits y activa **una sola** de sus 2ⁿ salidas (código *one-hot*). La tabla de la sección anterior es un decodificador 2 a 4. Suele tener una habilitación: con `en = 0`, todas las salidas quedan en 0.

En general, **cualquier tabla "número → patrón de salidas" es un decodificador**: por ejemplo, convertir un dígito en los segmentos que deben encenderse en un display, o convertir una cuenta en un patrón de señales de salida.

**Display de 7 segmentos.** Son siete LEDs, de **a** a **g**:

```
 ───a───
│       │
f       b
│       │
 ───g───
│       │
e       c
│       │
 ───d───
```

Un decodificador **BCD a 7 segmentos** recibe un dígito de 0 a 9 en 4 bits y entrega qué segmentos se encienden. Antes de escribir su tabla hay que saber el tipo de display: en **cátodo común** el segmento se enciende con 1; en **ánodo común**, con 0. Por ejemplo, el dígito 1 enciende solo los segmentos b y c. La tabla completa se construye a partir del dibujo y se encuentra en cualquier libro de introducción ([Dónde buscar](01_Metodologia.md#10-dónde-buscar)).

## 3. Codificador de prioridad

Un **codificador** hace lo inverso: recibe varias líneas y entrega el **número** de la línea activa. El **codificador de prioridad** además resuelve qué pasa con **varias** líneas activas (gana la de mayor prioridad) y con **ninguna** (lo indica con una salida `valido = 0`). Es la forma natural de leer varios pulsadores.

| `btn[3]` | `btn[2]` | `btn[1]` | `btn[0]` | `codigo` | `valido` |
|---|---|---|---|---|---|
| 1 | X | X | X | 11 | 1 |
| 0 | 1 | X | X | 10 | 1 |
| 0 | 0 | 1 | X | 01 | 1 |
| 0 | 0 | 0 | 1 | 00 | 1 |
| 0 | 0 | 0 | 0 | 00 | 0 |

En Verilog, una cadena `if` / `else if` describe la prioridad de forma natural, porque la primera condición verdadera gana. Qué entrada tiene prioridad y qué pasa sin entradas son **decisiones de diseño** que se documentan.

## 4. Multiplexor y mux de constantes

Un **multiplexor** (mux) elige **una** de varias entradas según un selector. Un mux 2:1 es simplemente `assign y = sel ? b : a;`.

Si las entradas son **constantes**, el mux funciona como una **tabla de valores**: a cada código le corresponde un número fijo. Es el puente entre una elección del usuario y una cantidad de ciclos de reloj. En el [ejemplo resuelto](12_Ejemplo_resuelto.md), un interruptor elige entre dos límites de cuenta:

```verilog
// Mux de constantes: el interruptor elige el límite del contador
wire [ANCHO-1:0] limite = rapido ? N_RAPIDO : N_LENTO;
```

Las constantes (`localparam`) se calculan al sintetizar, así que sus divisiones no generan divisores en el hardware.

## 5. Demultiplexor y multiplexación en el tiempo

Un **demultiplexor** toma **una** entrada y la envía a **una** de varias salidas según el selector; las demás quedan en 0. Es un decodificador cuya habilitación es el dato.

**Multiplexación en el tiempo:** un mux y un demux controlados por el **mismo selector**, que cambia periódicamente, permiten que varios usuarios compartan un mismo recurso por turnos. Si los turnos son suficientemente rápidos, el ojo no percibe la alternancia (persistencia de la visión). Es una técnica clásica para manejar varios displays con pocas líneas; busquen "multiplexed seven-segment display" en los libros de FPGA.

## 6. Comparadores

| Tipo | Verilog | Cómo se construye |
|---|---|---|
| Igualdad | `a == b`, `a != b` | Una XNOR por bit y una AND de todos los resultados |
| Magnitud | `a < b`, `a >= b`, ... | Un restador del que solo se usa el signo |
| Ventana | `(x >= MIN) && (x < MAX)` | Dos comparadores de magnitud y una AND |

Cuando uno de los valores es una constante, la herramienta simplifica el circuito.

**Código termómetro.** Un banco de comparadores contra umbrales crecientes activa salidas en orden, como el mercurio de un termómetro: con un valor bajo se activa una salida, con uno mayor se activan más. Sirve para mostrar una magnitud como una barra de LEDs.

**Comparador + contador.** Comparar una cuenta con un valor convierte el número en **tiempo**: `cnt == M − 1` marca el final de un periodo; `cnt < valor` genera un pulso cuyo ancho depende de `valor`. Ver [Señales periódicas y PWM](06_Senales_periodicas_PWM.md).

---

[← Contadores y tiempo](04_Contadores_y_tiempo.md) · [Fundamentos](README.md) · [Siguiente: Señales periódicas y PWM →](06_Senales_periodicas_PWM.md)
