# Tarjetas: Colorlight 5A-75E y Tang Nano 9K

[← Volver a la guía](README.md)

Todo el laboratorio funciona con las dos tarjetas usando los **mismos archivos**. En los comandos solo cambia `BOARD=colorlight` o `BOARD=tangnano9k`. Los archivos propios de cada tarjeta están en `blinker/boards/` y `soc/boards/`, y **no hace falta modificarlos**.

---

## Comparación

| | Colorlight 5A-75E (v8.2) | Tang Nano 9K |
|---|---|---|
| FPGA | Lattice ECP5 LFE5U-25F | Gowin GW1NR-9 |
| Reloj | **25 MHz** | **27 MHz** |
| Configuración | Adaptador **FT232RL** como JTAG | Cable **USB-C** (chip BL702) |
| UART con el PC | **Segundo** adaptador USB-serial (o el ESP32 del ejemplo del repositorio) | El **mismo** cable USB-C |
| Alimentación | **Fuente externa de 5 V** (recomendada) | Por el USB-C |
| Reset | Botón de la tarjeta | Botón S1 |
| Pulsadores | Externos en el conector J1 (2) | Botón S2 de la tarjeta (1) |
| LEDs | Externos en el conector J2 (6) | 6 LEDs de la tarjeta, **activos en bajo** |
| Archivo de pines | `.lpf` | `.cst` |
| Herramientas | Yosys → nextpnr-ecp5 → ecppack | Yosys → nextpnr-himbaechel → gowin_pack |
| Recursos que usa el SoC | ~1700 LUT (7 %), 16 de 56 BRAM (28 %) | ~2000 LUT (23 %), 16 de 26 BSRAM (61 %) |

> **Por qué los tops son distintos:** cada tarjeta tiene otro reloj y otra lógica en sus pines. El archivo `top_<tarjeta>.v` adapta la tarjeta al SoC: le dice al SoC su frecuencia (para que la UART calcule bien la velocidad) e invierte las señales activas en bajo, de modo que **dentro del SoC siempre 1 = presionado y 1 = encendido**. Así el periférico y el programa en C son iguales en las dos tarjetas.

---

## Colorlight 5A-75E

El pinout completo está en el repositorio del curso: `fpga-example/colorlight-5a-75e/femtoriscv/docs/colorlight-5a-75e-v8.2.drawio.pdf`. Si su tarjeta es la **v7.1**, los pines cambian: revisen el pinout de esa versión y ajusten los `.lpf`.

### Conexiones

| Qué | Pin de la FPGA | Conector | Cómo se conecta |
|---|---|---|---|
| UART TX (FPGA → PC) | C4 | J1 | al **RX** del adaptador USB-serial |
| UART RX (PC → FPGA) | D4 | J1 | al **TX** del adaptador USB-serial |
| Pulsador 0 | E4 | J1 | pulsador entre el pin y **GND** |
| Pulsador 1 | D3 | J1 | pulsador entre el pin y **GND** |
| LED 0 a LED 5 | F3, F5, G3, G4, H3, H4 | J2 | pin → resistencia de 330 Ω → ánodo del LED; cátodo a **GND** |
| JTAG | J27, J30, J31, J32 | JTAG | adaptador FT232RL, igual que en los laboratorios anteriores |

Reglas importantes:

- **J1 es el único conector que sirve como entrada.** J2 a J16 son solo salidas (pasan por un circuito de manejo). Por eso los pulsadores van en J1.
- Los pulsadores no necesitan resistencia externa: el pin tiene **pull-up interna** (`PULLMODE=UP`). Sin presionar, el pin lee 1; al presionar, 0; el top lo invierte.
- **GND común** entre la tarjeta, el adaptador de la UART y el FT232RL.
- Los pines de la FPGA trabajan a **3,3 V**. No conecten 5 V a ningún pin.
- Alimenten la tarjeta con una fuente externa de 5 V: el FT232RL no da corriente suficiente.

### Comandos

```bash
make syn BOARD=colorlight
make config BOARD=colorlight          # volátil: se pierde al apagar
make config-flash BOARD=colorlight    # permanente
make terminal BOARD=colorlight PORT=/dev/ttyUSB1   # el puerto del adaptador de la UART
```

`make config` usa por defecto la misma asignación de pines del FT232RL que el repositorio del curso (TDI–TXD, TDO–CTS, TCK–DTR, TMS–RXD). Si su cableado es otro: `make config CABLE_PINES=TDI:TDO:TCK:TMS` con los números de los pines del FT232RL.

Con dos adaptadores conectados aparecen dos puertos (`/dev/ttyUSB0` y `/dev/ttyUSB1`). Para saber cuál es cuál: `ls /dev/ttyUSB*` antes y después de conectar el adaptador de la UART.

