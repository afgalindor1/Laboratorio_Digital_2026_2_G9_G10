# Reloj de segundos con 2 displays de 7 segmentos

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md) · [Ejemplo resuelto](../../Fundamentos/12_Ejemplo_resuelto.md)

**Enunciado:** construir un contador de segundos que se reinicie cada 60 segundos, mostrado en 2 displays de 7 segmentos.

---

## 1. Alcance base

- Dos displays muestran los segundos de 00 a 59; después vuelven a 00.
- El reset lleva la cuenta a 00.

| Parámetro | Valor base | Valor asignado a su grupo |
|---|---|---|
| Rango de la cuenta | 00 a 59 | |
| Sentido de la cuenta | Ascendente | |

## 2. Qué deben investigar

Busquen en los libros (temas: displays de 7 segmentos, decodificador BCD a 7 segmentos, contadores BCD y en cascada, multiplexación de displays) y en la hoja de datos de su display:

- ¿Cómo está construido un display de 7 segmentos? ¿Qué diferencia hay entre **cátodo común** y **ánodo común**? ¿Cuál tienen ustedes?
- ¿Qué es el código BCD y por qué conviene para mostrar números?
- ¿Cómo se encadenan contadores para contar en varios dígitos?
- Si los dos displays comparten las líneas de segmentos, ¿cómo se muestran dos dígitos distintos? ¿Qué es la **persistencia de la visión** y qué frecuencia de alternancia se necesita?
- ¿Por qué cada segmento lleva su propia resistencia? ¿Por qué el pin común suele necesitar un transistor?

## 3. Preguntas guía por etapa

| Etapa | Preguntas |
|---|---|
| 2. Variables | ¿Cuántos contadores necesitan y de cuántos bits? ¿Qué más hay que recordar? ¿Cuántos flip-flops predicen? |
| 3. Cuentas | ¿Cuántos ciclos de reloj tiene un segundo? ¿Cada cuántos ciclos debe alternar la multiplexación? |
| 4. Caja negra | ¿Qué puertos tiene el módulo? ¿Qué especificaciones medibles definen? |
| 5. Diagrama de flujo | ¿Qué pasa en 09 → 10? ¿Y en 59 → 00? ¿Cómo se decide qué display se enciende? |
| 6. Verilog | ¿Cuál es la tabla de verdad completa de su decodificador? ¿Qué bloques combinacionales usa la multiplexación? |
| 7. RTL | ¿Cómo aparece el decodificador en el RTL? ¿Coinciden los registros con su predicción? |

## 4. Conexión y seguridad

- Una **resistencia por segmento**, calculada para la corriente del LED y el voltaje de la FPGA.
- Un **transistor por pin común** si la corriente total supera lo que debe entregar un pin de la FPGA. Revisen si el transistor invierte la lógica.

Ver [Conexión eléctrica](../../Fundamentos/11_Conexion_electrica.md).

## 5. Qué deben verificar

- **Simulación:** las transiciones 09 → 10 y 59 → 00; los diez dígitos del decodificador contra su tabla de verdad; la alternancia de los displays. Elijan un `CLK_FREQ` reducido que permita simular un minuto completo.
- **Tarjeta:** ambos dígitos estables y sin parpadeo visible; un minuto cronometrado.

## 6. Experimentos de síntesis

Además de los cinco [experimentos obligatorios](../../Fundamentos/10_Herramientas_de_sintesis.md#5-experimentos-de-síntesis), para S2: describan el decodificador con un `case` y con ecuaciones lógicas (`assign`) obtenidas de mapas de Karnaugh. ¿Producen el mismo hardware después de `synth_ice40`?

## 7. Mejoras opcionales

- Pausa con un interruptor.
- Minutos y segundos con cuatro displays.
- Ajuste de la cuenta con pulsadores.

---

[← Laboratorio de periféricos](../../README.md) · [Fundamentos](../../Fundamentos/README.md)
