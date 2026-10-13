// =============================================================================
// parpadeo_dos_velocidades.v
// -----------------------------------------------------------------------------
// EJEMPLO RESUELTO de la metodologia de diseno (ver 12_Ejemplo_resuelto.md).
//
// Especificacion:
//   - Un LED parpadea de forma continua.
//   - Con el interruptor sw_rapido = 0, parpadea a 1 Hz (0.5 s encendido,
//     0.5 s apagado). Con sw_rapido = 1, parpadea a 4 Hz (0.125 s / 0.125 s).
//   - El pulsador de reset (activo en bajo) apaga el LED y reinicia la cuenta.
//
// Sirve tambien para VERIFICAR CLK_FREQ en la tarjeta: con sw_rapido = 0 el
// LED debe hacer 60 parpadeos en 60 segundos.
// =============================================================================
module parpadeo_dos_velocidades #(
    parameter CLK_FREQ = 25_000_000          // Hz: frecuencia del oscilador de la tarjeta
)(
    input  wire clk,                         // reloj de la tarjeta
    input  wire rst_n,                       // pulsador de reset, activo en bajo
    input  wire sw_rapido,                   // interruptor: 0 = 1 Hz, 1 = 4 Hz
    output reg  led                          // LED que parpadea
);

    // ---- Cuentas (etapa 3 de la metodologia) --------------------------------
    // El LED cambia de estado cada medio periodo:
    //   1 Hz -> medio periodo de 0.5 s   -> CLK_FREQ / 2 ciclos
    //   4 Hz -> medio periodo de 0.125 s -> CLK_FREQ / 8 ciclos
    localparam N_LENTO  = CLK_FREQ / 2;
    localparam N_RAPIDO = CLK_FREQ / 8;
    localparam ANCHO    = $clog2(N_LENTO);   // bits del contador (24 a 25 MHz)

    // ---- Entradas externas: invertir y sincronizar --------------------------
    // Variables que se recuerdan: 2 flip-flops por cada entrada externa.
    reg [1:0] ent_meta, ent_sync;            // {reset, interruptor}

    always @(posedge clk) begin
        ent_meta <= {~rst_n, sw_rapido};     // 1er flip-flop: captura
        ent_sync <= ent_meta;                // 2do flip-flop: copia estable
    end

    wire rst    = ent_sync[1];               // 1 = reset activo
    wire rapido = ent_sync[0];               // 1 = modo rapido

    // ---- Mux de constantes: limite de la cuenta segun la velocidad ----------
    // Combinacional: no tiene memoria.
    wire [ANCHO-1:0] limite = rapido ? N_RAPIDO : N_LENTO;

    // ---- Contador de medio periodo ------------------------------------------
    // Variable que se recuerda: la cuenta -> ANCHO flip-flops.
    reg  [ANCHO-1:0] cnt;
    wire fin = (cnt >= limite - 1);          // comparador: termino el medio periodo

    always @(posedge clk) begin
        if (rst || fin)                      // reset o fin de medio periodo...
            cnt <= 0;                        // ...vuelve a 0
        else
            cnt <= cnt + 1;                  // ...si no, sigue contando
    end
    // Se usa >= y no ==: si se pasa de lento a rapido cuando cnt ya supero el
    // nuevo limite, con == el contador seguiria hasta desbordarse.

    // ---- LED: se invierte cada medio periodo --------------------------------
    // Variable que se recuerda: el estado del LED -> 1 flip-flop.
    always @(posedge clk) begin
        if (rst)
            led <= 1'b0;
        else if (fin)
            led <= ~led;
    end

endmodule
