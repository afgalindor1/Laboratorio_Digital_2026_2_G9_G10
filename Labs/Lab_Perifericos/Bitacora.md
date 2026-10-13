# Guía de la bitácora

[← Laboratorio de periféricos](README.md)

La **bitácora grupal** es el registro de todo el proceso de diseño. **La evaluación del laboratorio se basa en ella:** lo que no está registrado no se puede evaluar, aunque el prototipo funcione. Sus secciones son las que define la [metodología del curso](../../README.md#metodología), y dentro de ellas se ubican las ocho etapas de la [metodología de diseño](Fundamentos/01_Metodologia.md).

---

## Contenido

- [Cómo llevar la bitácora](#cómo-llevar-la-bitácora)
- [Secciones de la bitácora](#secciones-de-la-bitácora)
- [Plantillas](#plantillas)
- [El repositorio en GitHub Classroom](#el-repositorio-en-github-classroom)
- [El video](#el-video)
- [Lista de verificación antes de entregar](#lista-de-verificación-antes-de-entregar)

---

## Cómo llevar la bitácora

- **Registren mientras trabajan**, con fecha en cada entrada.
- **Registren las predicciones antes de ejecutar las herramientas.** Una predicción escrita después del resultado no tiene valor.
- **Registren los errores**: qué falló, cómo lo detectaron y cómo lo corrigieron.
- **Justifiquen cada decisión** y **citen cada fuente**: hoja de datos, libro, página.
- **Todos los integrantes participan** e indican qué hizo cada uno.
- **Preinforme e informe:** las secciones 1 a 5 forman el **preinforme** y se entregan antes de la sesión de implementación; las secciones 6 y 7 forman el **informe**.

## Secciones de la bitácora

| # | Sección | Etapas de la metodología | Entrega |
|---|---|---|---|
| 1 | Objetivos | — | Preinforme |
| 2 | Marco teórico | 1. Entender el problema | Preinforme |
| 3 | Etapa de diseño del sistema | 2. Variables · 3. Cuentas · 4. Caja negra · 5. Diagrama de flujo | Preinforme |
| 4 | Etapa de descripción en HDL | 6. Verilog · 7. RTL: predicción vs. síntesis (S1 a S3) | Preinforme |
| 5 | Etapa de simulación | 8. Simulación | Preinforme |
| 6 | Etapa de implementación | 8. Implementación (S4 y S5) | Informe |
| 7 | Resultados y análisis | Todas | Informe |

### 1. Objetivos

- Objetivo general y específicos, **en sus propias palabras**.
- El alcance acordado con el profesor y los **parámetros asignados** a su grupo.

### 2. Marco teórico (etapa 1)

- Funcionamiento del periférico: qué señal espera, con qué tiempos y voltajes, **con citas** a la hoja de datos y a los libros.
- Respuestas a las preguntas de "Qué deben investigar" de su ficha.
- La tarjeta y su `CLK_FREQ`: de dónde lo obtuvieron y cómo lo verificaron.

### 3. Etapa de diseño del sistema (etapas 2 a 5)

- **Tabla de variables**, con la columna "¿se recuerda?" y la **predicción de flip-flops**.
- **Tabla de cálculos**: tiempos convertidos a ciclos y bits.
- **Caja negra** y **tabla de especificaciones** medibles, con identificadores (E1, E2, ...).
- **Diagrama de flujo** que cubra todos los casos.
- **Tablas de verdad** de los bloques combinacionales.
- **Diagrama de bloques** con nombres y anchos de las señales.

### 4. Etapa de descripción en HDL (etapas 6 y 7)

- El código Verilog, **explicado y relacionado con el diagrama de flujo**: qué parte del código implementa cada decisión y cada acción.
- **Experimento S1:** predicción (escrita antes) vs. RTL y estadísticas de Yosys; cada diferencia explicada.
- **Experimento S2:** dos descripciones de un mismo bloque y su comparación.
- **Experimento S3:** el latch provocado a propósito y lo que reportó la herramienta.

Detalles de los experimentos: [Herramientas de síntesis](Fundamentos/10_Herramientas_de_sintesis.md#5-experimentos-de-síntesis).

### 5. Etapa de simulación (etapa 8)

- El testbench: qué especificación verifica cada prueba y cómo.
- Los mensajes `OK` / `ERROR`.
- Capturas de GTKWave con las mediciones visibles, comparadas con la tabla de cálculos.
- Si algo falló: la corrección y la nueva simulación.

### 6. Etapa de implementación (etapa 8)

- Archivo de restricciones y **tabla de conexiones**.
- Esquema o foto del montaje, con la fuente externa y la tierra común visibles.
- Verificación de **cada especificación** en la tarjeta, con mediciones.
- **Experimento S4:** cambio de parámetro y su efecto en bits y recursos.
- **Experimento S5:** recursos usados y frecuencia máxima reportados por la síntesis.
- Si hubo un cambio en vivo durante la sesión: qué se pidió, qué se recalculó y el resultado.

### 7. Resultados y análisis

- **Comparación entre lo diseñado, lo simulado y lo implementado**, idealmente en una tabla por especificación.
- Problemas encontrados y cómo se resolvieron.
- Limitaciones, mejoras implementadas o propuestas.
- Conclusiones: qué aprendieron sobre el diseño y sobre las herramientas.

## Plantillas

**Tabla de variables**

| Variable | Tipo | Valores | Unidad | ¿Se recuerda? | Flip-flops |
|---|---|---|---|---|---|
| | | | | | |
| | | | | **Total predicho** | |

**Tabla de cálculos** ($N = t \cdot f_{clk}$, bits $= \lceil \log_2 N \rceil$)

| Parámetro | Tiempo o frecuencia | Fórmula | Ciclos | Bits | En el código |
|---|---|---|---|---|---|
| Reloj de la tarjeta | `CLK_FREQ` = | — | — | — | `parameter CLK_FREQ = ...` |
| | | | | | |

**Tabla de especificaciones**

| ID | Especificación (medible) | Verificación en simulación | Verificación en la tarjeta |
|---|---|---|---|
| E1 | | | |

**Predicción vs. síntesis (S1)**

| Elemento | Predicción | Resultado de Yosys | Explicación de la diferencia |
|---|---|---|---|
| Flip-flops | | | |
| Sumadores / restadores | | | |
| Comparadores | | | |
| Multiplexores | | | |

El [ejemplo resuelto](Fundamentos/12_Ejemplo_resuelto.md) muestra estas tablas llenas.

## El repositorio en GitHub Classroom

El repositorio contiene **el código y lo mínimo para entenderlo y ejecutarlo**. El análisis va en la bitácora.

```
├── src/              # módulos Verilog del diseño
├── testbench/        # testbenches
├── constraints/      # archivo de restricciones físicas
├── experimentos/     # versiones usadas en los experimentos de síntesis
├── Makefile          # el de los ejemplos .zip, adaptado
└── README.md
```

**README corto:** qué hace el diseño, cómo simularlo y sintetizarlo, entradas y salidas, enlace al video.

**Commits realizados y justificados** (criterio habilitante). El historial debe mostrar el proceso real: predicción, primer intento, errores y correcciones. Ejemplos:

```
Agrego contador de periodo con parámetro CLK_FREQ

Implementa la tabla de cálculos de la bitácora: 20 ms con
el reloj de 25 MHz requieren 19 bits.
```

```
Experimento S3: provoco un latch quitando el valor por defecto

Yosys reporta "Latch inferred" y una celda $dlatch; la
versión corregida queda en src/.
```

```
Corrijo comparador de reinicio: cambio == por >=

Al cambiar de velocidad el contador se pasaba del nuevo
límite y tardaba casi un segundo en reiniciar (E4 fallaba).
```

## El video

En el video, el grupo:

1. Explica el **flujo de desarrollo** con su propio diseño: variables, cuentas, caja negra, diagrama de flujo, Verilog, RTL y la comparación con su predicción, simulación y síntesis.
2. Muestra el **prototipo funcionando**, con cada especificación.
3. Comenta un problema que encontraron y cómo lo resolvieron.

La duración y el formato los indica el profesor. Incluyan el enlace en el README y en la bitácora.

## Lista de verificación antes de entregar

**Preinforme**

- [ ] Objetivos propios, alcance y parámetros asignados.
- [ ] Marco teórico con fuentes citadas y `CLK_FREQ` verificado.
- [ ] Tabla de variables con la predicción de flip-flops.
- [ ] Tabla de cálculos, caja negra y especificaciones medibles.
- [ ] Diagrama de flujo, tablas de verdad y diagrama de bloques.
- [ ] Verilog sintetizable y trazable al diagrama de flujo.
- [ ] Experimentos S1, S2 y S3 registrados.
- [ ] Testbench que verifica cada especificación, con capturas.

**Informe**

- [ ] Restricciones, tabla de conexiones y montaje seguro.
- [ ] Cada especificación verificada en la tarjeta.
- [ ] Experimentos S4 y S5 registrados.
- [ ] Comparación diseñado / simulado / implementado y conclusiones.

**Repositorio y video**

- [ ] Código, testbench y restricciones organizados, con README corto.
- [ ] Commits que muestran el proceso.
- [ ] Video con el flujo completo y el prototipo funcionando.

---

[← Laboratorio de periféricos](README.md)
