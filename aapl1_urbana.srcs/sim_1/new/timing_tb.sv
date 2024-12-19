`timescale 1ns/1ps

module apple1_post_synth_tb;

    // Clock and reset
    reg clk_50MHz;
    reg rst_n;

    // Test signals for apple1 inputs/outputs
    wire [15:0] pc_monitor;
    wire vga_h_sync, vga_v_sync, vga_red, vga_grn, vga_blu, vde;

    // Keyboard input signals
    reg [7:0] keycode0, keycode1;

    // VGA clear signal
    reg vga_cls;

    // Control signals for RAM/ROM testing
    wire cpu_dout_dbg;

    // Instantiate the apple1 module
    apple1 uut (
        .clk25(clk_50MHz),
        .rst_n(rst_n),
        .keycode0(keycode0),
        .keycode1(keycode1),
        .vga_cls(vga_cls),
        .pc_monitor(pc_monitor),
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_grn(vga_grn),
        .vga_blu(vga_blu),
        .vde(vde),
        .cpu_dout_dbg(cpu_dout_dbg)
    );

    // Clock generation (50 MHz)
    initial begin
        clk_50MHz = 0;
        forever #10 clk_50MHz = ~clk_50MHz; // 20 ns period for 50 MHz clock
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #100 rst_n = 1; // Release reset after 100 ns
    end

    // Keyboard inputs initialization
    initial begin
        keycode0 = 8'h00;
        keycode1 = 8'h00;
        vga_cls = 0;
    end

    // Test RAM and ROM
    reg [7:0] expected_rom_data [0:255];
    reg [7:0] ram_data [0:8191];

    // Load test data into expected arrays
    initial begin
        $readmemh("wozmon.hex", expected_rom_data, 0, 255);
        $readmemh("ram.hex", ram_data, 0, 8191);
    end

    // Main test sequence
    initial begin
        // Wait for reset to complete
        @(posedge rst_n);

        // Test 1: Verify memory map
        $display("Testing memory map...");
        test_memory_map();

        // Test 2: Verify ROM (wozmon) functionality
        $display("Testing ROM (wozmon)...");
        test_rom();

        // Test 3: Verify CPU read/write interactions
        $display("Testing CPU interactions...");
        test_cpu();

        $display("Post-synthesis timing simulation completed.");
        $finish;
    end

    // Task to test memory map
    task test_memory_map;
        integer i;
        begin
            for (i = 0; i < 8192; i = i + 1) begin
                @(posedge clk_50MHz);
                // Simulate writes to RAM and check reads
                force uut.my_ram.w_en = 1;         // Enable write
                force uut.my_ram.address = i[12:0]; // Set address
                force uut.my_ram.din = i[7:0];    // Write value
                @(posedge clk_50MHz);
                release uut.my_ram.w_en;
                release uut.my_ram.address;
                release uut.my_ram.din;
                @(posedge clk_50MHz);
                if (uut.my_ram.dout !== ram_data[i]) begin
                    $display("[FAIL] RAM Address %0h: Expected %0h, Got %0h", i, ram_data[i], uut.my_ram.dout);
                end else begin
                    $display("[PASS] RAM Address %0h: Value %0h", i, uut.my_ram.dout);
                end
            end
        end
    endtask

    // Task to test ROM functionality
    task test_rom;
        integer i;
        begin
            for (i = 0; i < 256; i = i + 1) begin
                @(posedge clk_50MHz);
                force uut.my_rom_wozmon.address = i[7:0]; // Set ROM address
                @(posedge clk_50MHz);
                release uut.my_rom_wozmon.address;
                if (uut.my_rom_wozmon.dout !== expected_rom_data[i]) begin
                    $display("[FAIL] ROM Address %0h: Expected %0h, Got %0h", i, expected_rom_data[i], uut.my_rom_wozmon.dout);
                end else begin
                    $display("[PASS] ROM Address %0h: Value %0h", i, uut.my_rom_wozmon.dout);
                end
            end
        end
    endtask

    // Task to test CPU interactions
    task test_cpu;
        integer i;
        reg [7:0] cpu_data;
        begin
            for (i = 0; i < 256; i = i + 1) begin
                @(posedge clk_50MHz);
                force uut.my_cpu.ab = i[15:0];      // Set address bus
                force uut.my_cpu.dbo = i[7:0];     // Set data bus output
                force uut.my_cpu.we = 1;           // Enable write
                @(posedge clk_50MHz);
                release uut.my_cpu.ab;
                release uut.my_cpu.dbo;
                release uut.my_cpu.we;
                @(posedge clk_50MHz);
                if (uut.my_ram.dout !== i[7:0]) begin
                    $display("[FAIL] CPU Write Address %0h: Expected %0h, Got %0h", i, i[7:0], uut.my_ram.dout);
                end else begin
                    $display("[PASS] CPU Write Address %0h: Value %0h", i, uut.my_ram.dout);
                end
            end
        end
    endtask

endmodule
