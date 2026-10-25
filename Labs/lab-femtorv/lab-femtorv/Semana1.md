# Semana 1 · Del contador al procesador

[← Volver a la guía](README.md)

**Objetivo de la semana:** entender qué es un procesador, ejecutar un programa en C en el FemtoRV (simulado y en la tarjeta) y construir el mapa de memoria del SoC.

**Antes de empezar:** lean [Fundamentos 01](Fundamentos/01_RISC-V_y_FemtoRV.md), [Fundamentos 03](Fundamentos/03_De_C_a_la_FPGA.md) y las secciones 1 a 4 de [Fundamentos 02](Fundamentos/02_Bus_y_perifericos.md). Activen el entorno en cada terminal: `source digital-logic-design activate`.

**Regla de trabajo:** en cada tarea que lo pida, **escriban la predicción en la bitácora antes de ejecutar el comando**. La predicción equivocada que se explica vale más que el resultado correcto copiado.

| Tarea | Qué hacen | Tiempo estimado |
|---|---|---|
| [1](#tarea-1-el-blinker-desde-memoria) | Blinker desde memoria: predecir, simular, llevar a la tarjeta | 1 h |
| [2](#tarea-2-el-primer-programa-en-el-femtorv) | Primer programa en el FemtoRV: simulación y tarjeta | 1 h |
| [3](#tarea-3-el-mapa-de-memoria) | Mapa de memoria del SoC | 45 min |
| [4](#tarea-4-las-cinco-partes-del-femtorv) | Ubicar las cinco partes del FemtoRV en su código | 45 min |
| [5](#tarea-5-de-una-línea-de-c-al-bus) | De una línea de C a una instrucción y al bus | 1 h |
| [✓](#punto-de-control) | Punto de control al inicio de la semana 2 | 5 min |

---

## Tarea 1. El blinker desde memoria

Carpeta: `blinker/`. Archivo principal: `blinker/rtl/blinker.v`.

### 1.1 Leer y predecir

Lean `blinker.v` y respondan en la bitácora **antes de simular**:

1. Dibujen el diagrama de bloques del circuito: divisor, PC, ROM y LEDs, con el ancho en bits de cada señal.
2. Completen la tabla para las primeras 8 posiciones:

   | PC | LEDS (predicción) | LEDS (simulación) |
   |---|---|---|
   | 0 | | |
   | 1 | | |
   | … | | |
   | 7 | | |

3. El testbench usa `DIV_BITS = 3` y un reloj de 25 MHz (periodo 40 ns). ¿Cada cuántos **ciclos** y cada cuántos **nanosegundos** avanza el PC?
4. En la tarjeta, `DIV_BITS = 22`. ¿Cuánto dura cada paso en la Colorlight (25 MHz) y en la Tang Nano (27 MHz)? ¿Cuánto dura la secuencia completa de 21 pasos?
5. La ROM se lee en un `always @(posedge clk)`. ¿Los LEDs cambian en el **mismo** ciclo que el PC o en el **siguiente**? ¿Por qué?

### 1.2 Simular

```bash
cd blinker
make sim
```

La terminal muestra una línea por cada cambio de los LEDs, por ejemplo:

```
t =    380 ns   PC =  1   LEDS = 00001
t =    700 ns   PC =  2   LEDS = 00010
```

Completen la columna "simulación" de la tabla y comprueben las respuestas 3 y 5. Abran las formas de onda con `make wave`, agreguen `clk`, `PC`, `tick` y `leds` (dentro de `uut`) y hagan una captura donde se vea **un** cambio del PC y el cambio de los LEDs un ciclo después.

### 1.3 Llevar a la tarjeta

Conecten los LEDs según [Tarjetas.md](Tarjetas.md) (en la Tang Nano se usan los de la tarjeta).

```bash
make syn BOARD=colorlight        # o BOARD=tangnano9k
make config BOARD=colorlight
```

Midan con un cronómetro cuánto tarda la secuencia completa (tomen el tiempo de 5 vueltas y dividan) y compárenlo con su respuesta 4.

### 1.4 Preguntas para la bitácora

1. ¿Qué tendría que **agregarse** a este circuito para que fuera un procesador? Usen la tabla de la sección 1 de [Fundamentos 01](Fundamentos/01_RISC-V_y_FemtoRV.md#1-un-procesador-es-un-contador-que-lee-una-memoria).
2. Si el contenido de la ROM fueran instrucciones y no patrones de LEDs, ¿qué bloque las interpretaría?

---

## Tarea 2. El primer programa en el FemtoRV

Carpeta: `soc/`. Programa: `soc/firmware/hola.c`.

### 2.1 Simular el programa tal como está

```bash
cd soc
make sim
```

El `Makefile` hace cuatro cosas, en este orden (miren la terminal):

1. Compila `firmware/hola.c` con `riscv64-unknown-elf-gcc`.
2. Genera `build/firmware.lst` (el listado) y `firmware.hex` (el programa para la memoria).
3. Compila el SoC y el testbench con Icarus Verilog.
4. Simula: el testbench escucha la UART y muestra lo que el programa envía.

Resultado esperado:

```
=== Simulacion del SoC: salida de la UART ===
Hola desde el FemtoRV
Por software (sumas repetidas): 5535
Por hardware (periferico MULT): 5535
Fin. El programa queda en un bucle infinito.

=== Fin: 155708 ciclos simulados, 145 caracteres recibidos, LEDS_EXT = 00000000 ===
```

Anoten en la bitácora: cuántas palabras de la RAM ocupa el programa (línea `firmware.hex: … palabras usadas`) y cuántos ciclos se simularon.

### 2.2 Modificar el programa

Editen `firmware/hola.c` para que, además, imprima el número del grupo y los nombres de sus integrantes. Vuelvan a ejecutar `make sim`. Copien la salida en la bitácora.

### 2.3 Llevar el programa a la tarjeta

Conecten la UART según [Tarjetas.md](Tarjetas.md) (en la Colorlight hace falta un adaptador USB-serial; en la Tang Nano basta el cable USB).

```bash
make syn BOARD=colorlight         # tarda 1 a 2 minutos
make config BOARD=colorlight
make terminal BOARD=colorlight    # salir: Ctrl-a y luego Ctrl-x
```

Con la terminal abierta, presionen el botón de reset de la tarjeta: el mensaje debe aparecer de nuevo.

Al final de `make syn` aparece una tabla de recursos. **Guárdenla en la bitácora**: la van a comparar en la semana 2 con el SoC que tenga su periférico.

### 2.4 Preguntas para la bitácora

1. ¿Por qué el mismo programa produce la misma salida en la simulación y en la tarjeta, si en la simulación la UART es mucho más rápida? (Pista: lean el encabezado de `sim/tb_soc.v` y la función `uart_putc` en `firmware/soc.h`).
2. ¿Por qué cada cambio en `hola.c` obliga a ejecutar `make syn` otra vez? ([Fundamentos 03, sección 6](Fundamentos/03_De_C_a_la_FPGA.md#6-cómo-llega-el-programa-a-la-fpga)).

---

## Tarea 3. El mapa de memoria

Construyan el mapa de memoria del SoC **leyendo el código**, no copiándolo de `soc.h`. Archivos: `soc/rtl/chip_select.v`, `soc/rtl/SOC.v`, `soc/rtl/uart/perip_uart.v` (módulo `peripheral_uart_addr_decoder`) y `soc/rtl/mult/perip_mult.v`.

### 3.1 Tabla de bloques

| Rango de direcciones | Bloque | Señal `cs` | Dato que vuelve al CPU (`chipX_dout`) |
|---|---|---|---|
| `0x0000_0000` – `0x0000_7FFF` | | | |
| `0x0040_0000` – `0x0040_FFFF` | | | |
| `0x0041_0000` – `0x0041_FFFF` | | | |
| `0x0042_0000` – `0x0042_FFFF` | | | |
| `0x0043_0000` – `0x0045_FFFF` | | | |

### 3.2 Tabla de registros de la UART y del multiplicador

| Dirección completa | Periférico | Nombre | Lectura / Escritura | Qué significan sus bits |
|---|---|---|---|---|
| | UART | | | |
| | UART | | | |
| | MULT | | | |
| … | | | | |

### 3.3 Preguntas

1. ¿Cuántos bits de la dirección mira `chip_select.v` y cuántos bits mira cada periférico para distinguir sus registros?
2. ¿Por qué la RAM es el caso `default` del `case` y no tiene un valor propio?
3. Si el programa escribe en `0x0043_0000`, ¿qué bloque recibe la escritura? ¿Y si lee de esa dirección? (Revisen qué valor tiene `chip3_dout` en `SOC.v`).
4. El multiplicador borra su resultado unos 30 ciclos después de `DONE` (lean el estado `END` de `soc/rtl/mult/mult.v`). ¿Cómo debería decirlo su tabla de registros? ¿Por qué `mult_hw()` en `soc.h` sí funciona?

---

## Tarea 4. Las cinco partes del FemtoRV

Abran `soc/rtl/cpu/femtorv32_quark.v` y la sección 7 de [Fundamentos 01](Fundamentos/01_RISC-V_y_FemtoRV.md#7-las-cinco-partes-del-femtorv-quark).

### 4.1 Ubicar

| Parte | Líneas | Señales o registros principales | Qué hace (una frase con sus palabras) |
|---|---|---|---|
| ① PC y siguiente PC | | | |
| ② Registro de instrucción y decodificador | | | |
| ③ Banco de registros | | | |
| ④ ALU y comparador de saltos | | | |
| ⑤ Interfaz de memoria | | | |

### 4.2 Preguntas

1. ¿En qué línea se garantiza que `x0` siempre valga 0?
2. Expliquen con la máquina de estados (líneas 292–370) por qué un `sw` tarda 4 ciclos y un `addi` tarda 3.
3. ¿Qué señal del bus indica, en el estado `FETCH_INSTR`, que el procesador está pidiendo una instrucción?
4. Comparen con el blinker de la tarea 1: ¿qué parte del FemtoRV equivale a su contador y cuál a su lectura de ROM?

---

## Tarea 5. De una línea de C al bus

### 5.1 Encontrar la instrucción

Abran `soc/build/firmware.lst` y busquen la función `imprimir`. Con la sección 8 de [Fundamentos 03](Fundamentos/03_De_C_a_la_FPGA.md#8-cómo-leer-firmwarelst):

1. Encuentren el `sw` que escribe un carácter en el registro de dato de la UART. Anoten su **dirección en la memoria de programa** y su **código máquina**.
2. ¿En qué registro está la dirección `0x0040_0008`? ¿Qué dos instrucciones la calcularon?
3. Decodifiquen a mano el código máquina de ese `sw`: separen los campos del formato S y digan qué es cada uno.

### 5.2 Verlo en las formas de onda

```bash
make sim ARGS=+vcd     # guarda los primeros 20 000 ciclos
make wave
```

En GTKWave, dentro de `tb_soc` → `uut`, agreguen: `clk`, `mem_addr`, `mem_wdata`, `mem_wmask`, `mem_rstrb`, `cs` y, dentro de `CPU`, `state`. Pongan `mem_addr` y `mem_wdata` en hexadecimal.

1. Busquen el **primer** ciclo en que `mem_addr = 00400008` y `mem_wmask = 1111`. ¿Qué valor tiene `mem_wdata`? ¿A qué carácter ASCII corresponde?
2. En ese ciclo, ¿qué vale `cs`? ¿Coincide con su mapa de memoria?
3. ¿En qué estado está el CPU? ¿Cuántos ciclos después vuelve a `FETCH_INSTR`?
4. Hagan una captura de pantalla con el cursor en ese ciclo y explíquenla en la bitácora, señal por señal.

### 5.3 ¿Dónde está el bucle?

En `hola.c` el producto "por software" se calcula con un bucle `for` de 45 sumas. Búsquenlo en `firmware.lst` dentro de `main`.

1. ¿Encuentran el bucle? ¿Qué encuentran en su lugar?
2. Expliquen qué hizo el compilador ([Fundamentos 03, sección 9](Fundamentos/03_De_C_a_la_FPGA.md#9-el-compilador-es-más-listo-de-lo-que-parece)).
3. ¿Por qué eso importa cuando se quiere **medir** cuánto tarda algo?

Ahora impidan que el compilador haga la cuenta:

4. En `hola.c` cambien `uint32_t a = 123, b = 45;` por `volatile uint32_t a = 123, b = 45;` y ejecuten `make sim`. Vuelvan a buscar el bucle en `firmware.lst`. ¿Cuántas palabras ocupa ahora el programa? ¿Qué instrucciones forman **una vuelta** del bucle y cuál de ellas es el salto que lo cierra?
5. Con la tabla de ciclos del Quark ([Fundamentos 01, sección 8](Fundamentos/01_RISC-V_y_FemtoRV.md#8-la-máquina-de-estados-y-los-ciclos-por-instrucción)): 3 ciclos para ALU y saltos, 4 para `lw`/`sw`, estimen cuántos ciclos tarda la multiplicación por software (45 vueltas).
6. Comparen los **ciclos simulados** de la última línea de `make sim` con y sin `volatile`. ¿La diferencia coincide con su estimación?

Al terminar, dejen `hola.c` como estaba: `git restore firmware/hola.c`.

---

## Punto de control

Al inicio de la semana 2, cada grupo muestra en 5 minutos:

- [ ] `make sim` funcionando, con el mensaje de su grupo.
- [ ] El mapa de memoria completo (tareas 3.1 y 3.2).
- [ ] Una respuesta oral: el profesor señala una dirección y el grupo dice qué bloque la atiende y qué pasa al escribirla.

Si algo no funciona, revisen [Errores_frecuentes.md](Errores_frecuentes.md) y lleguen con la pregunta concreta.

## Lo que va a la bitácora esta semana

- Tarea 1: diagrama, tabla de predicción frente a simulación, respuestas, captura de GTKWave, tiempo medido.
- Tarea 2: salida de la simulación con su mensaje, tabla de recursos de la síntesis, respuestas.
- Tarea 3: las dos tablas y las respuestas.
- Tarea 4: la tabla de las cinco partes y las respuestas.
- Tarea 5: instrucción decodificada, captura de GTKWave explicada, respuestas.

[← Volver a la guía](README.md) · [Semana 2 →](Semana2.md)
