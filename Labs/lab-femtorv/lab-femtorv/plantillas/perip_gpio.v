// =============================================================================
// perip_gpio.v — Periférico GPIO de ejemplo (Semana 2)
//
// Este periférico YA FUNCIONA. En la Parte A de la semana 2 se lee, se prueba
// y se conecta al SoC. En la Parte B ustedes le agregan el registro INVERTIR
// en los cuatro lugares marcados con  PARTE B .
//
// Copie este archivo a soc/rtl/perip_gpio.v.
//
// Tabla de registros (base 0x0041_0000, cs[1]):
//
//   Dirección     Nombre    Acceso   Bits    Qué significa
//   0x0041_0004   LEDS      L/E      [7:0]   Patrón de los LEDs (1 = encendido). Reset: 0x00
//   0x0041_0008   BOTONES   L        [3:0]   Pulsadores (1 = presionado)
//   otra          —         —        —       Escribir no hace nada; leer da 0
//
// Tiene las mismas partes que el multiplicador (soc/rtl/mult/perip_mult.v):
// elegir el registro con addr[4:0], guardar al escribir y responder al leer.
// =============================================================================
module perip_gpio (
    input             clk,
    input             reset,    // activo en alto
    input      [31:0] d_in,     // dato que escribe el procesador (mem_wdata)
    input             cs,       // 1 cuando la dirección es 0x0041_xxxx
    input      [31:0] addr,     // dirección completa (solo se usan los bits bajos)
    input             rd,       // 1 cuando el procesador lee
    input             wr,       // 1 cuando el procesador escribe
    output reg [31:0] d_out,    // dato que devuelve al procesador
    input      [ 3:0] botones,  // pulsadores (vienen de afuera del SoC)
    output     [ 7:0] leds      // LEDs (van hacia afuera del SoC)
);

  // ---------------------------------------------------------------------------
  // REGISTROS: lo que el periférico recuerda.
  // ---------------------------------------------------------------------------
  reg [7:0] valor_leds;   // registro LEDS (0x0041_0004)
  // PARTE B (1 de 4): declare aquí el registro INVERTIR (1 bit)

  // ---------------------------------------------------------------------------
  // ESCRITURA: en el flanco de reloj en que el procesador escribe (cs y wr)
  // se guarda el dato en el registro que indica addr[4:0].
  // BOTONES no se puede escribir: no hay ningún registro que lo guarde.
  // ---------------------------------------------------------------------------
  always @(posedge clk) begin
    if (reset) begin
      valor_leds <= 8'b0;
      // PARTE B (2 de 4): el reset también pone INVERTIR en 0
    end else begin
      if (cs && wr && addr[4:0] == 5'h04)
        valor_leds <= d_in[7:0];          // LEDS guarda los 8 bits bajos
      // PARTE B (2 de 4): si escriben en 0x0C, INVERTIR guarda el bit 0 de d_in
    end
  end

  // ---------------------------------------------------------------------------
  // LECTURA: cuando el procesador lee (cs y rd), se pone en d_out el registro
  // que indica addr[4:0]. Los bits que no se usan se rellenan con ceros.
  // ---------------------------------------------------------------------------
  always @(posedge clk) begin
    if (cs && rd)
      case (addr[4:0])
        5'h04:   d_out <= {24'b0, valor_leds};  // LEDS:    8 bits + 24 ceros
        5'h08:   d_out <= {28'b0, botones};     // BOTONES: 4 bits + 28 ceros
        // PARTE B (3 de 4): leer 0x0C devuelve INVERTIR (1 bit + 31 ceros)
        default: d_out <= 32'b0;                // otra dirección: 0
      endcase
  end

  // ---------------------------------------------------------------------------
  // SALIDA: lo que llega a los pines de los LEDs.
  // ---------------------------------------------------------------------------
  assign leds = valor_leds;
  // PARTE B (4 de 4): si INVERTIR vale 1, los pines muestran ~valor_leds

endmodule
