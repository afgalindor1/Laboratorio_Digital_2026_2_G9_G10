// =============================================================================
// hola.c — Primer programa para el FemtoRV (Semana 1)
//
// Compilar y simular:      make sim
// Compilar y sintetizar:   make syn BOARD=colorlight   (o BOARD=tangnano9k)
// Ver lo que envía:        make terminal
// =============================================================================
#include "soc.h"

int main(void) {
  imprimir("Hola desde el FemtoRV\r\n");

  // El mismo cálculo de dos formas:
  uint32_t a = 123, b = 45;

  imprimir("Por software (sumas repetidas): ");
  uint32_t r_sw = 0;
  for (uint32_t i = 0; i < b; i++) r_sw = r_sw + a;
  imprimir_dec(r_sw);
  imprimir("\r\n");

  imprimir("Por hardware (periferico MULT): ");
  imprimir_dec(mult_hw(a, b));
  imprimir("\r\n");

  // El LED de la tarjeta (Colorlight) se controla con el bit 2 del control de la UART.
  imprimir("Fin. El programa queda en un bucle infinito.\r\n");
  while (1) {}
}
