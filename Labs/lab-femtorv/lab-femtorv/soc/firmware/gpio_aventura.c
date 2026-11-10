// =============================================================================
// gpio_aventura.c — Programa de la Semana 2, Modo Aventura: usar el GPIO desde C
//
// Parte A (paso A4): completen las dos direcciones (COMPLETAR) según la tabla
//          de registros. Si quieren, cambien los dos patrones de LEDs.
// Parte B (paso B3): en las dos líneas marcadas con  PARTE B , quiten el
//          comentario y completen la dirección de INVERTIR.
//
//   make sim PROG=gpio_aventura ARGS="+botones=1"     (+botones=N fija los pulsadores)
//   make syn PROG=gpio_aventura BOARD=...
// =============================================================================
#include "soc.h"

// Direcciones de los registros (base 0x0041_0000 + desplazamiento)
#define GPIO_LEDS      REG(GPIO_BASE + 0x00 /* COMPLETAR */)
#define GPIO_BOTONES   REG(GPIO_BASE + 0x00 /* COMPLETAR */)
// PARTE B: #define GPIO_INVERTIR  REG(GPIO_BASE + /* COMPLETAR */)

// Patrones de los LEDs (6 bits: los LEDs que tiene la tarjeta)
#define PATRON_SUELTO     0x07   // ningún pulsador:  000111  (cámbienlo si quieren)
#define PATRON_PULSADO    0x2A   // pulsador 0:       101010  (cámbienlo si quieren)

int main(void) {
  imprimir("Semana 2: periferico GPIO\r\n");

  // Prueba 1: escribir un valor en LEDS y leerlo de vuelta (un sw y un lw)
  GPIO_LEDS = 0x2A;
  imprimir("LEDS = ");
  imprimir_hex(GPIO_LEDS);
  imprimir("\r\n");

  // Prueba 2: leer los pulsadores (un lw)
  imprimir("BOTONES = ");
  imprimir_hex(GPIO_BOTONES);
  imprimir("\r\n");

  // Bucle principal: leer los pulsadores y decidir qué mostrar
  while (1) {
    uint32_t b = GPIO_BOTONES;

    if (b & 1)
      GPIO_LEDS = PATRON_PULSADO;
    else
      GPIO_LEDS = PATRON_SUELTO;

    // PARTE B: mientras el pulsador 0 esté presionado, INVERTIR vale 1
    // GPIO_INVERTIR = b & 1;
  }
}
