// =============================================================================
// tb_perip_gpio.v — Testbench del periférico GPIO (Semana 2, Modo Aventura)
//
// Ya está completo para LEDS y BOTONES. En la Parte B agregan la prueba del
// registro INVERTIR en el lugar marcado con  PARTE B .
//
// Prueba el periférico SOLO, sin el procesador. Las tareas escribir() y leer()
// imitan lo que hace el FemtoRV en el bus. Si el periférico falla aquí, el
// error está en el periférico y no en el programa en C.
//
// Copie este archivo a soc/sim/tb_perip_gpio.v. Para simular, desde soc/:
//   iverilog -g2012 -o build/tb_gpio.vvp sim/tb_perip_gpio.v rtl/perip_gpio.v
//   vvp -n build/tb_gpio.vvp
//   gtkwave build/tb_perip_gpio.vcd &
// =============================================================================
`timescale 1ns / 1ns

module tb_perip_gpio;

  reg         clk = 0, reset = 1;
  reg  [31:0] d_in = 0, addr = 0;
  reg         cs = 0, rd = 0, wr = 0;
  reg  [ 3:0] botones = 0;
  wire [31:0] d_out;
  wire [ 7:0] leds;

  perip_gpio uut (
      .clk(clk), .reset(reset), .d_in(d_in), .cs(cs), .addr(addr),
      .rd(rd), .wr(wr), .d_out(d_out), .botones(botones), .leds(leds)
  );

  always #20 clk = ~clk;  // 25 MHz

  // ---------------------------------------------- Tareas que imitan al CPU ---
  // Escritura (como un sw): dirección y dato presentes durante un flanco de
  // reloj con wr = 1. cs vale 1 solo si la dirección es 0x0041_xxxx: es lo que
  // haría el chip_select del SoC.
  task escribir(input [31:0] direccion, input [31:0] dato);
    begin
      @(negedge clk);
      addr = direccion; d_in = dato; cs = (direccion[31:16] == 16'h0041); wr = 1;
      @(negedge clk);
      wr = 0; cs = 0;
    end
  endtask

  // Lectura (como un lw): rd = 1 durante un flanco; el dato queda en d_out
  // después del flanco y se copia en la variable de salida.
  task leer(input [31:0] direccion, output [31:0] dato);
    begin
      @(negedge clk);
      addr = direccion; cs = (direccion[31:16] == 16'h0041); rd = 1;
      @(negedge clk);
      rd = 0; cs = 0;
      dato = d_out;
    end
  endtask

  // Comprueba un valor y reporta si coincide con lo esperado
  integer errores = 0;
  task comprobar(input [255:0] que, input [31:0] obtenido, input [31:0] esperado);
    begin
      if (obtenido === esperado) $display("OK     %0s = %h", que, obtenido);
      else begin
        $display("ERROR  %0s = %h (se esperaba %h)", que, obtenido, esperado);
        errores = errores + 1;
      end
    end
  endtask

  // ------------------------------------------------------------- Pruebas ---
  reg [31:0] valor;
  initial begin
    $dumpfile("build/tb_perip_gpio.vcd");
    $dumpvars(0, tb_perip_gpio);
    repeat (3) @(posedge clk);
    reset = 0;

    // Ejemplo: escribir 0xA5 en LEDS y comprobar las salidas
    escribir(32'h0041_0004, 32'hA5);
    comprobar("salida leds", leds, 8'hA5);

    // Leer LEDS devuelve lo que se escribió (bits altos en 0)
    leer(32'h0041_0004, valor);
    comprobar("leer LEDS", valor, 32'h0000_00A5);

    // Solo se guardan los 8 bits bajos
    escribir(32'h0041_0004, 32'hFFFF_FF3C);
    comprobar("LEDS tras escribir FFFFFF3C", leds, 8'h3C);

    // Leer BOTONES
    botones = 4'b1001;
    leer(32'h0041_0008, valor);
    comprobar("leer BOTONES", valor, 32'h0000_0009);

    // Escribir en BOTONES no cambia los LEDs
    escribir(32'h0041_0008, 32'h0000_00FF);
    comprobar("LEDS tras escribir en BOTONES", leds, 8'h3C);

    // Una escritura a otro periférico (cs = 0) no cambia los LEDs
    escribir(32'h0042_0004, 32'h0000_0011);
    comprobar("LEDS tras escribir en 0x00420004", leds, 8'h3C);

    // Dirección sin registro: se lee 0
    leer(32'h0041_0010, valor);
    comprobar("leer 0x00410010", valor, 32'h0);

    // PARTE B: prueba del registro INVERTIR (0x0041_000C).
    //   1. Escribir 1 en INVERTIR y comprobar que leds sale invertido
    //      (en este punto LEDS vale 3C; invertido es C3).
    //   2. Leer 0x0041_000C y comprobar que devuelve 1.
    //   3. Escribir 0 en INVERTIR y comprobar que leds vuelve a 3C.

    // Reset apaga los LEDs
    reset = 1; @(negedge clk); reset = 0;
    comprobar("LEDS tras reset", leds, 8'h00);

    $display("--- %0d errores ---", errores);
    $finish;
  end

endmodule
