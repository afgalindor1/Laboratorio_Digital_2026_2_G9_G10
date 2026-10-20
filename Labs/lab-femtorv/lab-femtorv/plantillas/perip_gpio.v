// =============================================================================
// perip_gpio.v — PLANTILLA del periférico GPIO (Semana 2)
//
// Copie este archivo a soc/rtl/perip_gpio.v y complete las partes marcadas
// con  /* COMPLETAR */ . Mientras queden marcas, el diseño NO compila.
//
// El periférico tiene dos registros que el procesador ve como memoria:
//
//   Desplazamiento  Nombre    Acceso   Contenido
//   +0x04           LEDS      L/E      bits [7:0]: LEDs externos (1 = encendido)
//   +0x08           BOTONES   L        bits [3:0]: pulsadores (1 = presionado)
//
// Use como guía soc/rtl/mult/perip_mult.v: tiene las mismas tres partes.
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
    output reg [ 7:0] leds      // LEDs (van hacia afuera del SoC)
);

  // ---------------------------------------------------------------------------
  // PARTE 1. Decodificador interno: ¿a cuál registro va el acceso?
  // Use los 5 bits bajos de addr, igual que perip_mult.v.
  // ---------------------------------------------------------------------------
  wire sel_leds    = cs && (addr[4:0] == /* COMPLETAR: desplazamiento de LEDS */);
  wire sel_botones = cs && (addr[4:0] == /* COMPLETAR: desplazamiento de BOTONES */);

  // ---------------------------------------------------------------------------
  // PARTE 2. Escritura: el procesador guarda un valor en el registro LEDS.
  // Solo cambia en el flanco de reloj en que hay escritura (wr) a ese registro.
  // ---------------------------------------------------------------------------
  always @(posedge clk) begin
    if (reset)
      leds <= 8'b0;
    else if (/* COMPLETAR: condición de escritura en LEDS */)
      leds <= /* COMPLETAR: ¿qué bits de d_in? */;
  end

  // ---------------------------------------------------------------------------
  // PARTE 3. Lectura: el procesador pide un registro y el periférico pone su
  // valor en d_out. Los bits que no se usan deben quedar en 0.
  // ---------------------------------------------------------------------------
  always @(posedge clk) begin
    if (rd) begin
      if (sel_leds)
        d_out <= /* COMPLETAR: 32 bits con el valor de leds */;
      else if (sel_botones)
        d_out <= /* COMPLETAR: 32 bits con el valor de botones */;
      else
        d_out <= 32'b0;
    end
  end

endmodule
