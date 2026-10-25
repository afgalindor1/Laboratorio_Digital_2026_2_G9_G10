# Errores frecuentes

[← Volver a la guía](README.md)

Antes de preguntar, busquen aquí el **síntoma**. Si no está, lleguen a clase con: el comando que ejecutaron, el mensaje de error completo y qué intentaron.

**Método general para depurar:** aislar el problema por partes, de adentro hacia afuera.

```
¿El periférico pasa su testbench?  →  ¿El SoC simula bien con make sim?  →  ¿La síntesis termina sin errores?  →  ¿Funciona en la tarjeta?
```

Si algo falla en un paso, el error está en ese paso o en uno anterior, nunca en uno posterior.

---

## Instalación y entorno

| Síntoma | Causa probable | Solución |
|---|---|---|
| `riscv64-unknown-elf-gcc: command not found` | Falta el compilador | `sudo apt install gcc-riscv64-unknown-elf` |
| `yosys: command not found`, `iverilog: command not found`… | No activaron el entorno en esta terminal | `source digital-logic-design activate` |
| `nextpnr-himbaechel: command not found` | Versión vieja de OSS CAD Suite | Actualicen el entorno del curso (`digital-logic-design` del repositorio) |
| `make: *** No rule to make target 'firmware/xxx.c'` | El nombre en `PROG=` no corresponde a un archivo | `PROG` va **sin** `.c`: `make sim PROG=gpio` |

## Compilación del programa en C

| Síntoma | Causa probable | Solución |
|---|---|---|
| `undefined reference to '__udivsi3'` o `'__mulsi3'` | Se quitó `-lgcc` o se enlaza con `ld` en vez de `gcc` | Usen el `Makefile` sin modificar la línea de enlace |
| `ERROR: el programa ocupa N palabras y la RAM tiene 8192` | El programa no cabe en 32 KB | Quiten textos largos o funciones que no usen |
| `error: 'GPIO_LEDS' undeclared` | Falta el `#define` del registro | Defínanlo al inicio del `.c` según su tabla de registros |
| Advertencia `LOAD segment with RWX permissions` | Normal en este tipo de programas | Se puede ignorar |

## Simulación

| Síntoma | Causa probable | Solución |
|---|---|---|
| La simulación termina en `2000000 ciclos simulados, 0 caracteres recibidos` | El programa no llega a imprimir: se quedó esperando algo | Busquen un `while` que espere un periférico (por ejemplo `MULT_DONE`) con una dirección equivocada. Simulen con `ARGS=+vcd` y miren `mem_addr` |
| `0 caracteres` aun con `hola.c` sin cambios | Compilaron a mano sin `-DBENCH` | Usen `make sim`: agrega `-DBENCH`, que inicializa registros internos del CPU |
| Error de Icarus en `perip_gpio.v` con `COMPLETAR` | Quedan partes sin completar en la plantilla | Completen todas las marcas `/* COMPLETAR */` |
| `Unknown module type: perip_gpio` | El archivo no está en `soc/rtl/` o se llama distinto | El archivo debe ser `soc/rtl/perip_gpio.v`: el `Makefile` agrega solo los `rtl/perip_*.v` |
| `LEDS_EXT = 00000000` aunque el programa escribe en los LEDs | No borraron `assign LEDS_EXT = 8'b0;` o no conectaron `.leds(LEDS_EXT)` | Revisen los 4 cambios de la Semana 2, tarea 4 |
| Leer un registro del periférico devuelve siempre 0 | `chip1_dout` sigue en `32'b0`, o el desplazamiento del `#define` no coincide con el del Verilog | Conecten `.chip1_dout(gpio_dout)`; comparen la tabla de registros con el código C y el Verilog |
| El multiplicador devuelve 0 | Se leyó `RESULT` mucho después de `DONE` | Lean el resultado inmediatamente después del `while (!MULT_DONE)`, como `mult_hw()` |
| GTKWave no muestra el ciclo que busco | El VCD solo guarda los primeros 20 000 ciclos | Cambien `DUMP_CICLOS` en `sim/tb_soc.v` (archivos más grandes y lentos) |

## Síntesis

| Síntoma | Causa probable | Solución |
|---|---|---|
| `ERROR: IO 'xxx' is unconstrained in LPF` (Colorlight) | Agregaron un puerto al top sin pin en el `.lpf` | Agreguen las líneas `LOCATE COMP` e `IOBUF PORT` del puerto |
| Error de nextpnr-himbaechel sobre un pin o un banco (Tang Nano) | El pin no existe o está en un banco de 1,8 V con `LVCMOS33` | Elijan otro pin del pinout oficial |
| `Max frequency … FAIL` | El diseño no alcanza la frecuencia del reloj | No debería pasar con este SoC (alcanza unos 60 MHz). Revisen si agregaron lógica combinacional muy larga en su periférico |

## En la tarjeta

| Síntoma | Causa probable | Solución |
|---|---|---|
| `unable to open ftdi device` / `permission denied` | Permisos de USB o cable mal conectado | Ver [Tarjetas.md, permisos](Tarjetas.md#permisos-en-linux) |
| `make terminal`: `FATAL: cannot open /dev/ttyUSB1: Permission denied` | El usuario no pertenece al grupo `dialout` (pasa la primera vez en casi todos los computadores) | `sudo usermod -aG dialout $USER` y luego cerrar sesión y volver a entrar. Para probar ya, sin cerrar sesión: `sudo chmod a+rw /dev/ttyUSB1` (se pierde al desconectar la tarjeta) |
| Colorlight: no se configura | Alimentación insuficiente o JTAG mal cableado | Fuente externa de 5 V; revisen TDI, TDO, TCK, TMS y GND |
| No se puede salir de `make terminal` con `Ctrl-a` `Ctrl-x` | Están usando la terminal integrada de un editor (Lite XL, VS Code…), que se queda con `Ctrl-a` | Cierren esa pestaña de terminal, o ejecuten `pkill picocom` desde otra. Para `make terminal` usen la terminal normal del sistema |
| La terminal no muestra nada | Puerto equivocado, TX/RX cruzados, falta GND, o no hubo reset | Prueben el otro `/dev/ttyUSB*`; TX de la FPGA va al RX del adaptador; presionen reset con la terminal abierta |
| La terminal muestra caracteres sin sentido | Velocidad distinta en los dos lados | Tang Nano: `CLK_FREQ` debe ser 27 MHz en su top. La terminal debe estar a 115200 baudios (`make terminal` ya la pone) |
| Funciona en simulación pero los LEDs no cambian | Cableado, pines o LEDs al revés; o no se volvió a sintetizar | Revisen polaridad del LED y pines de [Tarjetas.md](Tarjetas.md). Después de cambiar el C: `make syn` y `make config` |
| Tang Nano: los LEDs se ven al revés | Se quitó la inversión del top | Los LEDs de la tarjeta son activos en bajo: el top usa `assign led = ~leds_soc[5:0];` |
| Al apagar la tarjeta se pierde el diseño | `make config` es volátil | Usen `make config-flash` para que quede grabado |

[← Volver a la guía](README.md)
