# 4. Contadores y tiempo

[← Lógica secuencial](03_Logica_secuencial.md) · [Fundamentos](README.md) · [Siguiente: Bloques combinacionales →](05_Bloques_combinacionales.md)

En una FPGA el tiempo se mide **contando flancos de reloj**. El contador es la pieza que lo hace posible: casi todos los periféricos del laboratorio necesitan al menos uno.

---

## Contenido

1. [Qué es un contador](#1-qué-es-un-contador)
2. [Contador módulo M](#2-contador-módulo-m)
3. [Del tiempo a ciclos de reloj](#3-del-tiempo-a-ciclos-de-reloj)
4. [Pulso de habilitación: algo más lento sin crear otro reloj](#4-pulso-de-habilitación-algo-más-lento-sin-crear-otro-reloj)
5. [Otras formas de contador](#5-otras-formas-de-contador)

---

## 1. Qué es un contador

Un contador es un **registro** más un **sumador**: en cada flanco de reloj, el registro guarda su propio valor más 1. Un contador de N bits recorre $2^N$ valores y vuelve a empezar:

```
0000 → 0001 → 0010 → ... → 1110 → 1111 → 0000 → ...
```

```verilog
reg [3:0] cnt;                   // 4 flip-flops: la cuenta se recuerda

always @(posedge clk) begin
    if (rst)
        cnt <= 4'd0;
    else
        cnt <= cnt + 1;          // de 15 pasa solo a 0
end
```

## 2. Contador módulo M

Para contar M valores (de 0 a M − 1) se agrega un **comparador de reinicio**: cuando la cuenta llega a M − 1, en el siguiente flanco vuelve a 0.

```
cnt   0 → 1 → 2 → ... → M−2 → M−1 → 0 → 1 → ...
                               ↑ el comparador detecta el final
```

En el diagrama de flujo es un rombo "¿la cuenta llegó a M − 1?"; en Verilog, un `if` con una comparación. **Error frecuente:** comparar con `M` en lugar de `M − 1`: el contador tendría M + 1 valores y todos los tiempos saldrían un ciclo más largos.

## 3. Del tiempo a ciclos de reloj

Si el reloj tiene frecuencia $f_{clk}$, un intervalo de tiempo $t$ equivale a $N$ ciclos, y el contador necesita $\lceil \log_2 N \rceil$ bits:

$$N = t \cdot f_{clk} \qquad \text{bits} = \lceil \log_2 N \rceil$$

Para repetir algo con frecuencia $f$, el contador es módulo $N = f_{clk} / f$.

Ejemplos con un reloj de 25 MHz (verifiquen el de su tarjeta en [Frecuencia del reloj](08_Frecuencia_del_reloj.md)):

| Tiempo | Ciclos (N) | Bits |
|---|---|---|
| 1 µs | 25 | 5 |
| 1 ms | 25 000 | 15 |
| 10 ms | 250 000 | 18 |
| 1 s | 25 000 000 | 25 |

En el código **nunca** se escriben estos números a mano: se calculan a partir del parámetro `CLK_FREQ`, para que el diseño funcione con cualquier reloj y el testbench pueda usar uno más lento.

```verilog
localparam N_1MS = CLK_FREQ / 1000;      // ciclos en 1 ms
localparam ANCHO = $clog2(N_1MS);        // bits necesarios
```

## 4. Pulso de habilitación: algo más lento sin crear otro reloj

Muchas cosas deben ocurrir más lento que el reloj. La tentación es dividir el reloj y usar el resultado en `always @(posedge clk_lento)`. **No se debe hacer.** La FPGA tiene una red especial que lleva el reloj a todos los flip-flops al mismo tiempo; un reloj fabricado con lógica no viaja por ella, llega con retraso y en momentos distintos a cada flip-flop, y el diseño falla de forma intermitente.

La técnica correcta es generar un **pulso de habilitación** (*tick*): una señal que vale 1 durante **un solo ciclo** cada N ciclos. Todo el diseño sigue usando el mismo `clk`, y lo que debe ir lento solo avanza cuando el tick vale 1.

```
clk   __|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
tick  __________|‾‾‾|_______________|‾‾‾|____   (1 ciclo cada N ciclos)
```

```verilog
// INCORRECTO: una señal de lógica usada como reloj
always @(posedge clk_lento) ...

// CORRECTO: un solo reloj; la variable avanza solo cuando tick = 1
always @(posedge clk)
    if (tick)
        variable_lenta <= variable_lenta + 1;
```

El tick sale de un contador módulo N cuyo comparador de reinicio se usa también como pulso.

## 5. Otras formas de contador

| Forma | Idea | Dónde buscar más |
|---|---|---|
| **Contadores encadenados** | Un segundo contador avanza solo cuando el primero da la vuelta, como el acarreo de una suma. Así se cuentan varios dígitos | Contadores BCD y en cascada, en cualquiera de los libros de [Dónde buscar](01_Metodologia.md#10-dónde-buscar) |
| **Ascendente / descendente** | El mismo registro suma o resta según una señal de dirección | Contadores up/down |
| **Contador libre** | Cuenta sin parar; su bit k cambia de valor cada $2^k$ ciclos, así que sus bits sirven como divisores de frecuencia aproximados | Divisores de frecuencia |
| **Con saturación** | No pasa de un máximo ni baja de un mínimo, en lugar de dar la vuelta | Contadores con límites |

```
cnt      0   1   2   3   4   5   6   7   8
cnt[0]   0   1   0   1   0   1   0   1   0     cambia cada 1 ciclo
cnt[1]   0   0   1   1   0   0   1   1   0     cambia cada 2 ciclos
cnt[2]   0   0   0   0   1   1   1   1   0     cambia cada 4 ciclos
```

---

[← Lógica secuencial](03_Logica_secuencial.md) · [Fundamentos](README.md) · [Siguiente: Bloques combinacionales →](05_Bloques_combinacionales.md)
