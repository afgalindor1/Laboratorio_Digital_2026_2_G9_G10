// =============================================================================
// top_colorlight.v — Adapta el SoC a la tarjeta Colorlight 5A-75E (v8.2)
//
//   Reloj:      25 MHz (pin P6)
//   Reset:      botón de la tarjeta (R7), activo en bajo
//   UART:       TX en C4, RX en D4 (conector J1) -> adaptador USB-serial
//   LEDs ext.:  conector J2 (solo salidas)
//   Pulsadores: conector J1 (único conector que admite entradas)
//
// Los pulsadores se conectan entre el pin y GND; la resistencia de pull-up
// interna deja el pin en 1. Por eso se invierten: dentro del SoC 1 = presionado.
// =============================================================================
module top_colorlight (
    input        clk,       // 25 MHz
    input        resetn,    // botón de la tarjeta (presionado = 0)
    output       led,       // LED de la tarjeta (T6)
    input        RXD,
    output       TXD,
    input  [1:0] btn,       // pulsadores externos en J1 (presionado = 0)
    output [5:0] leds_ext   // LEDs externos en J2 (1 = encendido)
);

  wire [7:0] leds_soc;

  SOC #(
      .CLK_FREQ(25_000_000),
      .BAUD    (115200)
  ) soc (
      .clk     (clk),
      .resetn  (resetn),
      .LEDS    (led),
      .RXD     (RXD),
      .TXD     (TXD),
      .BOTONES ({2'b00, ~btn}),
      .LEDS_EXT(leds_soc)
  );

  assign leds_ext = leds_soc[5:0];

endmodule
