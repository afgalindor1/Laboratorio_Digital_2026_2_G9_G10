// =============================================================================
// top_tangnano9k.v — Adapta el SoC a la tarjeta Sipeed Tang Nano 9K
//
//   Reloj:   27 MHz (pin 52)              <-- ¡distinto de la Colorlight!
//   Reset:   botón S1 (pin 4), activo en bajo
//   Botón:   S2 (pin 3), activo en bajo   -> BOTONES[0]
//   LEDs:    6 LEDs de la tarjeta, ACTIVOS EN BAJO (0 = encendido)
//   UART:    TX pin 17, RX pin 18, por el mismo cable USB (chip BL702)
//
// La tarjeta trabaja al revés que el SoC (0 = presionado / 0 = encendido),
// así que aquí se invierten las señales: dentro del SoC siempre 1 = activo.
// =============================================================================
module top_tangnano9k (
    input        clk,       // 27 MHz
    input        btn_s1,    // reset (presionado = 0)
    input        btn_s2,    // pulsador de usuario (presionado = 0)
    output [5:0] led,       // LEDs de la tarjeta (0 = encendido)
    input        uart_rx,
    output       uart_tx
);

  wire [7:0] leds_soc;
  wire       led_uart;  // LED controlado por la UART: no se usa en esta tarjeta

  SOC #(
      .CLK_FREQ(27_000_000),  // ¡Si se deja en 25 MHz, la UART envía basura!
      .BAUD    (9600)
  ) soc (
      .clk     (clk),
      .resetn  (btn_s1),
      .LEDS    (led_uart),
      .RXD     (uart_rx),
      .TXD     (uart_tx),
      .BOTONES ({3'b000, ~btn_s2}),
      .LEDS_EXT(leds_soc)
  );

  assign led = ~leds_soc[5:0];

endmodule
