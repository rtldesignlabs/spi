module spi_master_top # (
    parameter SPI_CLOCK_DIVIDER_WIDTH   = 5,
    parameter SPI_DATA_WIDTH            = 32
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
        output  logic o_spi_cs_n,
        output  logic o_spi_clock,
        output  logic o_spi_mosi,
        input   logic i_spi_miso,
        // Audio Codec
        input   logic i_codec_bit_clock,  
        input   logic i_codec_lr_clock,  
        input   logic i_codec_adc_data,
        output  logic o_codec_mclock,
        output  logic o_codec_dac_data
    );

    timeunit 1ns;
    timeprecision 1ps;

    // Debouncer Core
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
            .i_switch_debounce_counter  (16'd10000),
            .i_button_debounce_counter  (16'd10000),
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

    // LD0 assignment, can be activated by SW0 or any of the pushbuttons
        led_share led_share_inst (
            .i_sw0  (sw0),
            .i_btnu (btnu),
            .i_btnd (btnd),
            .i_btnl (btnl),
            .i_btnr (btnr),
            .i_btnc (btnc),
            .o_ld0  (o_ld0)
        );

    // SPI Driver <-> SPI Core connecting signals
        logic                           spi_enable;
        logic [SPI_DATA_WIDTH-1 : 0]    spi_data_in;
        logic [SPI_DATA_WIDTH-1 : 0]    spi_data_out;
        logic                           spi_done;
        logic                           spi_busy;

    // SPI Driver
        spi_driver # (
            .SPI_DATA_WIDTH (SPI_DATA_WIDTH) 
        )
        spi_driver_inst (
            // Clock, reset
            .i_clock    (i_clock),
            .i_reset    (1'b0),
            // Control
            .i_enable   (btnc),
            // SPI Master Control
            .i_data     (spi_data_out),
            .i_done     (spi_done),
            .i_busy     (spi_busy),
            .o_enable   (spi_enable),
            .o_data     (spi_data_in)
        );

    // SPI Core
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
            .i_clock_polarity       (1'b0),
            .i_clock_phase          (1'b0),
            .i_spi_clock_divider    (5'b10000),
            .i_data_in              (spi_data_in),
            .o_data_out             (spi_data_out),
            .o_done                 (spi_done),
            .o_busy                 (spi_busy),
            // SPI interface
            .o_spi_cs_n             (o_spi_cs_n),
            .o_spi_clock            (o_spi_clock),
            .o_spi_mosi             (o_spi_mosi),
            .i_spi_miso             (i_spi_miso)
        );

    // Clock Generator for the Audio Codec
        logic clock_45;     // 44.1 KHz * 1024 = 45.169664 MHz, core generates 45.16765 MHz
        clk_wiz_0 clk_wiz_0_inst (
            .clk_in1    (i_clock),
            .clk_out1   (clock_45)
        );

        oddr_0 oddr_0_inst (
            .clk_in     (clock_45),
            .clk_out    (o_codec_mclock)
        );

    // Audio Processor
        audio_processor audio_processor_inst ( 
            .i_clock            (i_clock),
            // Audio Interface
            .i_codec_bit_clock  (i_codec_bit_clock),  
            .i_codec_lr_clock   (i_codec_lr_clock),  
            .i_codec_adc_data   (i_codec_adc_data),
<<<<<<< HEAD
            .o_codec_dac_data   (o_codec_dac_data),
            // Buttons
            .i_btnu             (btnu),
            .i_btnd             (btnd),
            .i_btnl             (btnl),
            .i_btnr             (btnr)    
=======
            .o_codec_dac_data   (o_codec_dac_data)        
>>>>>>> 9a691bf9e666dc0ea2514ad7430ff93e2f220e5f
        );

endmodule