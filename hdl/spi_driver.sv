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
        enum logic [4:0]    {IDLE,
                            DUMMY_WRITE_1,
                            DUMMY_WRITE_2,
                            DUMMY_WRITE_3,
                            WRITE_CLOCK_CONTROL_REG,
                            WRITE_I2S_MASTER_MODE,
                            LEFT_MIXER_ENABLE,
                            LEFT_0_DB,
                            RIGHT_MIXER_ENABLE,
                            RIGHT_0_DB,
                            PLAYBACK_LEFT_MIXER_UNMUTE_ENABLE,
                            PLAYBACK_RIGHT_MIXER_UNMUTE_ENABLE,
                            HEADPHONE_OUTPUT_LEFT_ENABLE,
                            HEADPHONE_OUTPUT_RIGHT_ENABLE,
                            LINE_OUT_LEFT_ENABLE,
                            LINE_OUT_RIGHT_ENABLE,
                            ADCS_ENABLE,
                            CHANNELS_PLAYBACK_ENABLE,
                            DACS_ENABLE,
                            SERIAL_INPUT_L0_R0_TO_DAC_LR,
                            SERIAL_OUTPUT_ADC_LR_TO_SERIAL_OUTPUT_L0_R0,
                            CLOCK_ALL_ENGINES_ENABLE,
                            CLOCK_GENERATORS_ENABLE} fsm_state = IDLE;

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
                        fsm_state <= WRITE_CLOCK_CONTROL_REG;
                    end
                end

                WRITE_CLOCK_CONTROL_REG : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00400007;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= WRITE_I2S_MASTER_MODE;
                    end
                end

                WRITE_I2S_MASTER_MODE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00401501;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= LEFT_MIXER_ENABLE;
                    end
                end

                LEFT_MIXER_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00400A01;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= LEFT_0_DB;
                    end
                end
                
                LEFT_0_DB : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00400B05;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= RIGHT_MIXER_ENABLE;
                    end
                end

                RIGHT_MIXER_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00400C01;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= RIGHT_0_DB;
                    end
                end

                RIGHT_0_DB : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00400D05;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= PLAYBACK_LEFT_MIXER_UNMUTE_ENABLE;
                    end
                end

                PLAYBACK_LEFT_MIXER_UNMUTE_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00401C21;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= PLAYBACK_RIGHT_MIXER_UNMUTE_ENABLE;
                    end
                end

                PLAYBACK_RIGHT_MIXER_UNMUTE_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00401E41;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= HEADPHONE_OUTPUT_LEFT_ENABLE;
                    end
                end

                HEADPHONE_OUTPUT_LEFT_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h004023E7;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= HEADPHONE_OUTPUT_RIGHT_ENABLE;
                    end
                end

                HEADPHONE_OUTPUT_RIGHT_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h004024E7;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= LINE_OUT_LEFT_ENABLE;
                    end
                end

                LINE_OUT_LEFT_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h004025E7;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= LINE_OUT_RIGHT_ENABLE;
                    end
                end

                LINE_OUT_RIGHT_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h004026E7;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= ADCS_ENABLE;
                    end
                end

                ADCS_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00401903;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= CHANNELS_PLAYBACK_ENABLE;
                    end
                end

                CHANNELS_PLAYBACK_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00402903;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= DACS_ENABLE;
                    end
                end

                DACS_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h00402A03;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= SERIAL_INPUT_L0_R0_TO_DAC_LR;
                    end
                end

                SERIAL_INPUT_L0_R0_TO_DAC_LR : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h0040F201;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= SERIAL_OUTPUT_ADC_LR_TO_SERIAL_OUTPUT_L0_R0;
                    end
                end

                SERIAL_OUTPUT_ADC_LR_TO_SERIAL_OUTPUT_L0_R0 : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h0040F301;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= CLOCK_ALL_ENGINES_ENABLE;
                    end
                end

                CLOCK_ALL_ENGINES_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h0040F97F;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= CLOCK_GENERATORS_ENABLE;
                    end
                end

                CLOCK_GENERATORS_ENABLE : begin
                    o_enable <= 1'b1;
                    o_data <= 32'h0040FA03;
                    if (i_done == 1'b1) begin
                        o_enable <= 1'b0;
                        fsm_state <= IDLE;
                    end
                end
                
                default : begin
                    fsm_state <= IDLE;
                end
            endcase
        end
    // Main FSM - End

endmodule