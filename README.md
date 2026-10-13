# Electrónica Digital I - 2026-II

**Grupos 9 y 10**

## Índice

* [Introducción](#introducción)
* [Metodología](#metodología)
* [Cronograma](#cronograma)
* [Laboratorios](#laboratorios)
* [Herramientas y recursos](#herramientas-y-recursos)

## Introducción

Bienvenidos al laboratorio de Electrónica Digital I.

El laboratorio de Electrónica Digital I tiene como objetivo principal complementar los conceptos teóricos impartidos en clase magistral mediante actividades prácticas que permitan a los estudiantes desarrollar competencias en diseño e implementación de circuitos digitales.

**Profesores:**

- Johan Sebastian Eslava
- Andrés Felipe Galindo Rojas

## Metodología

El laboratorio se desarrolla bajo el siguiente esquema:

1. **Preparación previa**

   Lectura de la guía, configuración del entorno, simulación y escritura del preinforme con diseño y cálculos.

2. **Trabajo en laboratorio**

   Implementación práctica en grupos, validación de resultados y análisis.

3. **Documentación**

   Elaboración de la bitácora grupal:

   * Objetivos.
   * Marco teórico.
   * Etapa de diseño del sistema (preinforme).
   * Etapa de descripción en HDL (preinforme).
   * Etapa de simulación (preinforme).
   * Etapa de implementación (informe).
   * Resultados y análisis.

4. **Evaluación y retroalimentación**

   Criterios de evaluación:

   * **Criterios habilitantes**
     * Asistencia al laboratorio.
     * Entrega del preinforme.
     * Commits realizados y justificados.
   * **Etapas del desarrollo del sistema:** se evaluará que los estudiantes sigan las etapas del flujo de diseño digital, incluyendo:
     * Etapa de diseño del sistema (preinforme).
     * Etapa de descripción en HDL (preinforme).
     * Etapa de simulación (preinforme).
     * Etapa de implementación (informe).
   * **Documentación en GitHub Classroom y bitácora:** claridad, precisión, organización, cumplimiento de los plazos establecidos y adherencia a los lineamientos de entrega planteados, completando cada una de las secciones definidas en esta.
   * Se valorará positivamente que los estudiantes vayan más allá de lo solicitado en la guía, incorporando mejoras, optimizaciones, características adicionales y/o realizando un análisis más profundo del diseño propuesto.

5. **Normas generales del laboratorio**

   * Asistencia obligatoria a todas las sesiones.
   * Puntualidad y respeto por los tiempos asignados.
   * Uso adecuado de los equipos y materiales.
   * Mantener el orden y la limpieza en el laboratorio.
   * Informar cualquier desperfecto o irregularidad con los equipos al profesor.

## Cronograma

| Semana | Fechas | Actividad | Entrega |
|---|---|---|---|
| Por definir | Por definir | Laboratorio de periféricos: lectura de los fundamentos, elección del periférico y acuerdo del alcance con el profesor | — |
| Por definir | Por definir | Laboratorio de periféricos: diseño, descripción en HDL y simulación | Preinforme |
| Por definir | Por definir | Laboratorio de periféricos: implementación en la FPGA | Informe, repositorio y video |

## Laboratorios

| Laboratorio | Contenido | Enlace |
|---|---|---|
| **Implementación de periféricos en FPGA** | Guía general: metodología, flujo de desarrollo, entregables y evaluación | [Guía del laboratorio](Labs/Lab_Perifericos/README.md) |
| | Fundamentos: metodología de diseño, Verilog, lógica secuencial, contadores, simulación y herramientas de síntesis | [Fundamentos](Labs/Lab_Perifericos/Fundamentos/README.md) |
| | Ejemplo resuelto: las ocho etapas aplicadas a un LED de dos velocidades | [Ejemplo resuelto](Labs/Lab_Perifericos/Fundamentos/12_Ejemplo_resuelto.md) |
| | Guía de la bitácora y del repositorio | [Bitácora](Labs/Lab_Perifericos/Bitacora.md) |
| | Instrucciones: servomotor SG90 | [Servomotor](Labs/Lab_Perifericos/Perifericos/Servomotor/README.md) |
| | Instrucciones: sensor de ultrasonido HC-SR04 | [Ultrasonido](Labs/Lab_Perifericos/Perifericos/Ultrasonido/README.md) |
| | Instrucciones: puente H con PWM | [Puente H](Labs/Lab_Perifericos/Perifericos/Puente_H/README.md) |
| | Instrucciones: generador de tonos | [Generador de tonos](Labs/Lab_Perifericos/Perifericos/Generador_Tonos/README.md) |
| | Instrucciones: reloj de segundos con 2 displays de 7 segmentos | [Reloj de segundos](Labs/Lab_Perifericos/Perifericos/Reloj_7_Segmentos/README.md) |
| | Instrucciones: motor paso a paso | [Motor paso a paso](Labs/Lab_Perifericos/Perifericos/Motor_Paso_a_Paso/README.md) |

## Herramientas y recursos

Todo el flujo del laboratorio usa herramientas de código abierto:

| Herramienta | Uso | Comando de los ejemplos |
|---|---|---|
| Icarus Verilog y GTKWave | Simulación y visualización de formas de onda | `make sim` |
| Yosys y netlistsvg | Síntesis y diagrama RTL | `make rtl` |
| Herramientas de síntesis, ubicación y ruteo, y programación de los ejemplos `.zip` | Configuración de la FPGA | `make clean syn conf` |

- [Repositorio de referencia del curso](https://github.com/johnnycubides/digital-electronic-1-101): ejemplos, documentación de las tarjetas FPGA y guías.
- [Instalación de las herramientas de código abierto](https://github.com/johnnycubides/digital-electronic-1-101/blob/main/installTools/conda-and-tools.md).
