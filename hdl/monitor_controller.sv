module monitor_controller ( 
    input   logic           i_clock,
    // Audio Data Input
    input   logic [23 : 0]  i_data_left,
    input   logic [23 : 0]  i_data_right,
    input   logic           i_data_valid,
    // Audio Data Output
    output  logic [23 : 0]  o_data_left,
    output  logic [23 : 0]  o_data_right,
    output  logic           o_data_valid
);

    timeunit 1ns;
    timeprecision 1ps;

    always @(posedge i_clock) begin
        o_data_left <= i_data_left;
        o_data_right <= i_data_right;
        o_data_valid <= i_data_valid;
    end

endmodule