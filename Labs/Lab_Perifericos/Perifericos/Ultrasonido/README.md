# Sensor de ultrasonido HC-SR04

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md) · [Ejemplo resuelto](../../Fundamentos/12_Ejemplo_resuelto.md)

**Enunciado:** mostrar por medio de LEDs la distancia a la que está un objeto.

---

## 1. Alcance base

- El sistema mide la distancia de forma periódica.
- La distancia se muestra en una barra de LEDs: más cerca, más LEDs (o al revés, según decida el grupo).
- Si no hay medición válida, los LEDs lo indican de una forma definida por el grupo.

| Parámetro | Valor base | Valor asignado a su grupo |
|---|---|---|
| Número de LEDs | 8 | |
| Distancia representada por cada LED | 5 cm | |
| Distancia máxima mostrada | 40 cm | |

## 2. Qué deben investigar

Busquen en la **hoja de datos del HC-SR04** y en los libros (temas: medición de tiempo con contadores, comparadores, código termómetro):

- ¿Cómo se inicia una medición? ¿Qué pulso hay que enviar por `Trig` y de qué duración mínima?
- ¿Qué entrega el sensor por `Echo` y cómo se relaciona su duración con la distancia? Deduzcan la fórmula a partir de la velocidad del sonido.
- ¿Cuánto tiempo debe pasar entre una medición y la siguiente? ¿Qué pasa si no hay objeto?
- ¿Con qué voltaje trabaja el sensor y qué voltaje entrega `Echo`? ¿Puede conectarse directamente a la FPGA?

## 3. Preguntas guía por etapa

| Etapa | Preguntas |
|---|---|
| 2. Variables | ¿Qué hay que recordar para medir la duración de un pulso? ¿Y para mostrar el resultado sin que los LEDs parpadeen mientras se mide? ¿Cuántos flip-flops predicen? |
| 3. Cuentas | ¿Cuántos ciclos duran el pulso de disparo y el ciclo de medición? ¿Pueden contar directamente en centímetros en lugar de dividir? ¿Cada cuántos ciclos debería avanzar ese contador? |
| 4. Caja negra | ¿Qué puertos tiene el módulo? ¿Qué especificaciones medibles definen (periodo de medición, resolución, umbrales, caso sin eco)? |
| 5. Diagrama de flujo | ¿Cómo se organiza el ciclo de medición en el tiempo? ¿Qué decide cada comparación? ¿Qué pasa si el eco nunca llega o dura demasiado? |
| 6. Verilog | ¿Qué parte es un contador, qué parte un comparador, qué parte un registro? |
| 7. RTL | ¿Cada registro del RTL corresponde a una variable de su tabla? |

## 4. Conexión y seguridad

- El pin **`Echo` entrega 5 V**: debe pasar por un **divisor de voltaje** antes de llegar a la FPGA. Calculen las resistencias y verifiquen el voltaje con el multímetro antes de conectarlo.
- `Echo` es una señal externa que habilita un contador: **debe sincronizarse** ([Entradas externas](../../Fundamentos/07_Entradas_externas.md)).
- **GND común** entre el sensor y la FPGA.

Ver [Conexión eléctrica](../../Fundamentos/11_Conexion_electrica.md).

## 5. Qué deben verificar

- **Simulación:** el testbench necesita un **modelo del sensor**: un bloque que, al terminar cada pulso de disparo, genere un eco de duración proporcional a una distancia elegida en el testbench. Escríbanlo ustedes y úsenlo para probar varias distancias, los umbrales y el caso sin eco.
- **Tarjeta:** mediciones comparadas con una regla en al menos tres distancias; `Trig` y `Echo` medidos con osciloscopio o analizador lógico.

## 6. Experimentos de síntesis

Además de los cinco [experimentos obligatorios](../../Fundamentos/10_Herramientas_de_sintesis.md#5-experimentos-de-síntesis): ¿cuántos comparadores genera la barra de LEDs? ¿Cambia algo si los umbrales se escriben como constantes o se calculan a partir de un parámetro?

## 7. Mejoras opcionales

- Mostrar la distancia en displays de 7 segmentos.
- Alarma sonora cuando el objeto está muy cerca.
- Promediar varias mediciones.

---

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md)
