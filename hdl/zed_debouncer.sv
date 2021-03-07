module zed_debouncer
    # (
        parameter SWITCH_COUNT              = 8,
        parameter BUTTON_COUNT              = 5,
        parameter DEBOUNCE_COUNTER_WIDTH    = 16
    )
    (
        // Clock
        input   logic i_clock,
        // Debounce counter values
        input   logic [DEBOUNCE_COUNTER_WIDTH-1 : 0] i_switch_debounce_counter,
        input   logic [DEBOUNCE_COUNTER_WIDTH-1 : 0] i_button_debounce_counter,
        // Input switches
        input   logic i_sw0,
        input   logic i_sw1,
        input   logic i_sw2,
        input   logic i_sw3,
        input   logic i_sw4,
        input   logic i_sw5,
        input   logic i_sw6,
        input   logic i_sw7,
        // Input buttons
        input   logic i_btnu,
        input   logic i_btnd,
        input   logic i_btnl,
        input   logic i_btnr,
        input   logic i_btnc,
        // Debounced switch outputs
        output  logic o_sw0,
        output  logic o_sw1,
        output  logic o_sw2,
        output  logic o_sw3,
        output  logic o_sw4,
        output  logic o_sw5,
        output  logic o_sw6,
        output  logic o_sw7,
        // Debounced button outputs
        output  logic o_btnu,
        output  logic o_btnd,
        output  logic o_btnl,
        output  logic o_btnr,
        output  logic o_btnc
    );

    timeunit 1ns;
    timeprecision 1ps;

    logic [SWITCH_COUNT-1 : 0] bouncing_switch_array;
    logic [SWITCH_COUNT-1 : 0] debounced_switch_array;
    logic [BUTTON_COUNT-1 : 0] bouncing_button_array;
    logic [BUTTON_COUNT-1 : 0] debounced_button_array;

    assign bouncing_switch_array    = {i_sw7, i_sw6, i_sw5, i_sw4, i_sw3, i_sw2, i_sw1, i_sw0};
    assign debounced_switch_array   = {o_sw7, o_sw6, o_sw5, o_sw4, o_sw3, o_sw2, o_sw1, o_sw0};
    assign bouncing_button_array    = {i_btnu, i_btnd, i_btnl, i_btnr, i_btnc};
    assign debounced_button_array   = {o_btnu, o_btnd, o_btnl, o_btnr, o_btnc};

    genvar i;
    generate
        for (i = 0; i < SWITCH_COUNT; i++) begin : switch_debounce_fsm_gen
            debounce_fsm 
            # (
                .DEBOUNCE_COUNTER_WIDTH (DEBOUNCE_COUNTER_WIDTH)
            )
            switch_debounce_fsm_inst (
                .i_clock            (i_clock),
                .i_debounce_counter (i_switch_debounce_counter),
                .i_bouncing_signal  (bouncing_switch_array[i]),
                .o_debounced_signal (debounced_switch_array[i])
            );
        end 
    endgenerate

    genvar j;
    generate
        for (j = 0; j < BUTTON_COUNT; j++) begin : button_debounce_fsm_gen
            debounce_fsm 
            # (
                .DEBOUNCE_COUNTER_WIDTH (DEBOUNCE_COUNTER_WIDTH)
            )
            button_debounce_fsm_inst (
                .i_clock            (i_clock),
                .i_debounce_counter (i_button_debounce_counter),
                .i_bouncing_signal  (bouncing_button_array[j]),
                .o_debounced_signal (debounced_button_array[j])
            );
        end 
    endgenerate

endmodule