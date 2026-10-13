# Fundamentos

[← Laboratorio de periféricos](../README.md)

Estas guías explican los temas generales que se necesitan para abordar cualquiera de los periféricos del laboratorio. No resuelven los periféricos: dan las bases, muestran cómo usar las herramientas e indican dónde profundizar. Lo específico de cada periférico lo investiga cada grupo en libros y hojas de datos.

## Orden de lectura

| # | Tema | Qué aprenden |
|---|---|---|
| 1 | [Metodología](01_Metodologia.md) | Las ocho etapas para abordar un problema de diseño digital; dónde buscar |
| 2 | [Verilog básico](02_Verilog_basico.md) | Módulos, `wire` y `reg`, `assign`, qué significa `always @`, `=` y `<=`, parámetros |
| 3 | [Lógica secuencial](03_Logica_secuencial.md) | El reloj, el flip-flop como caja negra, variables que se recuerdan, latches |
| 4 | [Contadores y tiempo](04_Contadores_y_tiempo.md) | Contador módulo M, de tiempo a ciclos de reloj, pulso de habilitación |
| 5 | [Bloques combinacionales](05_Bloques_combinacionales.md) | Tablas de verdad, decodificador, codificador de prioridad, mux, demux, comparadores |
| 6 | [Señales periódicas y PWM](06_Senales_periodicas_PWM.md) | Periodo, ciclo de trabajo, generación con contador y comparador |
| 7 | [Entradas externas](07_Entradas_externas.md) | Activo en bajo, sincronizador, rebote, control por nivel o por pulsación |
| 8 | [Frecuencia del reloj](08_Frecuencia_del_reloj.md) | Cómo averiguar y verificar `CLK_FREQ` |
| 9 | [Simulación con testbench](09_Simulacion.md) | Estructura de un testbench, verificación automática, GTKWave |
| 10 | [Herramientas de síntesis](10_Herramientas_de_sintesis.md) | RTL, predicción vs. síntesis, **experimentos de síntesis**, restricciones, configuración |
| 11 | [Conexión eléctrica](11_Conexion_electrica.md) | 3.3 V, fuente externa, GND común, divisor de voltaje |
| 12 | [Ejemplo resuelto](12_Ejemplo_resuelto.md) | Las ocho etapas aplicadas a un LED de dos velocidades |

## Ejemplo de código

La carpeta [ejemplos/](ejemplos/) contiene el diseño y el testbench del [ejemplo resuelto](12_Ejemplo_resuelto.md), comentados línea por línea, simulados con Icarus Verilog y sintetizados con Yosys sin errores ni latches. El mismo diseño sirve para verificar `CLK_FREQ` en la tarjeta.

| Archivo | Qué es |
|---|---|
| [parpadeo_dos_velocidades.v](ejemplos/parpadeo_dos_velocidades.v) | Diseño: LED que parpadea a 1 Hz o 4 Hz según un interruptor |
| [tb_parpadeo_dos_velocidades.v](ejemplos/tb_parpadeo_dos_velocidades.v) | Testbench con verificación automática de las especificaciones |

```bash
cd ejemplos
iverilog -o sim.vvp tb_parpadeo_dos_velocidades.v parpadeo_dos_velocidades.v
vvp sim.vvp
gtkwave tb_parpadeo_dos_velocidades.vcd
```

---

[← Laboratorio de periféricos](../README.md)
