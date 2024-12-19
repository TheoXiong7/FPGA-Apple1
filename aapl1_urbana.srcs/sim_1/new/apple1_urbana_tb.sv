module apple1_urbana_tb;

    // Clock and reset signals
    logic CLK_50MHZ;
    logic BUTTON;
    logic SWITCH;

    // Internal signals for monitoring
    logic [15:0] cpu_address;
    logic [7:0] cpu_data_out;
    logic [7:0] cpu_data_in;
    logic cpu_read;
    logic cpu_write;
    logic [7:0] ram_data;
    logic [7:0] rom_data;
    logic clk_25MHz, clk_100MHz, clk_125MHz, clk_6MHz;

    // Instantiate DUT
    apple1_urbana #(
        .BASIC_FILENAME("basic.hex"),
        .FONT_ROM_FILENAME("vga_font_bitreversed.hex"),
        .RAM_FILENAME("ram.hex"),
        .VRAM_FILENAME("vga_vram.bin"),
        .WOZMON_ROM_FILENAME("wozmon.hex")
    ) dut (
        .CLK_50MHZ(CLK_50MHZ),
        .BUTTON(BUTTON),
        .SWITCH(SWITCH)
    );

    // Clock generation: 50 MHz
    initial CLK_50MHZ = 0;
    always #10 CLK_50MHZ = ~CLK_50MHZ; // 20 ns period

    // Reset logic
    initial begin
        BUTTON = 1; // Assert reset
        SWITCH = 0; // Default switch state
        #100 BUTTON = 0; // Deassert reset after 100 ns
    end

    // Monitoring hooks: Internal signal access
    assign cpu_address  = dut.apple1_top.cpu_address;
    assign cpu_data_out = dut.apple1_top.cpu_data_out;
    assign cpu_data_in  = dut.apple1_top.cpu_data_in;
    assign cpu_read     = dut.apple1_top.cpu_read;
    assign cpu_write    = dut.apple1_top.cpu_write;
    assign ram_data     = dut.apple1_top.ram_data;
    assign rom_data     = dut.apple1_top.rom_data;
    assign clk_25MHz    = dut.clk_25MHz;
    assign clk_100MHz   = dut.clk_100MHz;
    assign clk_125MHz   = dut.clk_125MHz;
    assign clk_6MHz     = dut.clk_6MHz;

    // Waveform dumping
    initial begin
        // For VCD waveform
        $dumpfile("apple1_urbana_tb.vcd"); // Specify the VCD file name
        $dumpvars(0, apple1_urbana_tb);    // Dump all signals in this module and below
    end

    // Simulation duration
    initial begin
        #200000; // Run simulation for 200,000 ns (10,000 clock cycles at 50 MHz)
        $finish;
    end

endmodule
