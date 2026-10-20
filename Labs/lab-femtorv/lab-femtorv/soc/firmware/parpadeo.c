// =============================================================================
// parpadeo.c — Experimento de la Semana 2: ¿cuánto cuesta una tarea en software?
//
// El programa enciende y apaga el LED 0 lo más rápido que puede.
//
// ANTES de medir:
//   1. make firmware PROG=parpadeo
//   2. Abra build/firmware.lst y busque el bucle while(1): cuente sus instrucciones.
//   3. Prediga la frecuencia de la señal en el LED (vea Semana2.md, experimento).
// DESPUÉS: mida con el osciloscopio o el analizador lógico y compare.
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
