# 7. Entradas externas: pulsadores, interruptores y sensores

[← Señales periódicas y PWM](06_Senales_periodicas_PWM.md) · [Fundamentos](README.md) · [Siguiente: Frecuencia del reloj →](08_Frecuencia_del_reloj.md)

Toda señal que viene de fuera de la FPGA (un pulsador, un interruptor, la salida de un sensor) necesita un tratamiento antes de usarse: ajustar su polaridad, sincronizarla con el reloj y, a veces, eliminar el rebote.

---

## Contenido

1. [Cómo se conecta un pulsador: activo en bajo](#1-cómo-se-conecta-un-pulsador-activo-en-bajo)
2. [Sincronizar las entradas](#2-sincronizar-las-entradas)
3. [Rebote: control por nivel y control por pulsación](#3-rebote-control-por-nivel-y-control-por-pulsación)
4. [Interruptores](#4-interruptores)

---

## 1. Cómo se conecta un pulsador: activo en bajo

La conexión más común usa una **resistencia de pull-up**: con el pulsador suelto, el pin lee 1; al presionarlo, el pulsador lo conecta a GND y lee 0.

```
    3.3 V
      │
     ┌┴┐
     │R│ 10 kΩ (pull-up)
     └┬┘
      ├────────── pin de la FPGA   suelto: 1   presionado: 0
      │
     ─┴─
      ─   pulsador
     ─┬─
      │
     GND
```

A esto se le llama **activo en bajo**. Dentro del diseño es más claro que 1 signifique "presionado", así que la señal se invierte una sola vez, en el módulo top. El sufijo `_n` es una convención para nombrar señales activas en bajo:

```verilog
input  wire btn_n,           // pin de la tarjeta: 0 = presionado
wire   btn = ~btn_n;         // dentro del diseño: 1 = presionado
```

La resistencia de pull-up puede ser externa o interna de la FPGA, activada en el archivo de restricciones. Para saber si un pulsador de la tarjeta es activo en bajo, revisen el esquemático o conéctenlo directamente a un LED y observen.

## 2. Sincronizar las entradas

Una señal externa cambia en cualquier momento, sin relación con el reloj, y puede provocar **metaestabilidad** ([ver lógica secuencial](03_Logica_secuencial.md#8-señales-externas-y-metaestabilidad)). Antes de usarla, se pasa por un **sincronizador de dos flip-flops**:

```verilog
reg btn_meta, btn_s;

always @(posedge clk) begin
    btn_meta <= btn;         // 1er flip-flop: captura la señal externa
    btn_s    <= btn_meta;    // 2do flip-flop: entrega una copia estable
end
// En el resto del diseño se usa btn_s, nunca btn
```

La señal llega con dos ciclos de retraso, algo imperceptible. Esto aplica a pulsadores, interruptores y salidas de sensores; es indispensable cuando la señal habilita un contador.

## 3. Rebote: control por nivel y control por pulsación

Los contactos de un pulsador rebotan al presionar o soltar, y producen varios cambios rápidos durante **5 a 20 ms**:

```
           presiona                          suelta
              ↓                                ↓
btn_n  ‾‾‾‾‾‾‾|_|‾|__|‾|______________________|‾|_|‾‾|‾‾‾‾‾‾‾‾
              |<-rebote->|                     |<rebote>|
```

Si el rebote importa o no depende de **cómo se usa** el pulsador. Es una decisión de diseño:

| | Control por nivel | Control por pulsación |
|---|---|---|
| Qué se lee | Si el pulsador está presionado **ahora** | **Cuántas veces** se presionó |
| Ejemplo | Algo ocurre mientras se mantiene presionado | Cada pulsación avanza un paso |
| ¿Se recuerda algo? | No | Sí: un registro guarda el valor |
| Rebote | Casi no afecta: unos milisegundos de alternancia | Cada rebote cuenta como pulsación: hace falta **debounce** |
| Detector de flanco | No se usa | Necesario: un pulso de un ciclo por pulsación |

El **control por nivel** es el camino más simple y suficiente para el alcance base del laboratorio. El control por pulsación es una mejora: requiere un circuito de **debounce** (aceptar un cambio solo si dura más que el rebote) y un **detector de flanco**, que genera un pulso de un ciclo cuando la señal pasa de 0 a 1:

```verilog
reg ant;                                 // valor del ciclo anterior
always @(posedge clk) ant <= senal;
assign flanco = senal & ~ant;            // 1 solo en el ciclo en que senal sube
```

Busquen "debounce" y "edge detector" en los libros de FPGA para el diseño completo.

## 4. Interruptores

Un **interruptor** mantiene su posición sin que nadie lo sostenga. Sirve para valores que deben quedarse fijos, como un modo o una dirección. También se sincroniza. Si el enunciado pide pulsadores, acuerden con el profesor dónde pueden usar interruptores.

---

[← Señales periódicas y PWM](06_Senales_periodicas_PWM.md) · [Fundamentos](README.md) · [Siguiente: Frecuencia del reloj →](08_Frecuencia_del_reloj.md)
