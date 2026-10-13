// =============================================================================
// tb_parpadeo_dos_velocidades.v
// -----------------------------------------------------------------------------
// Testbench del ejemplo resuelto. Verifica automaticamente la tabla de
// especificaciones:
//   E1. Con sw_rapido = 0, el LED cambia cada 0.5 s.
//   E2. Con sw_rapido = 1, el LED cambia cada 0.125 s.
//   E3. Con reset, el LED queda apagado.
//
// Simular (desde esta carpeta):
//   iverilog -o sim.vvp tb_parpadeo_dos_velocidades.v parpadeo_dos_velocidades.v
//   vvp sim.vvp
//   gtkwave tb_parpadeo_dos_velocidades.vcd
// =============================================================================
`timescale 1ns/1ps                           // #1 = 1 ns

module tb_parpadeo_dos_velocidades;

    // ---- Reloj de simulacion reducido: 1 kHz --------------------------------
    // El intervalo mas corto del diseno (0.125 s) dura 125 ciclos: resolucion
    // suficiente, y un segundo simulado son solo 1000 ciclos.
    localparam CLK_FREQ_TB = 1_000;                          // Hz
    localparam T_CLK       = 1_000_000_000 / CLK_FREQ_TB;    // 1 ms en ns

    reg  clk       = 1'b0;
    reg  rst_n     = 1'b0;                   // reset presionado al inicio
    reg  sw_rapido = 1'b0;                   // empieza en modo lento
    wire led;

    always #(T_CLK/2) clk = ~clk;            // generador de reloj

    // ---- Diseno bajo prueba --------------------------------------------------
    parpadeo_dos_velocidades #(.CLK_FREQ(CLK_FREQ_TB)) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .sw_rapido(sw_rapido),
        .led      (led)
    );

    // ---- Tarea: mide el tiempo entre dos cambios del LED ---------------------
    integer errores = 0;

    task medir_medio_periodo;
        input [8*16-1:0] nombre;             // texto para el mensaje
        input integer    esperado_ns;
        time t1, t2;
        begin
            @(led);                          // espera un cambio (sincroniza)
            @(led) t1 = $time;               // primer cambio medido
            @(led) t2 = $time;               // segundo cambio medido
            if (t2 - t1 == esperado_ns)
                $display("OK:    %0s: medio periodo = %0d ns", nombre, t2 - t1);
            else begin
                $display("ERROR: %0s: medio periodo = %0d ns (esperado %0d)",
                         nombre, t2 - t1, esperado_ns);
                errores = errores + 1;
            end
        end
    endtask

    // ---- Estimulos y verificaciones ------------------------------------------
    initial begin
        $dumpfile("tb_parpadeo_dos_velocidades.vcd");
        $dumpvars(0, tb_parpadeo_dos_velocidades);

        #(10*T_CLK) rst_n = 1'b1;            // suelta el reset

        medir_medio_periodo("E1 lento", 500_000_000);    // 0.5 s

        sw_rapido = 1'b1;                    // cambia a rapido
        medir_medio_periodo("E2 rapido", 125_000_000);   // 0.125 s

        rst_n = 1'b0;                        // presiona reset
        #(10*T_CLK);
        if (led === 1'b0)
            $display("OK:    E3 reset: LED apagado");
        else begin
            $display("ERROR: E3 reset: LED = %b", led);
            errores = errores + 1;
        end

        if (errores == 0) $display("Simulacion correcta: 0 errores");
        else              $display("Simulacion con %0d errores", errores);
        $finish;
    end

endmodule
