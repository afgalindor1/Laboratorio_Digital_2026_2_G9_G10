// =============================================================================
// SOC.v — Sistema en chip (SoC) con el procesador FemtoRV32 Quark (RV32I)
//
// Basado en el SoC del repositorio del curso:
//   johnnycubides/digital-electronic-1-101/fpga-example/colorlight-5a-75e/femtoriscv
//
// Bloques:
//   CPU          FemtoRV32 Quark: ejecuta el programa (instrucciones RV32I)
//   chip_select  Decodificador de direcciones: decide qué bloque atiende cada acceso
//   RAM          Memoria de programa y datos (32 KB), cargada con firmware.hex
//   UART         Comunicación serial con el PC
//   MULT         Multiplicador por hardware (ejemplo y plantilla de periférico)
//
// MAPA DE MEMORIA (los 16 bits altos de la dirección eligen el bloque):
//   0x0040_xxxx  chip0  UART
//   0x0041_xxxx  chip1  LIBRE  <-- Semana 2: aquí va su periférico GPIO
//   0x0042_xxxx  chip2  Multiplicador
//   0x0043_xxxx  chip3  LIBRE
//   0x0044_xxxx  chip4  LIBRE
//   0x0045_xxxx  chip5  LIBRE
//   cualquier otra      RAM (en la práctica, 0x0000_0000 a 0x0000_7FFF)
// =============================================================================
module SOC #(
    parameter CLK_FREQ = 25_000_000,  // Frecuencia del reloj en Hz (la fija cada tarjeta)
    parameter BAUD     = 115200       // Velocidad de la UART en baudios
) (
    input        clk,       // Reloj del sistema
    input        resetn,    // Reset activo en bajo (0 = reiniciar)
    output [0:0] LEDS,      // LED controlado por el bit 2 del control de la UART
    input        RXD,       // UART: recepción
    output       TXD,       // UART: transmisión
    input  [3:0] BOTONES,   // Pulsadores externos (1 = presionado)
    output [7:0] LEDS_EXT   // LEDs externos (1 = encendido)
);

  // ===========================================================================
  // 1. PROCESADOR
  // El bus de memoria tiene 5 señales principales:
  //   mem_addr   dirección que el procesador quiere leer o escribir
  //   mem_wdata  dato que el procesador quiere escribir
  //   mem_wmask  qué bytes se escriben (0000 = no es una escritura)
  //   mem_rstrb  pulso que indica una lectura
  //   mem_rdata  dato que llega al procesador cuando lee
  // ===========================================================================
  wire [31:0] mem_addr;
  wire [31:0] mem_rdata;
  wire        mem_rstrb;
  wire [31:0] mem_wdata;
  wire [ 3:0] mem_wmask;

  FemtoRV32 CPU (
      .clk      (clk),
      .reset    (resetn),
      .mem_addr (mem_addr),
      .mem_rdata(mem_rdata),
      .mem_rstrb(mem_rstrb),
      .mem_wdata(mem_wdata),
      .mem_wmask(mem_wmask),
      .mem_rbusy(1'b0),
      .mem_wbusy(1'b0)
  );

  // Señales de lectura y escritura comunes a todos los periféricos
  wire wr = |mem_wmask;  // 1 si el procesador está escribiendo
  wire rd = mem_rstrb;   // 1 si el procesador está leyendo

  // ===========================================================================
  // 2. DECODIFICADOR DE DIRECCIONES (chip select)
  // Activa UNA señal cs según la dirección, y devuelve al procesador el dato
  // del bloque seleccionado.
  // ===========================================================================
  wire [6:0] cs;
  wire cs_uart  = cs[0];  // 0x0040_xxxx
  wire cs_chip1 = cs[1];  // 0x0041_xxxx  (libre)
  wire cs_mult  = cs[2];  // 0x0042_xxxx
  wire cs_chip3 = cs[3];  // 0x0043_xxxx  (libre)
  wire cs_chip4 = cs[4];  // 0x0044_xxxx  (libre)
  wire cs_chip5 = cs[5];  // 0x0045_xxxx  (libre)
  wire cs_ram   = cs[6];  // cualquier otra dirección

  wire [31:0] uart_dout;
  wire [31:0] mult_dout;
  wire [31:0] RAM_rdata;

  chip_select chip_select (
      .mem_addr  (mem_addr),
      .chip0_dout(uart_dout),  // 0x0040_xxxx
      .chip1_dout(32'b0),      // 0x0041_xxxx  <-- Semana 2: conecte aquí la salida de su periférico
      .chip2_dout(mult_dout),  // 0x0042_xxxx
      .chip3_dout(32'b0),      // 0x0043_xxxx
      .chip4_dout(32'b0),      // 0x0044_xxxx
      .chip5_dout(32'b0),      // 0x0045_xxxx
      .chip6_dout(RAM_rdata),  // RAM
      .cs        (cs),
      .mem_rdata (mem_rdata)
  );

  // ===========================================================================
  // 3. MEMORIA RAM (programa + datos + pila)
  // ===========================================================================
  Memory RAM (
      .clk      (clk),
      .mem_addr (mem_addr),
      .mem_rdata(RAM_rdata),
      .mem_rstrb(cs_ram & rd),
      .mem_wdata(mem_wdata),
      .mem_wmask({4{cs_ram}} & mem_wmask)
  );

  // ===========================================================================
  // 4. PERIFÉRICO UART  (base 0x0040_0000)
  //   +0x08  DATO     escribir: byte a transmitir   | leer: byte recibido
  //   +0x10  CONTROL  escribir: bit0 = transmitir, bit1 = confirmar recepción,
  //                             bit2 = LED de la tarjeta
  //                   leer:     bit9 = transmisor ocupado, bit8 = dato recibido,
  //                             bit7 = error de recepción
  // ===========================================================================
  peripheral_uart #(
      .clk_freq(CLK_FREQ),
      .baud    (BAUD)
  ) per_uart (
      .clk    (clk),
      .rst    (!resetn),
      .d_in   (mem_wdata),
      .cs     (cs_uart),
      .addr   (mem_addr),
      .rd     (rd),
      .wr     (wr),
      .d_out  (uart_dout),
      .uart_tx(TXD),
      .uart_rx(RXD),
      .ledout (LEDS[0])
  );

  // ===========================================================================
  // 5. PERIFÉRICO MULTIPLICADOR  (base 0x0042_0000)
  //   +0x04  A        operando A (16 bits)
  //   +0x08  B        operando B (16 bits)
  //   +0x0C  INIT     escribir 1 y luego 0 para iniciar
  //   +0x10  RESULT   resultado (32 bits)
  //   +0x14  DONE     1 cuando terminó
  //   ¡Cuidado! El resultado solo se conserva unos 30 ciclos después de DONE.
  // ===========================================================================
  peripheral_mult mult1 (
      .clk  (clk),
      .reset(!resetn),
      .d_in (mem_wdata),
      .cs   (cs_mult),
      .addr (mem_addr),
      .rd   (rd),
      .wr   (wr),
      .d_out(mult_dout)
  );

  // ===========================================================================
  // 6. PERIFÉRICO GPIO  (base 0x0041_0000)  <-- SEMANA 2
  //   Mientras no exista el periférico, los LEDs externos quedan apagados.
  //   Reemplace esta asignación por la instancia de su periférico perip_gpio.
  // ===========================================================================
  assign LEDS_EXT = 8'b0;

endmodule
