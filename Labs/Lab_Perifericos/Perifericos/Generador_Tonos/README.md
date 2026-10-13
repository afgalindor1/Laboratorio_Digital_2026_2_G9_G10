# Generador de tonos

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md) · [Ejemplo resuelto](../../Fundamentos/12_Ejemplo_resuelto.md)

**Enunciado:** enviar a un parlante diferentes tonos audibles, seleccionando el tono a través de pulsadores.

---

## 1. Alcance base

- Cada pulsador produce una nota musical **mientras se mantiene presionado**, como un piano.
- Sin pulsador, silencio.
- El comportamiento con varios pulsadores a la vez está definido y documentado.

| Parámetro | Valor base | Valor asignado a su grupo |
|---|---|---|
| Número de notas | 4 | |
| Notas | Do4, Re4, Mi4, Fa4 | |

## 2. Qué deben investigar

Busquen en libros de física, de diseño digital y en las hojas de datos de los componentes (temas: sonido, escala musical temperada, ondas cuadradas, divisores de frecuencia):

- ¿Qué relación hay entre la frecuencia de una onda y la altura del sonido? ¿Qué rango percibe el oído y qué rango reproduce bien un parlante pequeño?
- ¿Qué frecuencia tiene cada nota de la escala temperada? (Punto de partida: La4 = 440 Hz.) ¿Qué relación hay entre una nota y la misma nota una octava más arriba?
- ¿Cómo se genera una onda cuadrada de frecuencia elegida con un contador? ([Señales periódicas y PWM](../../Fundamentos/06_Senales_periodicas_PWM.md))
- ¿Qué diferencia hay entre un **buzzer activo** y uno **pasivo**? ¿Cuál sirve aquí?
- ¿Por qué un parlante no se puede conectar directamente a un pin de la FPGA? ¿Cómo se usa un transistor como interruptor para manejarlo?

## 3. Preguntas guía por etapa

| Etapa | Preguntas |
|---|---|
| 2. Variables | ¿Qué variables deben recordarse? ¿Cuántos flip-flops predicen? |
| 3. Cuentas | ¿Cuántos ciclos de reloj dura el periodo de cada nota? ¿Qué error introduce redondear a un número entero de ciclos? ¿Qué nota define el ancho del contador? |
| 4. Caja negra | ¿Qué puertos tiene el módulo? ¿Qué especificaciones medibles definen (frecuencia de cada nota con su tolerancia, silencio, prioridad)? |
| 5. Diagrama de flujo | ¿Qué pasa al cambiar de nota a mitad de un periodo? ¿Y sin pulsadores? |
| 6. Verilog | ¿Cómo llega la elección del pulsador hasta el contador? |
| 7. RTL | ¿Coincide el RTL con su predicción? |

## 4. Conexión y seguridad

- Nunca conecten un parlante de 8 Ω directamente a un pin de la FPGA: usen un **transistor** con resistencia de base. Diseñen el circuito (valores de resistencias, diodo de protección) y justifíquenlo en la bitácora.
- **GND común** entre el circuito del parlante y la FPGA.

Ver [Conexión eléctrica](../../Fundamentos/11_Conexion_electrica.md).

## 5. Qué deben verificar

- **Simulación:** el periodo medido de cada nota frente al calculado; el silencio; la prioridad.
- **Tarjeta:** la frecuencia de cada nota medida con osciloscopio o con una aplicación de afinador; comparación con la frecuencia teórica.

## 6. Experimentos de síntesis

Además de los cinco [experimentos obligatorios](../../Fundamentos/10_Herramientas_de_sintesis.md#5-experimentos-de-síntesis), para S2: comparen el reinicio del contador con `==` y con `>=`. ¿Qué cambia en el RTL? ¿Qué cambia en la simulación al pasar de una nota grave a una aguda?

## 7. Mejoras opcionales

- Un interruptor de octava.
- Más notas.
- Una melodía que se reproduzca sola.

---

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md)
