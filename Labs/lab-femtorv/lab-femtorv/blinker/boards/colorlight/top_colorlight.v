// Blinker en la Colorlight 5A-75E: 25 MHz, LEDs externos en J2 (los mismos de la Semana 2)
module top_colorlight (
    input        clk,       // 25 MHz
    input        resetn,    // botón de la tarjeta
    output [4:0] leds_ext   // LEDs externos en J2
);
  // 2^22 / 25 MHz = 0,17 s por paso
  blinker #(.DIV_BITS(22)) b (.clk(clk), .resetn(resetn), .leds(leds_ext), .pc());
endmodule
