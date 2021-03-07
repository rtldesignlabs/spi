module spi_master_top # (
    parameter SPI_CLOCK_DIVIDER_WIDTH   = 5,
    parameter SPI_DATA_WIDTH            = 8
    ) (
        // Clock
        input   logic i_clock,      // 100 MHz
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
        // Output LEDs
        output  logic o_ld0,
        output  logic o_ld1,
        output  logic o_ld2,
        output  logic o_ld3,
        output  logic o_ld4,
        output  logic o_ld5,
        output  logic o_ld6,
        output  logic o_ld7,
        // SPI Interface
        output  logic   o_spi_cs_n,
        output  logic   o_spi_clock,
        output  logic   o_spi_mosi,
        input   logic   i_spi_miso
    );

    timeunit 1ns;
    timeprecision 1ps;

    // Debouncer Core - Begin
        logic sw0;
        logic sw1;
        logic sw2;
        logic sw3;
        logic sw4;
        logic sw5;
        logic sw6;
        logic sw7;
        logic btnu;
        logic btnd;
        logic btnl;
        logic btnr;
        logic btnc;
    
        zed_debouncer # (
            .SWITCH_COUNT           (8),
            .BUTTON_COUNT           (5),
            .DEBOUNCE_COUNTER_WIDTH (16)
        )
        zed_debouncer_inst (
            // Clock
            .i_clock                    (i_clock),
            // Debounce counter values
            .i_switch_debounce_counter  (16'd1000),
            .i_button_debounce_counter  (16'd1000),
            // Input switches
            .i_sw0                      (i_sw0),
            .i_sw1                      (i_sw1),
            .i_sw2                      (i_sw2),
            .i_sw3                      (i_sw3),
            .i_sw4                      (i_sw4),
            .i_sw5                      (i_sw5),
            .i_sw6                      (i_sw6),
            .i_sw7                      (i_sw7),
            // Input buttons
            .i_btnu                     (i_btnu),
            .i_btnd                     (i_btnd),
            .i_btnl                     (i_btnl),
            .i_btnr                     (i_btnr),
            .i_btnc                     (i_btnc),
            // Debounced switch outputs
            .o_sw0                      (sw0),
            .o_sw1                      (sw1),
            .o_sw2                      (sw2),
            .o_sw3                      (sw3),
            .o_sw4                      (sw4),
            .o_sw5                      (sw5),
            .o_sw6                      (sw6),
            .o_sw7                      (sw7),
            // Debounced button outputs
            .o_btnu                     (btnu),
            .o_btnd                     (btnd),
            .o_btnl                     (btnl),
            .o_btnr                     (btnr),
            .o_btnc                     (btnc)
        );

        assign o_ld0 = (sw0 | btnu | btnd | btnl | btnr | btnc);    // LD0 can be activated by SW0 or any of the pushbuttons
        assign o_ld1 = sw1;
        assign o_ld2 = sw2;
        assign o_ld3 = sw3;
        assign o_ld4 = sw4;
        assign o_ld5 = sw5;
        assign o_ld6 = sw6;
        assign o_ld7 = sw7;
    // Debouncer Core - End

    // SPI Driver <-> SPI Core connecting signals - Begin
        (* keep = "dont_touch" *) logic                                   spi_enable;
        (* keep = "dont_touch" *) logic                                   clock_polarity;
        (* keep = "dont_touch" *) logic                                   clock_phase;
        (* keep = "dont_touch" *) logic [SPI_CLOCK_DIVIDER_WIDTH-1 : 0]   spi_clock_divider;
        (* keep = "dont_touch" *) logic [SPI_DATA_WIDTH-1 : 0]            spi_data_in;
        (* keep = "dont_touch" *) logic [SPI_DATA_WIDTH-1 : 0]            spi_data_out;
        (* keep = "dont_touch" *) logic                                   spi_done;
        (* keep = "dont_touch" *) logic                                   spi_busy;
        (* keep = "dont_touch" *) logic                                   spi_cs_n;
        (* keep = "dont_touch" *) logic                                   spi_clock;
        (* keep = "dont_touch" *) logic                                   spi_mosi;
        (* keep = "dont_touch" *) logic                                   spi_miso;
    // SPI Driver <-> SPI Core connecting signals - End

    // SPI Driver - Begin
        spi_driver # (
            .SPI_DATA_WIDTH (SPI_DATA_WIDTH) 
        )
        spi_driver_inst (
            // Clock, reset
            .i_clock    (i_clock),
            .i_reset    (1'b0),
            // Control
            .i_enable   (btnu),
            // SPI Master Control
            .i_data     (spi_data_out),
            .i_done     (spi_done),
            .i_busy     (spi_busy),
            .o_enable   (spi_enable),
            .o_data     (spi_data_in)
        );
    // SPI Driver - End

    // SPI Core - Begin
        spi_master # (
            .SPI_CLOCK_DIVIDER_WIDTH    (SPI_CLOCK_DIVIDER_WIDTH),   
            .SPI_DATA_WIDTH             (SPI_DATA_WIDTH)  
        )
        spi_master_inst (
            // Clock, reset
            .i_clock                (i_clock),
            .i_reset                (1'b0),
            // Data, control and status interface
            .i_enable               (spi_enable),
            .i_clock_polarity       (clock_polarity),
            .i_clock_phase          (clock_phase),
            .i_spi_clock_divider    (spi_clock_divider),
            .i_data_in              (spi_data_in),
            .o_data_out             (spi_data_out),
            .o_done                 (spi_done),
            .o_busy                 (spi_busy),
            // SPI interface
            .o_spi_cs_n             (spi_cs_n),
            .o_spi_clock            (spi_clock),
            .o_spi_mosi             (spi_mosi),
            .i_spi_miso             (spi_miso)
        );

        assign clock_polarity = sw1;
        assign clock_phase = sw2;
        assign spi_clock_divider = {sw7, sw6, sw5, sw4, sw3};
        assign spi_cs_n = o_spi_cs_n;
        assign spi_clock = o_spi_clock;
        assign spi_mosi = o_spi_mosi;
        assign spi_miso = i_spi_miso;
    // SPI Core - End

endmodule