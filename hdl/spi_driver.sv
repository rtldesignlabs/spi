module spi_driver # (
    parameter SPI_DATA_WIDTH = 8 
    ) (
        // Clock, reset
        input   logic i_clock,
        input   logic i_reset,
        // Control
        input   logic i_enable,
        // SPI Master Control
        input   logic [SPI_DATA_WIDTH-1 : 0]    i_data,
        input   logic                           i_done,
        input   logic                           i_busy,
        output  logic                           o_enable,
        output  logic [SPI_DATA_WIDTH-1 : 0]    o_data
    );

    timeunit 1ns;
    timeprecision 1ps;

    // Edge detection for the 'i_enable' input - Begin
        logic enable_delay1; 
        logic enable_delay2; 
        logic enable_rising;

        always_ff @(posedge i_clock) begin : enable_edge_detection
            enable_delay1 <= i_enable;
            enable_delay2 <= enable_delay1;
            enable_rising <= 1'b0;
            if ((enable_delay2 == 1'b0) && (enable_delay1 == 1'b1)) begin
                enable_rising <= 1'b1;
            end
        end 
    // Edge detection for the 'i_enable' input - End

    // Main FSM - Begin
       
        enum logic [1:0]    {IDLE,
                            DUMMY_WRITE_1,
                            DUMMY_WRITE_2,
                            DUMMY_WRITE_3} fsm_state = IDLE;

        always_ff @(posedge i_clock) begin
            case (fsm_state)
                IDLE : begin
                    o_enable <= 1'b0;
                    o_data <= 'b0;
                    if (enable_rising == 1'b1) begin
                        fsm_state <= DUMMY_WRITE_1;
                    end
                end

                DUMMY_WRITE_1 : begin
                    o_enable <= 1'b1;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= DUMMY_WRITE_2;
                    end
                end

                DUMMY_WRITE_2 : begin
                    o_enable <= 1'b1;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= DUMMY_WRITE_3;
                    end
                end

                DUMMY_WRITE_3 : begin
                    o_enable <= 1'b1;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= IDLE;
                    end
                end
            endcase
        end
    // Main FSM - End

endmodule