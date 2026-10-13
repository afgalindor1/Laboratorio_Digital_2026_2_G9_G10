# Puente H con PWM

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md) · [Ejemplo resuelto](../../Fundamentos/12_Ejemplo_resuelto.md)

**Enunciado:** controlar el sentido de giro de un motor y su velocidad a través de pulsadores.

---

## 1. Alcance base

- El motor gira en ambos sentidos, elegidos por el usuario.
- Hay varias velocidades, elegidas con pulsadores **mientras se mantienen presionados**; sin pulsador, el motor se detiene.
- El comportamiento con varios pulsadores a la vez está definido y documentado.

| Parámetro | Valor base | Valor asignado a su grupo |
|---|---|---|
| Número de velocidades | 3 | |
| Ciclos de trabajo | 40 %, 70 %, 100 % | |
| Frecuencia de la PWM | elegida y justificada por el grupo | |

## 2. Qué deben investigar

Busquen en la **hoja de datos del L298N** (o del driver que usen), en la documentación del módulo y en los libros (temas: puente H, PWM, control de motores DC):

- ¿Qué es un puente H y cómo invierte el sentido de giro?
- ¿Qué hacen las entradas de control del módulo (IN1, IN2, ENA)? Construyan su tabla de verdad a partir de la hoja de datos, incluido el frenado.
- ¿Por qué una PWM controla la velocidad? ¿Qué frecuencia conviene y qué pasa si es muy baja?
- ¿Qué caída de voltaje introduce el driver? ¿Por qué un motor no arranca con ciclos de trabajo pequeños?
- ¿Qué riesgos tiene invertir el sentido con el motor a toda velocidad?

## 3. Preguntas guía por etapa

| Etapa | Preguntas |
|---|---|
| 2. Variables | ¿Qué variables deben recordarse? ¿El sentido se recuerda o se lee directamente de una entrada? ¿Cuántos flip-flops predicen? |
| 3. Cuentas | ¿Cuántos ciclos dura el periodo de la PWM con su frecuencia elegida? ¿Cuántos ciclos en alto para cada velocidad? |
| 4. Caja negra | ¿Qué puertos tiene el módulo? ¿Qué especificaciones medibles definen? |
| 5. Diagrama de flujo | ¿Qué pasa sin pulsadores? ¿Con dos? ¿Cómo se maneja el cambio de sentido de forma segura? |
| 6. Verilog | ¿Qué bloques clásicos componen su diseño? |
| 7. RTL | ¿Coincide el RTL con su predicción? ¿Dónde está el comparador que genera la PWM? |

## 4. Conexión y seguridad

- **El jumper de ENA.** En el módulo L298N, junto a IN1 e IN2 hay dos pines marcados ENA unidos por un jumper. Uno es la entrada de habilitación (ENA); el otro es **+5 V del módulo**. Con el jumper puesto, el puente está siempre habilitado. Para controlar la velocidad con PWM hay que **retirar el jumper** y conectar la salida de la FPGA al pin **ENA**, nunca al de +5 V. Identifiquen cuál es cuál con el multímetro (con el módulo alimentado y sin jumper, el pin de +5 V marca 5 V respecto a GND) y regístrenlo en la bitácora.
- El motor se alimenta con una **fuente externa** adecuada a su voltaje.
- **GND común** entre la fuente, el módulo y la FPGA.

Ver [Conexión eléctrica](../../Fundamentos/11_Conexion_electrica.md).

## 5. Qué deben verificar

- **Simulación:** el periodo y el ciclo de trabajo de cada velocidad; las señales de sentido; el comportamiento sin pulsadores y con varios.
- **Tarjeta:** la señal de habilitación medida con osciloscopio; el motor en ambos sentidos y a cada velocidad; el ciclo de trabajo mínimo con el que el motor arranca.

## 6. Experimentos de síntesis

Además de los cinco [experimentos obligatorios](../../Fundamentos/10_Herramientas_de_sintesis.md#5-experimentos-de-síntesis), para S4: cambien la frecuencia de la PWM (por ejemplo de 1 kHz a 20 kHz). ¿Cuántos bits cambia el contador y cómo cambian los recursos?

## 7. Mejoras opcionales

- Botón de freno.
- Parada automática antes de invertir el sentido.
- Rampa de aceleración.

---

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md)
