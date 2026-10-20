// Blinker en la Tang Nano 9K: 27 MHz, LEDs de la tarjeta activos en bajo
module top_tangnano9k (
    input        clk,      // 27 MHz
    input        btn_s1,   // reset
    output [5:0] led       // 0 = encendido
);
  wire [4:0] leds;
  // 2^22 / 27 MHz = 0,16 s por paso
  blinker #(.DIV_BITS(22)) b (.clk(clk), .resetn(btn_s1), .leds(leds), .pc());
  assign led = ~{1'b0, leds};  // el sexto LED queda apagado
endmodule
