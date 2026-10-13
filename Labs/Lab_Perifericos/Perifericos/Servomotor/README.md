# Servomotor SG90

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md) · [Ejemplo resuelto](../../Fundamentos/12_Ejemplo_resuelto.md)

**Enunciado:** controlar la posición del servomotor a través de pulsadores.

---

## 1. Alcance base

- Varios pulsadores llevan el servo a posiciones fijas **mientras se mantienen presionados**.
- Sin pulsador presionado, el servo va a una posición de reposo definida por el grupo.
- El comportamiento con varios pulsadores a la vez está definido y documentado.

| Parámetro | Valor base | Valor asignado a su grupo |
|---|---|---|
| Número de posiciones | 3 | |
| Ángulos de las posiciones | 0°, 90°, 180° | |
| Posición de reposo | 90° | |

El profesor puede asignar valores distintos a cada grupo.

## 2. Qué deben investigar

Busquen en la **hoja de datos del SG90** y en los libros de [Dónde buscar](../../Fundamentos/01_Metodologia.md#10-dónde-buscar) (temas: servomotores, PWM, generación de pulsos con contadores):

- ¿Cómo funciona un servomotor por dentro? ¿Por qué se dice que es un sistema en lazo cerrado?
- ¿Qué señal de control espera? ¿Cuál es su **periodo** y qué **anchos de pulso** corresponden a cada posición? ¿Qué tolerancias da el fabricante?
- ¿Es una PWM de potencia o de referencia? ([Señales periódicas y PWM](../../Fundamentos/06_Senales_periodicas_PWM.md))
- ¿Por qué muchos servos reales no recorren exactamente los ángulos nominales y cómo se calibra?

## 3. Preguntas guía por etapa

| Etapa | Preguntas |
|---|---|
| 2. Variables | ¿Qué entradas y salidas tiene el sistema? ¿Qué variables deben recordarse entre ciclos de reloj? ¿Cuál es el ancho en bits de cada una? ¿Cuántos flip-flops predicen? |
| 3. Cuentas | ¿Cuántos ciclos de reloj dura el periodo y cada ancho de pulso con su `CLK_FREQ`? ¿Cuántos bits necesita el contador? |
| 4. Caja negra | ¿Qué puertos tiene el módulo top? ¿Qué especificaciones medibles debe cumplir (periodo, anchos, reposo, prioridad)? |
| 5. Diagrama de flujo | ¿Cómo se pasa de "qué pulsador está presionado" a "qué ancho de pulso"? ¿Qué pasa sin pulsadores? ¿Y con dos? |
| 6. Verilog | ¿Qué partes son combinacionales y cuáles secuenciales? ¿Qué bloques clásicos usaron ([Bloques combinacionales](../../Fundamentos/05_Bloques_combinacionales.md))? |
| 7. RTL | ¿Coinciden los flip-flops y bloques con su predicción? ¿Qué celda corresponde a cada bloque de su diseño? |

## 4. Conexión y seguridad

- El servo se alimenta con una **fuente externa de 5 V**, nunca desde la tarjeta.
- **GND común** entre la fuente externa y la FPGA.
- La señal de control va directamente desde un pin de la FPGA al cable de señal del servo (identifiquen los colores en la hoja de datos).

Ver [Conexión eléctrica](../../Fundamentos/11_Conexion_electrica.md).

## 5. Qué deben verificar

- **Simulación:** el periodo y el ancho del pulso para cada pulsador, para el reposo y para la combinación de pulsadores, todo medido automáticamente en el testbench.
- **Tarjeta:** la señal medida con osciloscopio o analizador lógico; el servo en cada posición; la calibración realizada, si fue necesaria.

## 6. Experimentos de síntesis

Además de los cinco [experimentos obligatorios](../../Fundamentos/10_Herramientas_de_sintesis.md#5-experimentos-de-síntesis), una idea específica para S2: comparen la selección del ancho con un `case` de constantes frente a una fórmula (posición × paso + mínimo). ¿Qué cambia en el RTL y en los recursos?

## 7. Mejoras opcionales

- Más posiciones.
- Que la posición **se mantenga** al soltar y cada pulsación avance un paso (requiere debounce, detector de flanco y un registro).
- Movimiento suave: la posición real se acerca a la deseada poco a poco.

---

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md)
