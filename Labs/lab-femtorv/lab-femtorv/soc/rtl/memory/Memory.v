// =============================================================================
// Memory.v — RAM del SoC (programa, datos y pila)
//
// Tomada del repositorio del curso. Cambio: el tamaño es un parámetro
// (8192 palabras de 32 bits = 32 KB), igual al definido en linker.ld.
//
// Al iniciar, $readmemh copia firmware.hex en la memoria: así el programa
// compilado queda "dentro" del bitstream de la FPGA.
// =============================================================================
module Memory #(
    parameter WORDS = 8192  // 8192 x 4 bytes = 32 KB
) (
    input             clk,
    input      [31:0] mem_addr,   // dirección (en bytes)
    output reg [31:0] mem_rdata,  // dato leído
    input             mem_rstrb,  // 1 cuando el procesador quiere leer
    input      [31:0] mem_wdata,  // dato a escribir
    input      [ 3:0] mem_wmask   // bytes a escribir (1 = escribir ese byte)
);

  reg [31:0] MEM[0:WORDS-1];

  initial begin
    $readmemh("firmware.hex", MEM);
  end

  // La memoria se organiza en palabras de 4 bytes:
  // los 2 bits bajos de la dirección eligen el byte dentro de la palabra.
  wire [29:0] word_addr = mem_addr[31:2];

  always @(posedge clk) begin
    if (mem_rstrb) begin
      mem_rdata <= MEM[word_addr];
    end
    if (mem_wmask[0]) MEM[word_addr][7:0] <= mem_wdata[7:0];
    if (mem_wmask[1]) MEM[word_addr][15:8] <= mem_wdata[15:8];
    if (mem_wmask[2]) MEM[word_addr][23:16] <= mem_wdata[23:16];
    if (mem_wmask[3]) MEM[word_addr][31:24] <= mem_wdata[31:24];
  end
endmodule
