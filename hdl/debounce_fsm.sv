module debounce_fsm
    # (
        parameter DEBOUNCE_COUNTER_WIDTH    = 16
    )
    (
        // Clock
        input   logic i_clock,
        // Debounce counter
        input   logic [DEBOUNCE_COUNTER_WIDTH-1 : 0] i_debounce_counter,
        // Bouncing signal
        input   logic i_bouncing_signal,
        // Debounced signal
        output  logic o_debounced_signal
    );

    timeunit 1ns;
    timeprecision 1ps;

    logic [DEBOUNCE_COUNTER_WIDTH-1 : 0] debounce_counter;

    // FSM States Definition
    enum logic [1:0] {  IDLE,
                        EDGE_DETECTED,
                        DEBOUNCED_HIGH,
                        DEBOUNCED_LOW } fsm_state = IDLE;

    // Main FSM
    always_ff @(posedge i_clock) begin
        case (fsm_state)
            IDLE : begin
                o_debounced_signal <= 1'b0;
                debounce_counter <= 'b0;
                fsm_state <= EDGE_DETECTED;
            end

            EDGE_DETECTED : begin
                debounce_counter <= debounce_counter + 1;
                if (debounce_counter == i_debounce_counter) begin
                    debounce_counter <= 'b0;
                    if (i_bouncing_signal == 1'b1) begin
                        fsm_state <= DEBOUNCED_HIGH;
                    end else begin
                        fsm_state <= DEBOUNCED_LOW;
                    end
                end
            end

            DEBOUNCED_HIGH : begin
                o_debounced_signal <= 1'b1;
                if (i_bouncing_signal == 1'b0) begin
                    fsm_state <= EDGE_DETECTED;
                end
            end

            DEBOUNCED_LOW : begin
                o_debounced_signal <= 1'b0;
                if (i_bouncing_signal == 1'b1) begin
                    fsm_state <= EDGE_DETECTED;
                end
            end
        endcase
    end // always_ff

endmodule