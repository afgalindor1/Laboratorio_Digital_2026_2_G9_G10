// =============================================================================
// tb_soc.v — Testbench del SoC completo
//
// Qué hace:
//   1. Genera el reloj y el reset.
//   2. Ejecuta el programa que esté en firmware.hex.
//   3. "Escucha" la línea TXD de la UART y escribe en la terminal cada carácter
//      que el programa envía, igual que un terminal serial conectado a la tarjeta.
//
// En simulación la UART funciona mucho más rápido que en la tarjeta (BAUD alto)
// para no esperar millones de ciclos. El programa en C es exactamente el mismo.
//
// Opciones (se pasan con make sim ARGS="..."):
//   +ciclos=N      ciclos máximos a simular (por defecto 2 000 000). La simulación
//                  también termina si la UART lleva 100 000 ciclos sin enviar nada.
//   +vcd           guarda formas de onda en build/tb_soc.vcd (primeros ciclos)
//   +botones=N     valor de los pulsadores, por ejemplo +botones=1
// =============================================================================
`timescale 1ns / 1ns

module tb_soc;

  localparam integer CLK_FREQ   = 25_000_000;
  localparam integer BAUD       = CLK_FREQ / 32;            // UART rápida solo en simulación
  localparam integer BIT_CICLOS = 16 * (CLK_FREQ / BAUD / 16);  // ciclos de reloj por bit
  localparam integer DUMP_CICLOS = 20_000;                  // ciclos guardados en el VCD

  reg        clk = 0;
  reg        resetn = 0;
  reg  [3:0] botones = 0;
  wire       txd;
  wire [7:0] leds_ext;
  wire       led;

  SOC #(
      .CLK_FREQ(CLK_FREQ),
      .BAUD    (BAUD)
  ) uut (
      .clk     (clk),
      .resetn  (resetn),
      .LEDS    (led),
      .RXD     (1'b1),       // nadie le envía datos al SoC
      .TXD     (txd),
      .BOTONES (botones),
      .LEDS_EXT(leds_ext)
  );

  // Reloj de 25 MHz: periodo de 40 ns
  always #20 clk = ~clk;

  // ------------------------------------------------- Receptor UART del PC ---
  integer i;
  reg [7:0] caracter;
  integer caracteres = 0;
  integer ultimo = 0;     // ciclo en que llegó el último carácter
  always begin
    @(negedge txd);                         // bit de inicio
    repeat (BIT_CICLOS / 2) @(posedge clk); // ir a la mitad del bit
    for (i = 0; i < 8; i = i + 1) begin
      repeat (BIT_CICLOS) @(posedge clk);
      caracter[i] = txd;                    // primero llega el bit menos significativo
    end
    repeat (BIT_CICLOS) @(posedge clk);     // bit de parada
    $write("%c", caracter);
    $fflush;
    caracteres = caracteres + 1;
    ultimo = ciclo;
  end

  // ---------------------------------------------------- Control del tiempo ---
  integer ciclos_max;
  integer ciclo = 0;
  integer valor;
  always @(posedge clk) ciclo <= ciclo + 1;

  initial begin
    if (!$value$plusargs("ciclos=%d", ciclos_max)) ciclos_max = 2_000_000;
    if ($value$plusargs("botones=%d", valor)) botones = valor;
    if ($test$plusargs("vcd")) begin
      $dumpfile("build/tb_soc.vcd");
      $dumpvars(0, tb_soc);
    end

    $display("=== Simulacion del SoC: salida de la UART ===");
    repeat (10) @(posedge clk);
    resetn = 1;                             // soltar el reset: el CPU arranca en 0x0

    if ($test$plusargs("vcd")) begin
      repeat (DUMP_CICLOS) @(posedge clk);
      $dumpoff;
    end

    wait (ciclo >= ciclos_max || (caracteres > 0 && ciclo - ultimo > 100_000));
    $display("\n=== Fin: %0d ciclos simulados, %0d caracteres recibidos, LEDS_EXT = %b ===",
             ciclo, caracteres, leds_ext);
    $finish;
  end

endmodule
