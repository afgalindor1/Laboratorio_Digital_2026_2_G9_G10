# Motor paso a paso

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md) · [Ejemplo resuelto](../../Fundamentos/12_Ejemplo_resuelto.md)

**Enunciado:** controlar el giro de un motor paso a paso a través de pulsadores.

---

## 1. Alcance base

- El motor gira en un sentido u otro **mientras se mantiene presionado** el pulsador correspondiente.
- Sin pulsador, el motor se detiene.
- El comportamiento con ambos pulsadores a la vez está definido y documentado.

| Parámetro | Valor base | Valor asignado a su grupo |
|---|---|---|
| Modo de secuencia | Paso completo | |
| Tiempo por paso | definido por el grupo (medido) | |

## 2. Qué deben investigar

Busquen en las hojas de datos del **28BYJ-48** y del **ULN2003**, y en los libros (temas: motores paso a paso, secuencias de excitación, contadores y decodificadores):

- ¿Cómo funciona un motor paso a paso? ¿Por qué gira al energizar las bobinas en secuencia?
- ¿Qué secuencias de excitación existen (onda, paso completo, medio paso)? ¿Qué diferencias tienen en fuerza, consumo y resolución?
- ¿Cuántos pasos da el eje en una vuelta completa, considerando la reducción interna del 28BYJ-48?
- ¿Qué limita la velocidad máxima? ¿Qué pasa si los pasos son demasiado rápidos?
- ¿Para qué sirve el ULN2003 y qué hacen los LEDs del módulo?

## 3. Preguntas guía por etapa

| Etapa | Preguntas |
|---|---|
| 2. Variables | ¿Qué debe recordar el sistema para saber cuál es el siguiente paso? ¿Cuántos flip-flops predicen? |
| 3. Cuentas | ¿Cuántos ciclos de reloj dura un paso? ¿Qué velocidad en rpm resulta? |
| 4. Caja negra | ¿Qué puertos tiene el módulo? ¿Qué especificaciones medibles definen? |
| 5. Diagrama de flujo | ¿Cómo se recorre la secuencia en un sentido y en el otro? ¿Qué pasa con las bobinas al detenerse (y por qué)? |
| 6. Verilog | ¿La secuencia de fases es una tabla de verdad? ¿De qué entrada? |
| 7. RTL | ¿Cómo aparece la secuencia en el RTL? ¿Coincide con su predicción? |

## 4. Conexión y seguridad

- El módulo ULN2003 y el motor se alimentan con una **fuente externa de 5 V**.
- **GND común** entre la fuente y la FPGA.
- Las entradas del módulo se conectan directamente a pines de la FPGA; verifiquen en la hoja de datos que reconocen 3.3 V como nivel alto.

Ver [Conexión eléctrica](../../Fundamentos/11_Conexion_electrica.md).

## 5. Qué deben verificar

- **Simulación:** la secuencia completa en ambos sentidos; el tiempo entre pasos; el estado de las salidas sin pulsadores; el cambio de sentido sin saltarse fases.
- **Tarjeta:** la secuencia observada en los LEDs del módulo a baja velocidad; el giro en ambos sentidos; el tiempo mínimo por paso encontrado; una vuelta cronometrada frente a la calculada.

## 6. Experimentos de síntesis

Además de los cinco [experimentos obligatorios](../../Fundamentos/10_Herramientas_de_sintesis.md#5-experimentos-de-síntesis), para S2: generen la secuencia con un contador y un decodificador, y con un registro de desplazamiento circular. ¿Cuántos flip-flops y cuánta lógica usa cada versión?

## 7. Mejoras opcionales

- Medio paso, seleccionable.
- Girar un ángulo exacto con cada pulsación.
- Rampa de aceleración.

---

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md)
