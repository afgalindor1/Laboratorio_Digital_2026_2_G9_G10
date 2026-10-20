// =============================================================================
// chip_select.v — Decodificador de direcciones del SoC
//
// Tomado del repositorio del curso; solo se corrigieron los comentarios para
// que coincidan con las conexiones de SOC.v.
//
// Funciona en dos partes, ambas combinacionales:
//   1. Mira los 16 bits altos de mem_addr y activa UNA línea de cs (one-hot).
//   2. Usa cs para elegir qué dato (chipX_dout) vuelve al procesador.
// =============================================================================
module chip_select (
    input      [31:0] mem_addr,
    input      [31:0] chip0_dout,
    input      [31:0] chip1_dout,
    input      [31:0] chip2_dout,
    input      [31:0] chip3_dout,
    input      [31:0] chip4_dout,
    input      [31:0] chip5_dout,
    input      [31:0] chip6_dout,
    output reg [ 6:0] cs,
    output reg [31:0] mem_rdata
);

  localparam integer CHIP0ADDR = 16'h0040;  // UART
  localparam integer CHIP1ADDR = 16'h0041;  // libre (GPIO en la semana 2)
  localparam integer CHIP2ADDR = 16'h0042;  // multiplicador
  localparam integer CHIP3ADDR = 16'h0043;  // libre
  localparam integer CHIP4ADDR = 16'h0044;  // libre
  localparam integer CHIP5ADDR = 16'h0045;  // libre

  localparam integer CHIP0CS = 7'b0000001;
  localparam integer CHIP1CS = 7'b0000010;
  localparam integer CHIP2CS = 7'b0000100;
  localparam integer CHIP3CS = 7'b0001000;
  localparam integer CHIP4CS = 7'b0010000;
  localparam integer CHIP5CS = 7'b0100000;
  localparam integer CHIP6CS = 7'b1000000;  // RAM

  // 1. Decodificación: 16 bits altos de la dirección -> una línea de cs
  always @(*) begin
    case (mem_addr[31:16])
      CHIP0ADDR: cs = CHIP0CS;  // 0x0040_xxxx -> UART
      CHIP1ADDR: cs = CHIP1CS;  // 0x0041_xxxx -> libre (GPIO)
      CHIP2ADDR: cs = CHIP2CS;  // 0x0042_xxxx -> multiplicador
      CHIP3ADDR: cs = CHIP3CS;  // 0x0043_xxxx -> libre
      CHIP4ADDR: cs = CHIP4CS;  // 0x0044_xxxx -> libre
      CHIP5ADDR: cs = CHIP5CS;  // 0x0045_xxxx -> libre
      default:   cs = CHIP6CS;  // cualquier otra -> RAM
    endcase
  end

  // 2. Multiplexor de lectura: el dato del bloque seleccionado vuelve al CPU
  always @(*) begin
    case (cs)
      CHIP0CS: mem_rdata = chip0_dout;
      CHIP1CS: mem_rdata = chip1_dout;
      CHIP2CS: mem_rdata = chip2_dout;
      CHIP3CS: mem_rdata = chip3_dout;
      CHIP4CS: mem_rdata = chip4_dout;
      CHIP5CS: mem_rdata = chip5_dout;
      CHIP6CS: mem_rdata = chip6_dout;
      default: mem_rdata = 32'h66666666;
    endcase
  end

endmodule
