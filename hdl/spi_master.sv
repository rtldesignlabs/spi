module spi_master
    # (
        parameter SPI_CLOCK_DIVIDER_WIDTH   = 8,
        parameter SPI_DATA_WIDTH            = 8
    )
    (
        // Clock, reset
        input   logic   i_clock,
        input   logic   i_reset,
        // Data, control and status interface
        input   logic                                   i_enable,
        input   logic                                   i_clock_polarity,
        input   logic                                   i_clock_phase,
        input   logic [SPI_CLOCK_DIVIDER_WIDTH-1 : 0]   i_spi_clock_divider,
        input   logic [SPI_DATA_WIDTH-1 : 0]            i_data_in,
        output  logic [SPI_DATA_WIDTH-1 : 0]            o_data_out,
        output  logic                                   o_done,
        output  logic                                   o_busy,
        // SPI interface
        output  logic   o_spi_cs_n,
        output  logic   o_spi_clock,
        output  logic   o_spi_mosi,
        input   logic   i_spi_miso
    );

    timeunit 1ns;
    timeprecision 1ps;

    enum logic [2:0]    {IDLE,
                        PRE_DELAY,
                        SETUP,
                        TRANSMISSION,
                        POST_DELAY,
                        DONE} fsm_state;
    logic [SPI_DATA_WIDTH-1 : 0] spi_data_counter;

    // Clock generation
    logic [SPI_CLOCK_DIVIDER_WIDTH-1 : 0] clock_counter;
    logic spi_clock;
    always_ff @ (posedge i_clock) begin
        if (i_reset) begin
            spi_clock <= 1'b0;
            clock_counter <= 'b0;
        end else begin
            if ((fsm_state == TRANSMISSION) || (fsm_state == PRE_DELAY) || (fsm_state == POST_DELAY)) begin
                clock_counter <= clock_counter + 1;
                if (clock_counter == (i_spi_clock_divider)) begin
                    if (fsm_state == TRANSMISSION) begin
                        spi_clock <= ~ spi_clock;
                    end
                    clock_counter <= 'b0;
                end
            end else begin
                if (i_clock_polarity) begin
                    spi_clock <= 1'b1;
                end else begin
                    spi_clock <= 1'b0;
                end
                clock_counter <= 'b0;
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

    // Main FSM
    logic enable_delay1;
    logic enable_delay2;
    logic enable_rising;
    logic spi_cs_n;
    logic [SPI_DATA_WIDTH-1 : 0] data_out_shift;
    logic [SPI_DATA_WIDTH-1 : 0] data_in_shift;
    logic spi_mosi;
    logic done;
    always_ff @(posedge i_clock) begin
        if (i_reset) begin
            fsm_state <= IDLE;
            spi_data_counter <= 'b0;
            spi_cs_n <= 1'b1;
            data_out_shift <= 'b0;
            done <= 1'b0;
            spi_mosi <= 1'b0;
            data_out_shift <= 'b0;
            o_data_out <= 'b0;
            o_busy <= 'b0;
        end else begin
            // Detecting the rising edge of the 'i_enable' signal - BEGIN
                enable_delay1 <= i_enable;
                enable_delay2 <= enable_delay1;
                enable_rising <= 1'b0;
                if ((enable_delay2 == 1'b0) && (enable_delay1 == 1'b1)) begin
                    enable_rising <= 1'b1;
                end
            // Detecting the rising edge of the 'i_enable' signal - END
            case (fsm_state)
                IDLE : begin
                    spi_cs_n <= 'b1;
                    o_busy <= 'b0;
                    if (enable_rising) begin
                        fsm_state <= PRE_DELAY;
                        data_out_shift <= i_data_in;
                        data_in_shift <= 'b0;
                        o_busy <= 'b1;
                    end
                end

                PRE_DELAY : begin
                    spi_cs_n <= 'b0;
                    if (clock_counter == (i_spi_clock_divider - 1)) begin
                        fsm_state <= SETUP;
                    end
                end

                SETUP : begin
                    if (~i_clock_phase) begin
                        spi_data_counter <= spi_data_counter + 1;
                        spi_mosi <= data_out_shift[$size(data_out_shift)-1];
                        data_out_shift <= data_out_shift << 1;
                    end
                    fsm_state <= TRANSMISSION;
                end

                TRANSMISSION : begin
                    if (i_clock_phase && i_clock_polarity) begin
                        if (spi_clock_rising == 'b1) begin      // Capture MISO data
                            data_in_shift <= {data_in_shift[$size(data_in_shift)-2:0], i_spi_miso};
                        end
                        if (spi_clock_falling == 'b1) begin
                            spi_data_counter <= spi_data_counter + 1;
                            spi_mosi <= data_out_shift[$size(data_out_shift)-1];
                            data_out_shift <= data_out_shift << 1;
                        end
                        if ((spi_data_counter == SPI_DATA_WIDTH) && (clock_counter == (i_spi_clock_divider-1)) && (spi_clock)) begin
                            spi_data_counter <= 'b0;
                            fsm_state <= POST_DELAY;
                        end
                    end
                    if (i_clock_phase && (~i_clock_polarity)) begin
                        if (spi_clock_falling == 'b1) begin      // Capture MISO data
                            data_in_shift <= {data_in_shift[($size(data_in_shift)-1):0], i_spi_miso};
                        end
                        if (spi_clock_rising == 'b1) begin
                            spi_data_counter <= spi_data_counter + 1;
                            spi_mosi <= data_out_shift[$size(data_out_shift)-1];
                            data_out_shift <= data_out_shift << 1;
                        end
                        if ((spi_data_counter == SPI_DATA_WIDTH) && (clock_counter == (i_spi_clock_divider-1)) && (~spi_clock)) begin
                            spi_data_counter <= 'b0;
                            fsm_state <= POST_DELAY;
                        end
                    end
                    if ((~i_clock_phase) && i_clock_polarity) begin
                        if (spi_clock_falling == 'b1) begin      // Capture MISO data
                            data_in_shift <= {data_in_shift[($size(data_out_shift)-2):0], i_spi_miso};
                        end
                        if (spi_clock_rising == 'b1) begin
                            spi_data_counter <= spi_data_counter + 1;
                            spi_mosi <= data_out_shift[$size(data_out_shift)-1];
                            data_out_shift <= data_out_shift << 1;
                        end
                        if ((spi_data_counter == SPI_DATA_WIDTH) && (spi_clock_rising)) begin
                            spi_data_counter <= 'b0;
                            fsm_state <= POST_DELAY;
                        end
                    end
                    if ((~i_clock_phase) && (~i_clock_polarity)) begin
                        if (spi_clock_rising == 'b1) begin      // Capture MISO data
                            data_in_shift <= {data_in_shift[($size(data_in_shift)-1):0], i_spi_miso};
                        end
                        if (spi_clock_falling == 'b1) begin
                            spi_data_counter <= spi_data_counter + 1;
                            spi_mosi <= data_out_shift[$size(data_out_shift)-1];
                            data_out_shift <= data_out_shift << 1;
                        end
                        if ((spi_data_counter == SPI_DATA_WIDTH) && (spi_clock_falling)) begin
                            spi_data_counter <= 'b0;
                            fsm_state <= POST_DELAY;
                        end
                    end
                end

                POST_DELAY : begin
                    if (clock_counter == (i_spi_clock_divider - 1)) begin
                        spi_cs_n <= 'b1;
                        fsm_state <= DONE;
                    end
                end

                DONE : begin
                    done <= 'b1;
                    o_data_out <= data_in_shift;
                    if (done) begin
                        done <= 'b0;
                        fsm_state <= IDLE;
                    end
                end

                default : begin
                    fsm_state <= IDLE;
                end
            endcase
        end
    end
    assign o_done = done;
    assign o_spi_cs_n = spi_cs_n;
    assign o_spi_mosi = spi_mosi;

endmodule