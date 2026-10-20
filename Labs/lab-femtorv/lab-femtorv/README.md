# Laboratorio: Procesador RISC-V y periféricos mapeados en memoria

**Electrónica Digital I · Grupos G9 y G10 · Duración: 2 semanas**

En el laboratorio de periféricos cada grupo diseñó una **tarea de hardware**: un circuito que controla un dispositivo por sí solo. En este laboratorio ese hardware deja de trabajar solo: lo controla un **procesador RISC-V** a través de un **programa en C**.

Esta es la estructura base de la **consola de videojuegos** del proyecto final: un procesador (el FemtoRV) que ejecuta el juego y varios periféricos (pantalla, controles, sonido) que el programa maneja escribiendo y leyendo direcciones de memoria. Aquí se construye esa estructura en pequeño.

> **No se diseña el procesador.** Se usa el FemtoRV32 Quark que ya está en el repositorio del curso. El trabajo es **entenderlo, programarlo y conectarle un periférico propio**.

---

## Contenido

- [Objetivos de aprendizaje](#objetivos-de-aprendizaje)
- [Qué hay en esta carpeta](#qué-hay-en-esta-carpeta)
- [Plan de las dos semanas](#plan-de-las-dos-semanas)
- [Antes de empezar](#antes-de-empezar)
- [Inicio rápido](#inicio-rápido)
- [Fundamentos](#fundamentos)
- [Entregables](#entregables)
- [Evaluación](#evaluación)
- [Relación con la consola](#relación-con-la-consola)
- [Diferencias con el ejemplo del repositorio](#diferencias-con-el-ejemplo-del-repositorio)
- [Referencias](#referencias)

---

## Objetivos de aprendizaje

Al terminar, el grupo será capaz de:

1. Explicar qué es **RISC-V** (un conjunto de instrucciones) y qué es el **FemtoRV** (un circuito que ejecuta esas instrucciones), y por qué no son lo mismo.
2. Reconocer en el código Verilog del FemtoRV sus cinco partes: contador de programa, registro de instrucción, decodificador, banco de registros con ALU, e interfaz de memoria.
3. Explicar el ciclo **buscar → decodificar → ejecutar** y calcular cuántos ciclos de reloj tarda una instrucción.
4. Construir el **mapa de memoria** del SoC leyendo su código.
5. Seguir el camino de una línea de C hasta la FPGA: compilador, código máquina, `firmware.hex`, memoria del SoC.
6. Diseñar un **periférico mapeado en memoria**, probarlo con un testbench y controlarlo desde C.
7. **Predecir y medir** el tiempo que tarda una tarea hecha por software.

## Qué hay en esta carpeta

```
lab-femtorv/
├── README.md               ← esta guía
├── Semana1.md              ← tareas de la semana 1, paso a paso
├── Semana2.md              ← tareas de la semana 2, paso a paso
├── Tarjetas.md             ← Colorlight 5A-75E y Tang Nano 9K: conexiones y diferencias
├── Errores_frecuentes.md   ← síntomas, causas y soluciones
├── Fundamentos/
│   ├── 01_RISC-V_y_FemtoRV.md     ← qué es un procesador y cómo funciona el FemtoRV
│   ├── 02_Bus_y_perifericos.md    ← cómo habla el procesador con la memoria y los periféricos
│   └── 03_De_C_a_la_FPGA.md       ← cómo un programa en C llega a ejecutarse en la FPGA
├── blinker/                ← Semana 1, paso 0: un "procesador" sin decodificador
│   ├── rtl/blinker.v
│   ├── sim/tb_blinker.v
│   ├── boards/             ← un top y un archivo de pines por tarjeta
│   └── Makefile
├── soc/                    ← el SoC con el FemtoRV (semanas 1 y 2)
│   ├── rtl/                ← Verilog: SOC.v, chip_select.v, cpu/, memory/, uart/, mult/
│   ├── sim/tb_soc.v        ← testbench: ejecuta el programa y muestra lo que envía la UART
│   ├── firmware/           ← programas en C: soc.h, hola.c, gpio.c, parpadeo.c
│   ├── boards/             ← top y pines de cada tarjeta
│   └── Makefile
└── plantillas/             ← Semana 2: plantillas del periférico y de su testbench
```

## Plan de las dos semanas

Cada semana empieza con una **charla de 30 minutos**; el resto del tiempo es trabajo del grupo con esta guía.

| | Charla (30 min) | Trabajo del grupo | Entrega |
|---|---|---|---|
| **Semana 1** | *Del contador al procesador*: qué es RISC-V, cómo funciona el FemtoRV, E/S mapeada en memoria | [Semana1.md](Semana1.md): blinker desde memoria, primer programa en C, mapa de memoria, lectura del procesador y del listado | **Punto de control** al inicio de la semana 2 (5 min por grupo) |
| **Semana 2** | *Del procesador al periférico*: el bus, anatomía de un periférico, cómo se prueba | [Semana2.md](Semana2.md): periférico GPIO, testbench, programa en C, tarjeta, experimento de tiempo | **Bitácora, repositorio y sustentación** al inicio de la sesión siguiente |

**Punto de control de la semana 1.** Cada grupo muestra en su computador: (1) la simulación del SoC imprimiendo su mensaje, (2) su mapa de memoria completo y (3) responde una pregunta sobre una dirección del mapa. Sirve para detectar a tiempo problemas de instalación.

## Antes de empezar

1. **Activen el entorno de herramientas del curso** en cada terminal nueva:
   ```bash
   source digital-logic-design activate
   ```
2. **Verifiquen que todas las herramientas responden.** Cada línea debe mostrar una versión, no un error:
   ```bash
   riscv64-unknown-elf-gcc --version   # compilador de C para RISC-V
   iverilog -V                         # simulador de Verilog
   yosys -V                            # síntesis
   nextpnr-ecp5 --version              # place & route, Colorlight
   nextpnr-himbaechel --version        # place & route, Tang Nano 9K
   openFPGALoader --version            # configuración de la FPGA
   python3 --version
   ```
   Si falta `riscv64-unknown-elf-gcc`, instálenlo con `sudo apt install gcc-riscv64-unknown-elf`.
3. **Sepan qué tarjeta tienen** y lean [Tarjetas.md](Tarjetas.md). Las dos funcionan con los mismos archivos; solo cambia `BOARD=colorlight` o `BOARD=tangnano9k` en los comandos.
4. **Lean los Fundamentos** en orden antes de cada semana (ver abajo). Las charlas los resumen; la guía supone que los leyeron.

## Inicio rápido

Desde la carpeta `soc/`:

```bash
make sim                          # compila hola.c y simula el SoC (unos 3 segundos)
make syn BOARD=colorlight         # o BOARD=tangnano9k: genera el archivo de configuración
make config BOARD=colorlight      # configura la FPGA
make terminal BOARD=colorlight    # muestra lo que el programa envía (salir: Ctrl-a Ctrl-x)
```

La salida de `make sim` debe terminar así:

```
=== Simulacion del SoC: salida de la UART ===
Hola desde el FemtoRV
Por software (sumas repetidas): 5535
Por hardware (periferico MULT): 5535
Fin. El programa queda en un bucle infinito.
```

Si no es así, vayan a [Errores_frecuentes.md](Errores_frecuentes.md) **antes** de seguir.

## Fundamentos

Lectura obligatoria. Están escritos para alguien que **nunca ha visto un procesador por dentro**.

| Documento | Qué explica | Antes de |
|---|---|---|
| [01 · RISC-V y FemtoRV](Fundamentos/01_RISC-V_y_FemtoRV.md) | Conjunto de instrucciones, registros, tipos de instrucción, ciclo buscar-decodificar-ejecutar, las 5 partes del FemtoRV, ciclos por instrucción | Semana 1 |
| [02 · Bus y periféricos](Fundamentos/02_Bus_y_perifericos.md) | Señales del bus, escritura y lectura ciclo a ciclo, decodificador de direcciones, mapa de memoria, anatomía de un periférico | Semana 1 (secciones 1 a 4) y Semana 2 (todo) |
| [03 · De C a la FPGA](Fundamentos/03_De_C_a_la_FPGA.md) | Compilador cruzado, `crt0.S`, `linker.ld`, `firmware.hex`, `volatile`, cómo leer `firmware.lst` | Semana 1 |

## Entregables

| Entregable | Contenido |
|---|---|
| **Bitácora grupal** | Las respuestas y tablas de [Semana1.md](Semana1.md) y [Semana2.md](Semana2.md): predicciones, mapa de memoria, tabla de registros, capturas de simulación comentadas, experimento con predicción, medición y análisis. Sigue el formato de bitácora del curso. |
| **Repositorio en GitHub Classroom** | La carpeta `soc/` con su `perip_gpio.v`, su testbench, el `SOC.v` modificado, sus programas en C y un README corto. Commits que muestren el proceso. |
| **Sustentación** | Demostración en la tarjeta y un **cambio en vivo** (ver Evaluación). |

## Evaluación

| Criterio | Qué se revisa |
|---|---|
| **Habilitantes** | Asistencia, punto de control de la semana 1 aprobado, commits realizados y justificados |
| **Comprensión del procesador** | Predicción del blinker, ubicación de las 5 partes del FemtoRV, cálculo de ciclos por instrucción |
| **Comprensión del SoC** | Mapa de memoria correcto y explicado; lectura de `firmware.lst` (de una línea de C a una instrucción `sw`) |
| **Periférico** | Tabla de registros completa; Verilog sintetizable y trazable a la tabla; testbench que comprueba cada registro |
| **Software** | Programa en C funcional en simulación y en la tarjeta |
| **Experimento** | Predicción razonada, medición con instrumento y explicación de la diferencia |
| **Sustentación** | Preguntas sobre su diseño y un **cambio en vivo**, por ejemplo: mover el periférico a otra dirección (`0x0043_0000`), agregar un registro, o cambiar el patrón de LEDs. El grupo debe hacerlo y explicarlo en la sesión. |
| **Valor agregado** | Integrar como periférico mapeado en memoria el controlador del laboratorio anterior (servo, tonos, ultrasonido…) y manejarlo desde C |

## Relación con la consola

| En este laboratorio | En la consola |
|---|---|
| Mapa de memoria del SoC | Mapa de memoria MMIO de la consola |
| Periférico GPIO con su tabla de registros | Periférico asignado a cada grupo (pantalla, mando, audio…) con sus registros de control y datos |
| Programa en C que lee pulsadores por *polling* | Rutinas en C de cada tarea y su política de sincronización |
| Experimento de tiempo por software | Decisión de qué va en hardware y qué en software |
| Uso de memoria de bloque (BRAM) en la síntesis | Presupuesto de memoria de la FPGA (imágenes, sonidos, programa) |

## Diferencias con el ejemplo del repositorio

El SoC parte del ejemplo `fpga-example/colorlight-5a-75e/femtoriscv` del [repositorio del curso](https://github.com/johnnycubides/digital-electronic-1-101). El procesador, la UART y el multiplicador son los mismos archivos. Se hicieron estos cambios para que el laboratorio funcione igual en las dos tarjetas y sea más fácil de depurar:

- `SOC.v`: la frecuencia del reloj y la velocidad de la UART son **parámetros** (cada tarjeta fija los suyos), y tiene puertos para pulsadores y LEDs externos.
- `chip_select.v`: se corrigieron los **comentarios**, que no coincidían con las conexiones de `SOC.v`. El código es el mismo.
- `Memory.v`: el tamaño es exactamente 8192 palabras (32 KB), igual al de `linker.ld`.
- **Firmware**: se compila con `gcc` como enlazador, así que la división (`/`, `%`) funciona; `soc.h` reúne las direcciones de todos los periféricos.
- **Simulación**: el testbench decodifica la UART, así que el mismo programa se ve igual en simulación y en la tarjeta, y la simulación tarda segundos en vez de minutos.
- **Un solo `Makefile`** para las dos tarjetas.

## Referencias

- Repositorio del curso: [johnnycubides/digital-electronic-1-101](https://github.com/johnnycubides/digital-electronic-1-101) (SoC FemtoRV y pasos "From Blinker to RISC-V").
- B. Levy, *From Blinker to RISC-V* (tutorial del autor del FemtoRV): [learn-fpga](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV).
- D. Harris y S. Harris, *Digital Design and Computer Architecture: RISC-V Edition*, Morgan Kaufmann, 2021. Capítulos 6 (arquitectura) y 7 (microarquitectura).
- *The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA*, capítulo 2 (RV32I).
- Ejemplos oficiales de la Tang Nano 9K: [sipeed/TangNano-9K-example](https://github.com/sipeed/TangNano-9K-example).
