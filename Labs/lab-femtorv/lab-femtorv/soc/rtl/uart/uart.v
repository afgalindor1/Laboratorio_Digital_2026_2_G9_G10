module uart #(
    parameter freq_hz = 12000000,
    parameter baud    = 9600
) (
    input        reset,
    input        clk,
    input        uart_rxd,
    output       uart_txd,
    output [7:0] rx_data,
    output       rx_avail,
    output       rx_error,
    input        rx_ack,
    input  [7:0] tx_data,
    input        tx_wr,
    output       tx_busy
);
  // Generador de la velocidad (enable16: 16 pulsos por bit)
  // Acumulador de fase: suma baud*16 en cada ciclo y da un pulso cada vez que
  // pasa de freq_hz. Así la velocidad promedio es exacta aunque freq_hz no sea
  // múltiplo de baud*16 (por ejemplo, 27 MHz a 115200 baudios). La versión
  // anterior dividía con números enteros y a 27 MHz / 115200 se equivocaba un 4,6 %.
  localparam integer BAUD16 = baud * 16;
  reg [31:0] acumulador;
  reg        enable16;

  always @(posedge clk) begin
    if (reset) begin
      acumulador <= 0;
      enable16   <= 0;
    end else if (acumulador + BAUD16 >= freq_hz) begin
      acumulador <= acumulador + BAUD16 - freq_hz;
      enable16   <= 1;
    end else begin
      acumulador <= acumulador + BAUD16;
      enable16   <= 0;
    end
  end

  // Synchronize RXD
  reg uart_rxd1, uart_rxd2;
  always @(posedge clk) begin
    uart_rxd1 <= uart_rxd;
    uart_rxd2 <= uart_rxd1;
  end

  // Instancia del receptor
  uart_rx uart_rx_inst (
      .clk     (clk),
      .reset   (reset),
      .enable16(enable16),
      .uart_rxd(uart_rxd2),
      .rx_data (rx_data),
      .rx_avail(rx_avail),
      .rx_error(rx_error),
      .rx_ack  (rx_ack)
  );

  // Instancia del transmisor
  uart_tx uart_tx_inst (
      .clk     (clk),
      .reset   (reset),
      .enable16(enable16),
      .tx_data (tx_data),
      .tx_wr   (tx_wr),
      .uart_txd(uart_txd),
      .tx_busy (tx_busy)
  );

endmodule

module uart_rx (
    input            clk,
    input            reset,
    input            enable16,
    input            uart_rxd,
    output reg [7:0] rx_data,
    output reg       rx_avail,
    output reg       rx_error,
    input            rx_ack
);
  localparam integer DATA_BITS = 8;

  reg       rx_busy;
  reg [3:0] rx_count16;
  reg [3:0] rx_bitcount;
  reg [7:0] rxd_reg;

  always @(posedge clk) begin
    if (reset) begin
      rx_busy     <= 0;
      rx_count16  <= 0;
      rx_bitcount <= 0;
      rx_avail    <= 0;
      rx_error    <= 0;
    end else begin
      if (rx_ack) begin
        rx_avail <= 0;
        rx_error <= 0;
      end

      if (enable16) begin
        if (!rx_busy) begin
          if (!uart_rxd) begin
            rx_busy     <= 1;
            rx_count16  <= 7;
            rx_bitcount <= 0;
          end
        end else begin
          rx_count16 <= rx_count16 + 1;

          if (rx_count16 == 0) begin
            rx_bitcount <= rx_bitcount + 1;

            case (rx_bitcount)
              0: if (uart_rxd) rx_busy <= 0;  // invalid start bit
              DATA_BITS + 1: begin
                rx_busy <= 0;
                if (uart_rxd) begin
                  rx_data  <= rxd_reg;
                  rx_avail <= 1;
                  rx_error <= 0;
                end else begin
                  rx_error <= 1;
                end
              end
              default: rxd_reg <= {uart_rxd, rxd_reg[7:1]};
            endcase
          end
        end
      end
    end
  end
endmodule

module uart_tx (
    input            clk,
    input            reset,
    input            enable16,
    input      [7:0] tx_data,
    input            tx_wr,
    output reg       uart_txd,
    output reg       tx_busy
);
  localparam integer DATA_BITS = 8;

  reg [3:0] tx_bitcount;
  reg [3:0] tx_count16;
  reg [7:0] txd_reg;

  always @(posedge clk) begin
    if (reset) begin
      tx_busy    <= 0;
      uart_txd   <= 1;
      tx_count16 <= 0;
    end else begin
      if (tx_wr && !tx_busy) begin
        txd_reg     <= tx_data;
        tx_bitcount <= 0;
        tx_count16  <= 0;
        tx_busy     <= 1;
      end

      if (enable16 && tx_busy) begin
        tx_count16 <= tx_count16 + 1;

        if (tx_count16 == 0) begin
          tx_bitcount <= tx_bitcount + 1;

          case (tx_bitcount)
            0: uart_txd <= 0;  // start bit
            DATA_BITS + 1: uart_txd <= 1;  // stop bit
            DATA_BITS + 2: begin
              uart_txd <= 1;
              tx_busy  <= 0;
            end
            default: begin
              uart_txd <= txd_reg[0];
              txd_reg  <= {1'b0, txd_reg[7:1]};
            end
          endcase
        end
      end
    end
  end
endmodule
