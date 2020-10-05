module spi_master_top
    # (
        parameter SPI_CLOCK_DIVIDER_WIDTH   = 4,
        parameter SPI_DATA_WIDTH            = 8
    )
    (
        // Clock, reset
        input           i_clock,
        input           i_reset,
        // Data, control and status interface
        input                                   i_enable,
        input                                   i_interrupt_enable,
        input                                   i_clock_polarity,
        input                                   i_clock_phase,
        input   [SPI_CLOCK_DIVIDER_WIDTH-1 : 0] i_spi_clock_divider,
        input   [SPI_DATA_WIDTH-1 : 0]          i_data_in,
        output  [SPI_DATA_WIDTH-1 : 0]          o_data_out,
        output                                  o_done,
        // SPI interface
        output          o_spi_cs_n,
        output          o_spi_clock,
        output          o_spi_mosi,
        input           i_spi_miso
    );

    timeunit 1ns;
    timeprecision 1ps;

    // Clock generation
    logic [SPI_CLOCK_DIVIDER_WIDTH-1 : 0] clock_counter;
    logic spi_clock;
    always_ff @ (posedge i_clock) begin
        if (i_reset) begin
            spi_clock <= 1'b0;
            clock_counter <= 'b0;
        end else begin
            if (i_clock_polarity) begin
                spi_clock <= 1'b1;
            end else begin
                spi_clock <= 1'b0;
            end
            if (~ i_enable) begin
                spi_clock <= 1'b0;
                clock_counter <= 'b0;
            end else begin
                clock_counter <= clock_counter + 1;
                if (clock_counter == (i_spi_clock_divider-1)) begin
                    spi_clock <= ~ spi_clock;
                end
            end
        end
    end
    assign o_spi_clock = spi_clock;

    // SPI clock edge detection
    logic spi_clock_falling;
    logic spi_clock_rising;
    logic spi_clock_ff;
    always_ff @(posedge i_clock) begin
        spi_clock_ff <= spi_clock;
        spi_clock_falling <= 1'b0;
        spi_clock_rising <= 1'b0;
        if ((spi_clock == 1'b1) && (spi_clock_ff == 1'b0)) begin   // Rising edge
            spi_clock_rising <= 1'b1;
        end
        if ((spi_clock == 1'b0) && (spi_clock_ff == 1'b1)) begin   // Falling edge
            spi_clock_falling <= 1'b1;
        end
    end

    // Data transmission
    logic [SPI_DATA_WIDTH-1 : 0] spi_data_counter;
    logic spi_cs_n;
    logic [SPI_DATA_WIDTH-1 : 0] data_out;
    logic done;
    logic spi_mosi;
    always_ff @(posedge i_clock) begin
        if (i_reset) begin
            spi_data_counter <= 'b0;
            spi_cs_n <= 1'b1;
            data_out <= 'b0;
            done <= 1'b0;
            spi_mosi <= 1'b0;
        end else begin
            if (~ i_enable) begin
                spi_data_counter <= 'b0;
                spi_cs_n <= 1'b1;
            end else begin
                spi_cs_n <= 1'b0;
                if (~ spi_cs_n) begin
                    if (i_clock_phase) begin            // Clock phase = 1
                        if (i_clock_polarity) begin     // Clock polarity = 1
                            if (spi_clock_falling) begin
                                spi_data_counter <= spi_data_counter + 1;
                                if (spi_data_counter == 8) begin // TODO: parameterize the upper boundary
                                    spi_cs_n <= 1'b1;
                                    spi_data_counter <= 'b0;
                                end
                            end
                        end else begin                  // Clock polarity = 0
                            if (spi_clock_rising) begin
                                spi_data_counter <= spi_data_counter + 1;
                                if (spi_data_counter == 8) begin // TODO: parameterize the upper boundary
                                    spi_cs_n <= 1'b1;
                                    spi_data_counter <= 'b0;
                                end
                            end
                        end
                    end else begin                      // Clock phase = 0
                        if (i_clock_polarity) begin     // Clock polarity = 1
                            if (spi_clock_falling) begin
                                spi_data_counter <= spi_data_counter + 1;
                                if (spi_data_counter == 8) begin // TODO: parameterize the upper boundary
                                    spi_cs_n <= 1'b1;
                                    spi_data_counter <= 'b0;
                                end
                            end
                        end else begin                  // Clock polarity = 0
                            if (spi_clock_falling) begin
                                spi_data_counter <= spi_data_counter + 1;
                                if (spi_data_counter == 8) begin // TODO: parameterize the upper boundary
                                    spi_cs_n <= 1'b1;
                                    spi_data_counter <= 'b0;
                                end
                            end
                        end 
                    end
                end
            end
        end
    end
    assign o_spi_cs_n = spi_cs_n;
    assign o_data_out = data_out;
    assign o_done = done;
    assign o_spi_mosi = spi_mosi;

endmodule