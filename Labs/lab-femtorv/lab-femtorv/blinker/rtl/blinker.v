// =============================================================================
// blinker.v — "Blinker desde memoria": un procesador sin decodificador
//
// Adaptado del paso 3 de "From Blinker to RISC-V" (Bruno Levy), que está en el
// repositorio del curso: fpga-example/colorlight-5a-75e/from-blinker-to-riscv-to-adapted
//
// Tres bloques que ya conocen del laboratorio de periféricos:
//   1. Divisor:  genera un pulso 'tick' unas pocas veces por segundo.
//   2. PC:       contador que avanza con cada tick: 0, 1, 2, ..., 20, 0, ...
//   3. ROM:      memoria de 21 palabras de 5 bits; la palabra MEM[PC] va a los LEDs.
//
// Un procesador real hace lo mismo: un PC recorre una memoria. La diferencia es
// que lo que lee no se muestra en LEDs: se DECODIFICA y se EJECUTA.
// =============================================================================
module blinker #(
    parameter DIV_BITS = 22  // tick cada 2^DIV_BITS ciclos de reloj
) (
    input        clk,
    input        resetn,     // 0 = reiniciar
    output [4:0] leds,       // 1 = encendido
    output [4:0] pc          // se saca para verlo en la simulación
);

  // ---------------------------------------------------------- 1. Divisor ---
  reg [DIV_BITS-1:0] divisor = 0;
  wire tick = (divisor == 0);
  always @(posedge clk) divisor <= divisor + 1;

  // --------------------------------------------- 2. Contador de programa ---
  reg [4:0] PC = 0;
  always @(posedge clk) begin
    if (!resetn) PC <= 0;
    else if (tick) PC <= (PC == 20) ? 0 : PC + 1;
  end
  assign pc = PC;

  // ------------------------------------------------------------- 3. ROM ---
  reg [4:0] MEM[0:20];
  initial begin
    MEM[0]  = 5'b00000;
    MEM[1]  = 5'b00001;
    MEM[2]  = 5'b00010;
    MEM[3]  = 5'b00100;
    MEM[4]  = 5'b01000;
    MEM[5]  = 5'b10000;
    MEM[6]  = 5'b10001;
    MEM[7]  = 5'b10010;
    MEM[8]  = 5'b10100;
    MEM[9]  = 5'b11000;
    MEM[10] = 5'b11001;
    MEM[11] = 5'b11010;
    MEM[12] = 5'b11100;
    MEM[13] = 5'b11101;
    MEM[14] = 5'b11110;
    MEM[15] = 5'b11111;
    MEM[16] = 5'b11110;
    MEM[17] = 5'b11100;
    MEM[18] = 5'b11000;
    MEM[19] = 5'b10000;
    MEM[20] = 5'b00000;
  end

  reg [4:0] dato;
  always @(posedge clk) dato <= MEM[PC];  // lectura síncrona: un ciclo de retardo
  assign leds = dato;

endmodule
