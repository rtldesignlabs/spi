module audio_processor (
    input   logic   i_clock,
    // Audio Interface
    input   logic   i_codec_bit_clock,
    input   logic   i_codec_lr_clock,
    input   logic   i_codec_adc_data,
    output  logic   o_codec_dac_data,
    // Buttons
    input   logic   i_btnu,
    input   logic   i_btnd,
    input   logic   i_btnl,
    input   logic   i_btnr
);

    timeunit 1ns;
    timeprecision 1ps;

    // Connecting signals
        logic [23 : 0]  data_right_1;
        logic [23 : 0]  data_right_2;
        logic [23 : 0]  data_left_1;
        logic [23 : 0]  data_left_2;
        logic           data_valid_1;
        logic           data_valid_2;

    // Audio Deserializer
    audio_deserializer audio_deserializer_inst (
        .i_clock            (i_clock),
        // I2S Interface
        .i_codec_bit_clock  (i_codec_bit_clock),
        .i_codec_lr_clock   (i_codec_lr_clock),
        .i_codec_adc_data   (i_codec_adc_data),
        // Parallel Data Output
        .o_data_left        (data_left_1),
        .o_data_right       (data_right_1),
        .o_data_valid       (data_valid_1)
    );

    // Monitor Controller
    monitor_controller monitor_controller_inst ( 
        .i_clock        (i_clock),
        // Audio Data Input
        .i_data_left    (data_left_1),
        .i_data_right   (data_right_1),
        .i_data_valid   (data_valid_1),
        // Buttons
        .i_btnu         (i_btnu),
        .i_btnd         (i_btnd),
        .i_btnl         (i_btnl),
        .i_btnr         (i_btnr),
        // Audio Data Output
        .o_data_left    (data_left_2),
        .o_data_right   (data_right_2),
        .o_data_valid   (data_valid_2)
    );

    // Audio Serializer
    audio_serializer audio_serializer_inst (
        .i_clock            (i_clock),
        // I2S Interface
        .i_codec_bit_clock  (i_codec_bit_clock),
        .i_codec_lr_clock   (i_codec_lr_clock),
        .o_codec_dac_data   (o_codec_dac_data),
        // Parallel Data Output
        .i_data_left        (data_left_2),
        .i_data_right       (data_right_2),
        .i_data_valid       (data_valid_2)
    );

endmodule