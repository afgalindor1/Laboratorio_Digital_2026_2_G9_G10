// =============================================================================
// soc.h — Direcciones de los periféricos del SoC y funciones básicas
//
// Cada periférico es un conjunto de REGISTROS en direcciones fijas de memoria.
// Para el programa, leer o escribir un registro es lo mismo que leer o escribir
// una variable en esa dirección: eso es la E/S mapeada en memoria (MMIO).
//
// REG(dir) convierte un número en "la variable que vive en esa dirección".
//   volatile: le dice al compilador que ese valor puede cambiar por fuera del
//   programa (lo cambia el hardware), así que NO debe guardarlo en un registro
//   ni eliminar lecturas o escrituras que parezcan repetidas.
// =============================================================================
#ifndef SOC_H
#define SOC_H

#include <stdint.h>

#define REG(dir) (*(volatile uint32_t *)(dir))

// ------------------------------------------------------------------ UART ----
#define UART_BASE     0x00400000
#define UART_DATO     REG(UART_BASE + 0x08)  // escribir: byte a enviar | leer: byte recibido
#define UART_CONTROL  REG(UART_BASE + 0x10)  // ver tabla en SOC.v
#define UART_OCUPADA  (1u << 9)              // bit 9: el transmisor está enviando
#define UART_RECIBIDO (1u << 8)              // bit 8: llegó un byte

// --------------------------------------------------------- MULTIPLICADOR ----
#define MULT_BASE     0x00420000
#define MULT_A        REG(MULT_BASE + 0x04)
#define MULT_B        REG(MULT_BASE + 0x08)
#define MULT_INIT     REG(MULT_BASE + 0x0C)
#define MULT_RESULT   REG(MULT_BASE + 0x10)
#define MULT_DONE     REG(MULT_BASE + 0x14)

// ------------------------------------------------------------------ GPIO ----
// Semana 2: el periférico GPIO vive en chip1. Los desplazamientos (+0x04, ...)
// de cada registro los define su grupo en la tabla de registros.
#define GPIO_BASE     0x00410000

// ==================================================== Funciones de la UART ===

// Envía un carácter por la UART y espera a que termine de salir.
static inline void uart_putc(char c) {
  UART_DATO = (uint32_t)c;                 // 1. dejar el byte en el registro de dato
  UART_CONTROL = 1;                        // 2. pedir la transmisión (bit 0)
  UART_CONTROL = 0;
  while (UART_CONTROL & UART_OCUPADA) {}   // 3. esperar (polling) a que termine
}

// Envía un texto terminado en '\0'.
static inline void imprimir(const char *texto) {
  while (*texto) uart_putc(*texto++);
}

// Envía un número de 32 bits en hexadecimal: 0x0000159F
static inline void imprimir_hex(uint32_t n) {
  imprimir("0x");
  for (int i = 28; i >= 0; i -= 4) {
    uint32_t d = (n >> i) & 0xF;
    uart_putc(d < 10 ? '0' + d : 'A' + d - 10);
  }
}

// Envía un número en decimal. Usa división (/ y %): RV32I NO tiene instrucción
// de división, así que el compilador la reemplaza por una rutina de software.
static inline void imprimir_dec(uint32_t n) {
  char buf[11];
  int i = 10;
  buf[i] = '\0';
  do {
    buf[--i] = '0' + (n % 10);
    n = n / 10;
  } while (n);
  imprimir(&buf[i]);
}

// ============================================ Funciones del multiplicador ===

// Multiplica por hardware dos números de 16 bits.
// ¡El resultado se lee JUSTO después de DONE! El periférico lo borra ~30 ciclos después.
static inline uint32_t mult_hw(uint16_t a, uint16_t b) {
  MULT_A = a;
  MULT_B = b;
  MULT_INIT = 1;
  MULT_INIT = 0;
  while (!MULT_DONE) {}
  return MULT_RESULT;
}

#endif
