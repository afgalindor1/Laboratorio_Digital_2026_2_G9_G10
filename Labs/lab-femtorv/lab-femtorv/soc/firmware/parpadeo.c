// =============================================================================
// parpadeo.c — Experimento de la Semana 2: ¿cuánto cuesta una tarea en software?
//
// El programa enciende y apaga el LED 0 lo más rápido que puede.
//
// Experimento opcional (Semana2.md, paso L2):
//   1. Calcule la frecuencia de la señal del LED 0 con la tabla de ciclos de la
//      guía (el bucle se ve en build/firmware.lst después de make firmware PROG=parpadeo).
//   2. make syn PROG=parpadeo BOARD=...  y  make config BOARD=...
//   3. Mida con el osciloscopio o el analizador lógico y compare.
// =============================================================================
#include "soc.h"

// COMPLETAR: la misma dirección del registro LEDS que usó en gpio.c
#define GPIO_LEDS  REG(GPIO_BASE + 0x00 /* COMPLETAR */)

int main(void) {
  while (1) {
    GPIO_LEDS = 1;  // encender
    GPIO_LEDS = 0;  // apagar
  }
}
