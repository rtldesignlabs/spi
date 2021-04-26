module led_share (
    input   logic i_sw0, 
    input   logic i_btnu, 
    input   logic i_btnd, 
    input   logic i_btnl, 
    input   logic i_btnr, 
    input   logic i_btnc,
    output  logic o_ld0
);

    timeunit 1ns;
    timeprecision 1ps;

    assign o_ld0 = (i_sw0 | i_btnu | i_btnd | i_btnl | i_btnr | i_btnc);    // LD0 can be activated by SW0 or any of the pushbuttons

endmodule