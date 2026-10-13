# 11. Conexión eléctrica de los periféricos

[← Herramientas de síntesis](10_Herramientas_de_sintesis.md) · [Fundamentos](README.md) · [Siguiente: Ejemplo resuelto →](12_Ejemplo_resuelto.md)

La FPGA trabaja a **3.3 V** y cada pin entrega muy poca corriente. Su salida es una **señal de control**: nunca la alimentación de un motor, un servo o un parlante. La mayoría de los daños en el laboratorio ocurren por olvidar esto.

---

## Contenido

1. [Reglas de conexión](#1-reglas-de-conexión)
2. [Señales de 5 V hacia la FPGA: divisor de voltaje](#2-señales-de-5-v-hacia-la-fpga-divisor-de-voltaje)
3. [Cómo se conecta cada periférico](#3-cómo-se-conecta-cada-periférico)
4. [Tabla de conexiones para la bitácora](#4-tabla-de-conexiones-para-la-bitácora)
5. [Antes de energizar](#5-antes-de-energizar)

---

## 1. Reglas de conexión

| Regla | Por qué |
|---|---|
| **Nunca aplicar 5 V a un pin de la FPGA** | Los pines soportan 3.3 V; 5 V pueden dañarlos de forma permanente |
| **Fuente externa para las cargas** | Un motor o un servo consume cientos de mA; la tarjeta no está hecha para entregarlos |
| **GND común obligatorio** | La señal de control se mide respecto a una tierra; si la FPGA y la fuente externa no comparten GND, la señal no tiene referencia y el periférico se comporta de forma errática |
| **Resistencia en serie con cada LED externo** (220 Ω a 330 Ω) | Limita la corriente que sale del pin |
| **Señales de 3.3 V hacia módulos de 5 V** | Normalmente funcionan (servo, L298N, ULN2003, trigger del HC-SR04 reconocen 3.3 V como 1), pero verifiquen el umbral de entrada en la hoja de datos |
| **Capacitor en la alimentación de los motores** (por ejemplo 100 µF en paralelo con 100 nF) | Reduce el ruido eléctrico que generan los motores |
| **Cables cortos** | Menos ruido y menos falsos contactos |

## 2. Señales de 5 V hacia la FPGA: divisor de voltaje

Algunos periféricos entregan señales de 5 V, como el pin `Echo` del sensor de ultrasonido HC-SR04. Antes de llegar a la FPGA deben pasar por un **divisor de voltaje**:

```
 Echo (5 V) ───[ R1 = 1 kΩ ]───┬──── pin de la FPGA (≈ 3.3 V)
                               │
                          [ R2 = 2 kΩ ]
                               │
                              GND
```

$$V_{out} = V_{in} \cdot \frac{R_2}{R_1 + R_2} = 5\ \text{V} \cdot \frac{2\ \text{k}\Omega}{1\ \text{k}\Omega + 2\ \text{k}\Omega} \approx 3.3\ \text{V}$$

Si no tienen una resistencia de 2 kΩ, dos de 1 kΩ en serie cumplen la misma función.

## 3. Cómo se conecta cada periférico

| Periférico | Alimentación | Desde la FPGA | Hacia la FPGA | Atención |
|---|---|---|---|---|
| Servomotor SG90 | 5 V externa | Señal PWM (cable naranja o amarillo) | — | GND común |
| Puente H (L298N o similar) | Fuente del motor, según su voltaje | IN1, IN2, ENA | — | Retirar el jumper de ENA para usar PWM |
| Motor paso a paso (28BYJ-48 + ULN2003) | 5 V externa | IN1 a IN4 | — | GND común |
| Sensor de ultrasonido HC-SR04 | 5 V | Trig | Echo, **con divisor de voltaje** | Echo es de 5 V |
| Parlante o buzzer pasivo | 5 V | Señal, **a través de un transistor** | — | Nunca un parlante directo al pin |
| Displays de 7 segmentos | 3.3 V | Segmentos y comunes | — | Una resistencia por segmento y un transistor por común |

Los detalles de cada uno están en su ficha: [Perifericos](../Perifericos/).

## 4. Tabla de conexiones para la bitácora

En la etapa de implementación, incluyan una tabla como esta, que debe coincidir con su archivo de restricciones:

| Señal del top | Dirección | Pin de la FPGA | Conector y pin físico | Conectado a |
|---|---|---|---|---|
| `clk` | Entrada | | | Oscilador de la tarjeta |
| `rst_n` | Entrada | | | Pulsador de reset |
| `btn_n[0]` | Entrada | | | Pulsador 1 |
| `servo_pwm` | Salida | | | Cable de señal del servo |
| GND | — | | | GND de la fuente externa |

Acompáñenla de un esquema o una foto del montaje donde se vean la fuente externa y la tierra común.

## 5. Antes de energizar

- [ ] Todas las conexiones se hicieron con las fuentes **apagadas**.
- [ ] La polaridad de cada fuente está revisada (rojo a positivo, negro a GND).
- [ ] Ningún pin de la FPGA recibe más de 3.3 V.
- [ ] La fuente externa y la FPGA comparten GND.
- [ ] Los motores, el servo y el parlante **no** se alimentan desde la tarjeta.

---

[← Herramientas de síntesis](10_Herramientas_de_sintesis.md) · [Fundamentos](README.md) · [Siguiente: Ejemplo resuelto →](12_Ejemplo_resuelto.md)