---

## Tang Nano 9K

### Conexiones

Solo hace falta el cable **USB-C**. Por ese cable pasan la configuración de la FPGA y la UART.

| Qué | Pin de la FPGA | Dónde |
|---|---|---|
| Reloj de 27 MHz | 52 | en la tarjeta |
| Reset | 4 | botón **S1** |
| Pulsador 0 (`BOTONES[0]`) | 3 | botón **S2** |
| LED 0 a LED 5 | 10, 11, 13, 14, 15, 16 | LEDs de la tarjeta (**0 = encendido**) |
| UART TX / RX | 17 / 18 | conectados al chip USB de la tarjeta |

Al conectar la tarjeta aparecen **dos** puertos: el primero (`/dev/ttyUSB0`) es para configurar; el segundo (`/dev/ttyUSB1`) es la UART. El `Makefile` ya usa `/dev/ttyUSB1` para `make terminal`.

### Comandos

```bash
make syn BOARD=tangnano9k
make config BOARD=tangnano9k          # volátil
make config-flash BOARD=tangnano9k    # permanente
make terminal BOARD=tangnano9k
```

### Lo que se comprobó en la tarjeta

Probado con una Tang Nano 9K real: `hola.c` corre en la tarjeta y su mensaje aparece en `make terminal` al presionar S1.

- **S1 (pin 4) es el reset** y **S2 (pin 3) es el pulsador de usuario**, como dice la tabla (se comprobó encendiendo un LED con cada botón).
- **La UART va a 115200 baudios.** A 9600 baudios la FPGA transmitía (se comprobó con un LED conectado a TX), pero el chip USB de la tarjeta no entregaba nada al PC. El ejemplo oficial de Sipeed también usa 115200.
- `make syn` tarda varios minutos y muestra avisos de Python (`Numpy is not available…`): son normales y no afectan el resultado.

### Cuidado con la frecuencia

`soc/boards/tangnano9k/top_tangnano9k.v` le pasa al SoC `CLK_FREQ = 27_000_000`. Si se deja en 25 MHz (el valor de la Colorlight), la UART calcula mal su velocidad: el error es de casi el 8 % y en la terminal aparecen **caracteres sin sentido**.

### Solo hay un pulsador de usuario

S1 se usa como reset, así que solo queda S2 para `BOTONES[0]`. `BOTONES[1]` vale siempre 0. Para probar el patrón del segundo pulsador pueden usar la simulación (`ARGS="+botones=2"`), o agregar un pulsador externo con el procedimiento de la siguiente sección.

### Medir una señal o agregar un pin

Los LEDs están soldados en la tarjeta. Para medir con el osciloscopio (Semana 2, tarea 7) hay dos opciones:

**Opción A (recomendada): sacar la señal a un pin del conector.**

1. Busquen en el **pinout oficial** de la Tang Nano 9K ([wiki de Sipeed](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)) un pin del conector que **no** use la tarjeta (ni LEDs, ni botones, ni la UART, ni la memoria flash) y que esté en un banco de **3,3 V**.
2. En `soc/boards/tangnano9k/top_tangnano9k.v`, agreguen una salida y conéctenla al LED 0:
   ```verilog
   output prueba,          // en la lista de puertos
   ...
   assign prueba = leds_soc[0];
   ```
3. En `soc/boards/tangnano9k/tangnano9k.cst`, agreguen (cambien `NN` por el número de pin que eligieron):
   ```
   IO_LOC "prueba" NN;
   IO_PORT "prueba" IO_TYPE=LVCMOS33;
   ```
4. `make syn` mostrará un error si el pin no existe o está en un banco de otro voltaje.

**Opción B:** medir con cuidado en la resistencia del LED 0 (el lado que va al pin 10 de la FPGA). Recuerden que el LED es activo en bajo: la señal en el pin es la **inversa** de `LEDS_EXT[0]`.

---

## Permisos en Linux

Si `make config` o `make terminal` dicen *permission denied* o *unable to open device*:

```bash
sudo usermod -aG dialout $USER     # acceso a los puertos serie; luego cierren sesión y vuelvan a entrar
```

El error típico de `make terminal` es `FATAL: cannot open /dev/ttyUSB1: Permission denied`. El cambio de grupo solo vale después de cerrar sesión y volver a entrar; para probar de inmediato, `sudo chmod a+rw /dev/ttyUSB1` da permiso hasta que se desconecte la tarjeta.

y ejecuten el script de permisos del repositorio del curso: `installTools/hw-permissions.sh`.

[← Volver a la guía](README.md)
