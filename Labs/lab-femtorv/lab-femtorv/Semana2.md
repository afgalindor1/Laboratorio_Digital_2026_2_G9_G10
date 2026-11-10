# Semana 2 · Conectar un periférico al SoC

[← Volver a la guía](README.md)

**Objetivo de la semana:** conectar un periférico al mapa de memoria del SoC y controlarlo desde C. Es lo que cada grupo hará después con el periférico de su consola.

El periférico es un **GPIO**: un registro para encender LEDs y uno para leer pulsadores, en el espacio libre `0x0041_xxxx` (`cs[1]`) que encontraron en la semana 1.

## Elijan su modo

Esta semana se puede jugar en dos modos. Los dos terminan en lo mismo: el GPIO conectado al SoC, funcionando en la tarjeta y controlado desde C.

| | [Modo Aventura 🗺️](Semana2_Aventura.md) | [Modo Jefe Final 🐉](Semana2_JefeFinal.md) |
|---|---|---|
| **Para quién** | Para la mayoría: la primera vez que conectan un periférico | Para los que quieren el reto completo |
| **El GPIO** | Viene hecho: lo leen, lo prueban y lo conectan | Lo diseñan ustedes desde una plantilla |
| **El testbench** | Viene hecho; ustedes agregan 3 pruebas | Escriben parte de las pruebas |
| **Lo que construyen** | Le agregan un registro nuevo, INVERTIR, siguiendo la receta | El periférico completo, con su tabla de registros y su caja negra |
| **Experimento del parpadeo** | Opcional | Obligatorio |
| **Valor agregado** | No | **Sí**, si completan **todas** las tareas del modo |

**Pueden cambiar de modo en cualquier momento.** Si empiezan en Jefe Final y se pasan a Aventura, pierden el valor agregado. Si empiezan en Aventura y quieren el reto, pueden pasarse a Jefe Final mientras completen todas sus tareas.

**Antes de empezar, en cualquier modo:**

- `make sim` de la semana 1 funcionando.
- El mapa de memoria de la tarea 3 en su bitácora.
- El entorno activado en cada terminal nueva: `source digital-logic-design activate`.

[← Semana 1](Semana1.md) · [Volver a la guía](README.md)
