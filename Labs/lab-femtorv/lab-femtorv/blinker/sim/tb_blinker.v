// =============================================================================
// tb_blinker.v — Testbench del blinker
// Usa un divisor muy pequeño (DIV_BITS = 3) para no simular millones de ciclos,
// y escribe en la terminal el PC y los LEDs cada vez que los LEDs cambian.
// =============================================================================
`timescale 1ns / 1ns

module tb_blinker;
  reg clk = 0, resetn = 0;
  wire [4:0] leds, pc;

  blinker #(.DIV_BITS(3)) uut (.clk(clk), .resetn(resetn), .leds(leds), .pc(pc));

  always #20 clk = ~clk;

  always @(leds) $display("t = %6t ns   PC = %2d   LEDS = %b", $time, pc, leds);

  initial begin
    $dumpfile("build/tb_blinker.vcd");
    $dumpvars(0, tb_blinker);
    #100 resetn = 1;
    #(40 * 8 * 23) $finish;  // un poco más de una vuelta completa (21 posiciones)
  end
endmodule
