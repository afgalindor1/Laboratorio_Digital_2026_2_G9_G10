# 8. Frecuencia del reloj: cómo saber `CLK_FREQ`

[← Entradas externas](07_Entradas_externas.md) · [Fundamentos](README.md) · [Siguiente: Simulación con testbench →](09_Simulacion.md)

`CLK_FREQ` es la frecuencia, en hertz, del reloj que llega a su diseño. **Todos** los tiempos del laboratorio se calculan a partir de ella: periodos, anchos de pulso, frecuencias, segundos. Si `CLK_FREQ` está mal, todo sale proporcionalmente mal: con el doble del valor real, cada segundo dura dos.

---

## Contenido

1. [Cuatro formas de averiguarla](#1-cuatro-formas-de-averiguarla)
2. [Cuidado con el PLL](#2-cuidado-con-el-pll)
3. [Cómo se usa `CLK_FREQ` en el código](#3-cómo-se-usa-clk_freq-en-el-código)
4. [Qué registrar en la bitácora](#4-qué-registrar-en-la-bitácora)

---

## 1. Cuatro formas de averiguarla

### a) El archivo de restricciones de los ejemplos

Los ejemplos `.zip` del curso traen un archivo de restricciones que asigna cada señal a un pin. La línea del reloj suele venir con un comentario que indica su frecuencia. Por ejemplo, el archivo `.pcf` de la tarjeta **BlackIce Mx** (iCE40 HX4K) del [repositorio del curso](https://github.com/johnnycubides/digital-electronic-1-101/tree/main/fpga-example/ice40-hx4k-MyStorm-BlackIce-Mx):

```
# Onboard 25Mhz oscillator
set_io clk 60
```

Se lee: la señal `clk` está en el pin 60 y viene de un oscilador de **25 MHz** en la tarjeta. Entonces `CLK_FREQ = 25_000_000`.

Busquen en el archivo de restricciones de su ejemplo una señal llamada `clk`, `clock`, `clk25`, `clk_50` o similar. Algunos formatos indican la frecuencia con una restricción explícita en lugar de un comentario.

### b) La documentación o el esquemático de la tarjeta

En el manual o el esquemático, busquen las palabras *oscillator*, *OSC*, *XTAL* o *CLK*. El oscilador suele aparecer como un componente con una referencia del tipo X1, Y1 o U*n*, y su frecuencia escrita al lado. Para la BlackIce Mx, los esquemáticos están en la misma carpeta del repositorio del curso.

### c) La marca del componente en la tarjeta

El oscilador es un componente pequeño, normalmente metálico y rectangular, de cuatro pines, cerca de la FPGA. Lleva impresa su frecuencia en MHz: `25.000` significa 25 MHz; `50.000`, 50 MHz; `12.000`, 12 MHz. Usen una lupa o la cámara del celular.

### d) Verificarla experimentalmente

Las tres formas anteriores dan un valor **supuesto**. Para confirmarlo en la tarjeta real:

1. Sinteticen el [ejemplo resuelto](12_Ejemplo_resuelto.md) ([parpadeo_dos_velocidades.v](ejemplos/parpadeo_dos_velocidades.v)) con el valor supuesto de `CLK_FREQ` y el interruptor en modo lento. El LED debería parpadear una vez por segundo.
2. Con un cronómetro, cuenten los parpadeos durante 60 segundos.
3. Si cuentan 60, el valor es correcto. Si no, calculen el real:

$$f_{real} = f_{supuesta} \times \frac{\text{parpadeos contados}}{60}$$

donde $f_{supuesta}$ es el valor de `CLK_FREQ` con el que sintetizaron.

Por ejemplo, si suponen 25 MHz y cuentan 120 parpadeos, el reloj real es de 50 MHz. Para mayor precisión, midan la salida del LED con el osciloscopio o el analizador lógico del laboratorio: el periodo debe ser 1 s.

## 2. Cuidado con el PLL

Algunos ejemplos no usan el oscilador directamente: lo pasan por un **PLL** (*Phase-Locked Loop*), un bloque de la FPGA que multiplica o divide la frecuencia. En las FPGA iCE40 se llama `SB_PLL40_CORE` o similar.

Si su ejemplo instancia un PLL, **`CLK_FREQ` es la frecuencia de salida del PLL**, no la del oscilador. El valor suele aparecer en un comentario junto al PLL. Si no están seguros, la prueba de parpadeo del punto d) lo resuelve.

## 3. Cómo se usa `CLK_FREQ` en el código

**Una sola definición.** `CLK_FREQ` se define una vez, como parámetro del módulo top, y se pasa hacia abajo a cada módulo que mida tiempo:

```verilog
module top #(
    parameter CLK_FREQ = 25_000_000         // Hz: único lugar donde se escribe
)( ... );

    base_tiempo #(                          // un submódulo propio que mide tiempo
        .CLK_FREQ (CLK_FREQ),               // se pasa el mismo valor hacia abajo
        .TICK_FREQ(1)
    ) u_tick_1s ( ... );

    localparam N_20MS = CLK_FREQ / 50;      // las cuentas se derivan de CLK_FREQ
```

**Nunca números a mano.** Escribir `500000` en lugar de `CLK_FREQ / 50` funciona en una tarjeta y falla en todas las demás, y además impide simular rápido.

**Otro valor en el testbench.** Como `CLK_FREQ` es un parámetro, el testbench puede usar un reloj mucho más lento para que la simulación termine en segundos:

```verilog
top #(.CLK_FREQ(1_000_000)) dut ( ... );    // 1 MHz solo en simulación
```

Cómo elegir ese valor sin perder resolución: [Simulación con testbench](09_Simulacion.md#3-un-clk_freq-reducido-para-simular-rápido).

## 4. Qué registrar en la bitácora

En el marco teórico o en la etapa de diseño, anoten:

- La tarjeta que usan y el valor de `CLK_FREQ`.
- De dónde lo obtuvieron (archivo de restricciones, esquemático, marca del componente).
- El resultado de la verificación experimental (parpadeos contados o medición con osciloscopio).
- El periodo del reloj, $T = 1 / f_{clk}$, y cómo se usa en su tabla de cálculos.

---

[← Entradas externas](07_Entradas_externas.md) · [Fundamentos](README.md) · [Siguiente: Simulación con testbench →](09_Simulacion.md)
