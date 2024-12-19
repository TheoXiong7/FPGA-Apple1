`timescale 1ns / 1ps

module arlet_6502_tb;

    //////////////////////////////////////////////////////////////////////////
    // Testbench Signals
    reg clk;                      // Clock signal
    reg enable;                   // Clock enable
    reg rst;                      // Reset signal
    reg irq_n;                    // Interrupt request
    reg nmi_n;                    // Non-maskable interrupt
    reg ready;                    // Ready signal
    wire [15:0] ab;               // Address bus
    wire [7:0] dbo;               // Data bus output
    reg [7:0] dbi;                // Data bus input
    wire we;                      // Write enable
    wire [15:0] pc_monitor;       // Program counter monitor

    //////////////////////////////////////////////////////////////////////////
    // Instantiate the CPU (DUT)
    arlet_6502 dut (
        .clk(clk),
        .enable(enable),
        .rst(rst),
        .ab(ab),
        .dbi(dbi),
        .dbo(dbo),
        .we(we),
        .irq_n(irq_n),
        .nmi_n(nmi_n),
        .ready(ready),
        .pc_monitor(pc_monitor)
    );

    //////////////////////////////////////////////////////////////////////////
    // Memory Map
    // Registers for memory-mapped regions
    reg [7:0] rom [0:65535];       // Expanded ROM (64 KB)
    reg [7:0] ram [0:65535];       // Expanded RAM (64 KB)

    // Read/write logic for memory
    always @(*) begin
        if (ab < 16'h8000) begin   // RAM region: 0x0000 - 0x7FFF
            dbi = ram[ab];
        end else begin             // ROM region: 0x8000 - 0xFFFF
            dbi = rom[ab];
        end
    end

    always @(posedge clk) begin
        if (we && ab < 16'h8000) begin // Writes to RAM only
            ram[ab] <= dbo;
        end
    end

    //////////////////////////////////////////////////////////////////////////
    // Clock Generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Generate a 50 MHz clock
    end

    //////////////////////////////////////////////////////////////////////////
    // Task: Initialize ROM
    task init_rom;
        integer i;
        begin
            // Initialize entire ROM to NOPs (0xEA)
            for (i = 0; i < 65536; i = i + 1) begin
                rom[i] = 8'hEA; // NOP
            end

            // Simple program in ROM starting at address 0x8000
            // - Store 0x42 to RAM[0x0010]
            // - Load from RAM[0x0010] to accumulator
            // - Increment accumulator
            // - Store accumulator to RAM[0x0011]
            // - Jump back to start
            rom[16'h8000] = 8'hA9; // LDA #$42
            rom[16'h8001] = 8'h42; 
            rom[16'h8002] = 8'h85; // STA $0010
            rom[16'h8003] = 8'h10; 
            rom[16'h8004] = 8'hA5; // LDA $0010
            rom[16'h8005] = 8'h10;
            rom[16'h8006] = 8'hE6; // INC $0010
            rom[16'h8007] = 8'h10; 
            rom[16'h8008] = 8'h85; // STA $0011
            rom[16'h8009] = 8'h11;
            rom[16'h800A] = 8'h4C; // JMP $8000
            rom[16'h800B] = 8'h00;
            rom[16'h800C] = 8'h80;

            // Set the reset vector at 0xFFFC-0xFFFD to point to 0x8000
            rom[16'hFFFC] = 8'h00; // Low byte of start address
            rom[16'hFFFD] = 8'h80; // High byte of start address
        end
    endtask

    //////////////////////////////////////////////////////////////////////////
    // Test Sequence
    initial begin
        // Initialize testbench signals
        enable = 1'b1;
        rst = 1'b1;
        irq_n = 1'b1;
        nmi_n = 1'b1;
        ready = 1'b1;

        // Initialize ROM and RAM
        init_rom();
        for (integer i = 0; i < 65536; i = i + 1) begin
            ram[i] = 8'h00;
        end

        // Apply reset
        $display("Applying reset...");
        #50 rst = 1'b0; // Release reset

        // Monitor execution
        $monitor("Time=%0t, PC=%h, AB=%h, DBI=%h, DBO=%h, WE=%b, RAM[10]=%h, RAM[11]=%h",
                 $time, pc_monitor, ab, dbi, dbo, we, ram[16'h0010], ram[16'h0011]);

        // Wait for some cycles
        #5000; // Adjust time as needed to allow the program to execute

        // Check final results
        if (ram[16'h0010] !== 8'h43) begin
            $display("[FAIL] RAM[0x0010] = %h (expected 0x43)", ram[16'h0010]);
        end else if (ram[16'h0011] !== 8'h43) begin
            $display("[FAIL] RAM[0x0011] = %h (expected 0x43)", ram[16'h0011]);
        end else begin
            $display("[PASS] CPU Test Passed");
        end

        $finish;
    end

endmodule
