module monitor_controller ( 
    input   logic           i_clock,
    // Audio Data Input
    input   logic [23 : 0]  i_data_left,
    input   logic [23 : 0]  i_data_right,
    input   logic           i_data_valid,
    // Buttons
    input   logic           i_btnu,
    input   logic           i_btnd,
    input   logic           i_btnl,
    input   logic           i_btnr,
    // Audio Data Output
    output  logic [23 : 0]  o_data_left,
    output  logic [23 : 0]  o_data_right,
    output  logic           o_data_valid
);

    timeunit 1ns;
    timeprecision 1ps;

    logic btnu_delay;
    logic btnd_delay;
    logic btnl_delay;
    logic btnr_delay;
    logic toggle_up = 1'b0;
    logic toggle_down = 1'b0;
    logic toggle_left = 1'b0;
    logic toggle_right = 1'b0;
    always @(posedge i_clock) begin
        btnu_delay <= i_btnu;
        btnd_delay <= i_btnd;
        btnl_delay <= i_btnl;
        btnr_delay <= i_btnr;
        if ((i_btnu == 1'b1) & (btnu_delay == 1'b0)) begin
            toggle_up = ~ toggle_up;
        end
        if ((i_btnd == 1'b1) & (btnd_delay == 1'b0)) begin
            toggle_down = ~ toggle_down;
        end
        if ((i_btnl == 1'b1) & (btnl_delay == 1'b0)) begin
            toggle_left = ~ toggle_left;
        end
        if ((i_btnr == 1'b1) & (btnr_delay == 1'b0)) begin
            toggle_right = ~ toggle_right;
        end
        o_data_valid <= i_data_valid;
        o_data_left <= i_data_left;
        o_data_right <= i_data_right;
        // Dim
        if (toggle_up == 1'b1) begin
            o_data_left <= $signed(i_data_left) >>> 2;
            o_data_right <= $signed(i_data_right) >>> 2;
        end
        // Cut
        if (toggle_down == 1'b1) begin
            o_data_left <= 'b0;
            o_data_right <= 'b0;
        end
        // Mute left
        if (toggle_left == 1'b1) begin
            o_data_left <= ($signed(i_data_left) + $signed(i_data_right)) >>> 1;
            o_data_right <= ($signed(i_data_left) + $signed(i_data_right)) >>> 1;
        end
        // Mute right
        if (toggle_right == 1'b1) begin
            o_data_left <= ($signed(i_data_left) - $signed(i_data_right));
            o_data_right <= ($signed(i_data_left) - $signed(i_data_right));
        end
    end

endmodule