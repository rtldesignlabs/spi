module audio_processor (
    input   logic           i_clock,
    // Audio Interface
    input   logic           i_codec_bit_clock,
    input   logic           i_codec_lr_clock,
    input   logic           i_codec_adc_data,
    output  logic           o_codec_dac_data,
    // Output LEDs
    output  logic [6 : 0]   o_leds
);

    timeunit 1ns;
    timeprecision 1ps;

    // Audio Deserializer Output Signals
    logic [23 : 0] data_right;
    logic [23 : 0] data_left;
    logic          data_valid;

    // Audio Deserializer
    audio_deserializer audio_deserializer_inst (
        .i_clock            (i_clock),
        // I2S Interface
        .i_codec_bit_clock  (i_codec_bit_clock),
        .i_codec_lr_clock   (i_codec_lr_clock),
        .i_codec_adc_data   (i_codec_adc_data),
        // Parallel Data Output
        .o_data_left        (data_left),
        .o_data_right       (data_right),
        .o_data_valid       (data_valid)
    );

    // Audio Serializer
    audio_serializer audio_serializer_inst (
        .i_clock            (i_clock),
        // I2S Interface
        .i_codec_bit_clock  (i_codec_bit_clock),
        .i_codec_lr_clock   (i_codec_lr_clock),
        .o_codec_dac_data   (o_codec_dac_data),
        // Parallel Data Output
        .i_data_left        (data_left),
        .i_data_right       (data_right),
        .i_data_valid       (data_valid)
    );

    // LED Meter
    led_meter (
        .i_clock        (i_clock),
        // Audio Data Input
        .i_data_left    (data_left),
        .i_data_right   (data_right),
        .i_data_valid   (data_valid),
        // LEDs
        .o_leds         (o_leds)
    );

endmodule