module led_meter ( 
    input   logic           i_clock,
    // Audio Data Input
    input   logic [23 : 0]  i_data_left,
    input   logic [23 : 0]  i_data_right,
    input   logic           i_data_valid,
    // LEDs
    output  logic [6 : 0]   o_leds
);

    timeunit 1ns;
    timeprecision 1ps;

endmodule