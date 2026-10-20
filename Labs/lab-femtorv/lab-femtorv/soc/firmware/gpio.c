// =============================================================================
// gpio.c — PLANTILLA del programa de la Semana 2
//
// Objetivo: los LEDs muestran un patrón que depende del pulsador presionado.
// Complete las partes marcadas con  COMPLETAR  y ejecute:
//   make sim PROG=gpio ARGS="+botones=1"
//   make syn PROG=gpio BOARD=...
// =============================================================================
#include "soc.h"

// COMPLETAR: direcciones de los registros según SU tabla de registros
#define GPIO_LEDS     REG(GPIO_BASE + 0x00 /* COMPLETAR */)
#define GPIO_BOTONES  REG(GPIO_BASE + 0x00 /* COMPLETAR */)

int main(void) {
  imprimir("Semana 2: periferico GPIO\r\n");

  // Prueba 1: escribir un valor y leerlo de vuelta
  GPIO_LEDS = 0x2A;
  imprimir("LEDS = ");
  imprimir_hex(GPIO_LEDS);
  imprimir("\r\n");

  // Prueba 2: leer los pulsadores
  imprimir("BOTONES = ");
  imprimir_hex(GPIO_BOTONES);
  imprimir("\r\n");

  // Bucle principal (polling): leer los pulsadores y decidir el patrón
  while (1) {
    uint32_t b = GPIO_BOTONES;

    // COMPLETAR: elija un patrón distinto para cada caso, por ejemplo:
    //   ningún pulsador -> 0b000001
    //   pulsador 0      -> 0b010101
    //   pulsador 1      -> 0b101010
    if (b == 0) {
      GPIO_LEDS = 0x01;
    } else {
      GPIO_LEDS = 0x00; /* COMPLETAR */
    }
  }
}
