module spi_master_tb;

    timeunit 1ns;
    timeprecision 1ps;

    parameter SPI_CLOCK_DIVIDER_WIDTH   = 4;
    parameter SPI_DATA_WIDTH            = 8;

    logic   clock;
    logic   reset;
    logic   enable;
    logic   interrupt_enable;
    logic   clock_polarity;
    logic   clock_phase;
    logic   [SPI_CLOCK_DIVIDER_WIDTH-1 : 0] spi_clock_divider;
    logic   [SPI_DATA_WIDTH-1 : 0]          data_in;
    logic   [SPI_DATA_WIDTH-1 : 0]          data_out;
    logic   done;
    logic   spi_cs_n;
    logic   spi_clock;
    logic   spi_mosi;
    logic   spi_miso;

    spi_master_top
    # (
        .SPI_CLOCK_DIVIDER_WIDTH    (SPI_CLOCK_DIVIDER_WIDTH),
        .SPI_DATA_WIDTH             (SPI_DATA_WIDTH)
    )
    spi_master_top_inst
    (
        .i_clock                (clock),
        .i_reset                (reset),
        .i_enable               (enable),
        .i_interrupt_enable     (interrupt_enable),
        .i_clock_polarity       (clock_polarity),
        .i_clock_phase          (clock_phase),
        .i_spi_clock_divider    (spi_clock_divider),
        .i_data_in              (data_in),
        .o_data_out             (data_out),
        .o_done                 (done),
        .o_spi_cs_n             (spi_cs_n),
        .o_spi_clock            (spi_clock),
        .o_spi_mosi             (spi_mosi),
        .i_spi_miso             (spi_miso)
    );

    // Clock generation
    initial begin
        clock = 1'b0;
        forever begin
            #5;
            clock = ~ clock;
        end
    end

    logic [7 : 0] mosi_bus;
    logic [7 : 0] miso_bus;
    // Stimulus
    initial begin
        $display("Starting simulation");
        reset = 1'b0;
        enable = 1'b0;
        interrupt_enable = 1'b0;
        clock_polarity = 1'b0;
        clock_phase = 1'b0;
        spi_clock_divider = 'b0;
        data_in = 'b0;
        spi_miso = 1'b0;
        mosi_bus <= 'b0;
        miso_bus <= 'b01101001;
        @(posedge clock);
        @(posedge clock);
        reset = 1'b1;
        @(posedge clock);
        @(posedge clock);
        reset = 1'b0;
        @(posedge clock);
        data_in = 'b10010110;
        clock_polarity = 1'b1;
        clock_phase = 1'b1;
        spi_clock_divider = 15;
        enable = 1'b1;
        @(posedge clock);
        enable = 1'b0;
        @(negedge spi_cs_n);
        for (int i = 7; i >= 0; i--) begin
            @(negedge spi_clock);   // Shift data
            spi_miso = miso_bus[i];
            @(posedge spi_clock);   // Sample data
            mosi_bus[i] = spi_mosi;
        end
        @(negedge done);
        #125;
        @(posedge clock);
        clock_polarity = 1'b0;
        @(posedge clock);
        enable = 1'b1;
        @(posedge clock);
        enable = 1'b0;
        @(negedge spi_cs_n);
        for (int i = 7; i >= 0; i--) begin
            @(posedge spi_clock);   // Shift data
            spi_miso = miso_bus[i];
            @(negedge spi_clock);   // Sample data
            mosi_bus[i] = spi_mosi;
        end
        @(negedge done);
        #125;
        @(posedge clock);
        clock_phase = 1'b0;
        clock_polarity = 1'b1;
        @(posedge clock);
        enable = 1'b1;
        @(posedge clock);
        enable = 1'b0;
        @(negedge spi_cs_n);
        for (int i = 7; i >= 0; i--) begin
            spi_miso = miso_bus[i];
            @(negedge spi_clock);   // Sample data
            mosi_bus[i] = spi_mosi;
            @(posedge spi_clock);   // Shift data
        end
        @(negedge done);
        #125;
        @(posedge clock);
        clock_phase = 1'b0;
        clock_polarity = 1'b0;
        @(posedge clock);
        enable = 1'b1;
        @(posedge clock);
        enable = 1'b0;
        @(negedge spi_cs_n);
        for (int i = 7; i >= 0; i--) begin
            spi_miso = miso_bus[i];
            @(posedge spi_clock);   // Sample data
            mosi_bus[i] = spi_mosi;
            @(negedge spi_clock);   // Shift data
        end
        @(negedge done);
        #125;
        $display("Simulation finished");
        $stop();
    end

endmodule