// AAPL 1

module apple1 #(
    parameter BASIC_FILENAME      = "basic.hex",
    parameter FONT_ROM_FILENAME   = "vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "ram.hex",
    parameter VRAM_FILENAME       = "vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "wozmon.hex"
) (
    output cpu_dout_dbg,
    input  clk25,               // 25 MHz master clock
    input  rst_n,               // active low synchronous reset

    // MicroBlaze USB keyboard interface
    input [7:0] keycode0,       // First keycode from MicroBlaze GPIO
    input [7:0] keycode1,       // Second keycode from MicroBlaze GPIO

    // Outputs to VGA display
    output vga_h_sync,          // horizontal VGA sync pulse
    output vga_v_sync,          // vertical VGA sync pulse
    output vga_red,             // red VGA signal
    output vga_grn,             // green VGA signal
    output vga_blu,             // blue VGA signal
    output vde,                 // vde
    input vga_cls,              // clear screen button

    // Debugging ports
    output [15:0] pc_monitor    // spy for program counter / debugging
);
    // Registers and Wires

    wire [15:0] ab;
    wire [7:0] dbi;
    wire [7:0] dbo;
    wire we;

    // Clocks and Reset
    wire cpu_clken;
    clock my_clock(
        .clk25(clk25),
        .rst_n(rst_n),
        .cpu_clken(cpu_clken)
    );

    wire rst;
    pwr_reset my_reset(
        .clk25(clk25),
        .rst_n(rst_n),
        .enable(cpu_clken),
        .rst(rst)
    );

    // 6502
    arlet_6502 my_cpu(
        .clk    (clk25),
        .enable (cpu_clken), //cpu_clken
        .rst    (rst),
        .ab     (ab),
        .dbi    (dbi),
        .dbo    (dbo),
        .we     (we),
        .irq_n  (1'b1),
        .nmi_n  (1'b1),
        .ready  (cpu_clken), //cpu_clken
        .pc_monitor (pc_monitor)
    );

    // Address Decoding
    wire ram_cs =   (ab[15:13] ==  3'b000);              // 0x0000 -> 0x1FFF
    wire vga_mode_cs = (ab[15:2] == 14'b11000000000000); // 0xC000 -> 0xC003
    wire rx_cs = (ab[15:1]  == 15'b110100000001000);     // 0xD010 -> 0xD011
    wire tx_cs = (ab[15:1]  == 15'b110100000001001);     // 0xD012 -> 0xD013
    
    wire kb_cs = rx_cs;    // Keyboard input
    wire vga_cs = tx_cs;   // VGA output
    
    wire basic_cs = (ab[15:12] ==  4'b1110);             // 0xE000 -> 0xEFFF
    wire rom_cs =   (ab[15:8]  ==  8'b11111111);         // 0xFF00 -> 0xFFFF

    // RAM and ROM
    wire [7:0] ram_dout;
    ram #(
        .RAM_FILENAME (RAM_FILENAME)
    ) my_ram(
        .clk(cpu_clken), // clk25
        .address(ab[12:0]),
        .w_en(we & ram_cs),
        .din(dbo),
        .dout(ram_dout)
    );

    wire [7:0] rom_dout;
    rom_wozmon #(
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) my_rom_wozmon(
        .clk(cpu_clken), // clk25
        .address(ab[7:0]),
        .dout(rom_dout)
    );

    wire [7:0] basic_dout;
    rom_basic #(
        .BASIC_FILENAME (BASIC_FILENAME)
    ) my_rom_basic(
        .clk(cpu_clken),
        .address(ab[11:0]),
        .dout(basic_dout)
    );

    // USB Keyboard Interface
    reg [7:0] kb_dout;
    always @(posedge clk25 or posedge rst) begin
        if (rst) begin
            kb_dout <= 8'h00; 
        end else if (kb_cs & cpu_clken) begin
            // Convert USB keycode to ASCII
            case (keycode0)
                8'h04: kb_dout <= 8'h41;  // A
                8'h05: kb_dout <= 8'h42;  // B
                8'h06: kb_dout <= 8'h43;  // C
                8'h07: kb_dout <= 8'h44;  // D
                8'h08: kb_dout <= 8'h45;  // E
                8'h09: kb_dout <= 8'h46;  // F
                8'h0A: kb_dout <= 8'h47;  // G
                8'h0B: kb_dout <= 8'h48;  // H
                8'h0C: kb_dout <= 8'h49;  // I
                8'h0D: kb_dout <= 8'h4A;  // J
                8'h0E: kb_dout <= 8'h4B;  // K
                8'h0F: kb_dout <= 8'h4C;  // L
                8'h10: kb_dout <= 8'h4D;  // M
                8'h11: kb_dout <= 8'h4E;  // N
                8'h12: kb_dout <= 8'h4F;  // O
                8'h13: kb_dout <= 8'h50;  // P
                8'h14: kb_dout <= 8'h51;  // Q
                8'h15: kb_dout <= 8'h52;  // R
                8'h16: kb_dout <= 8'h53;  // S
                8'h17: kb_dout <= 8'h54;  // T
                8'h18: kb_dout <= 8'h55;  // U
                8'h19: kb_dout <= 8'h56;  // V
                8'h1A: kb_dout <= 8'h57;  // W
                8'h1B: kb_dout <= 8'h58;  // X
                8'h1C: kb_dout <= 8'h59;  // Y
                8'h1D: kb_dout <= 8'h5A;  // Z
                8'h28: kb_dout <= 8'h0D;  // Enter
                8'h2C: kb_dout <= 8'h20;  // Space
                default: kb_dout <= 8'h00;
            endcase
        end
    end

    // VGA Interface

    reg [2:0] fg_colour;
    reg [2:0] bg_colour;
    reg [1:0] font_mode;
    reg [7:0] vga_mode_dout;

    vga #(
        .VRAM_FILENAME (VRAM_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME)
    ) my_vga(
        .clk25(clk25),
        .enable(vga_cs & cpu_clken), // vga_cs & cpu_clken
        .rst(rst),
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_grn(vga_grn),
        .vga_blu(vga_blu),
        .vde(vde),
        .address(ab[0]),
        .w_en(we & vga_cs),
        .din(dbo),
        .mode(font_mode),
        .fg_colour(fg_colour),
        .bg_colour(bg_colour),
        .clr_screen(vga_cls)
    );

    // VGA mode handling
    always @(posedge clk25 or posedge rst) begin
        if (rst) begin
            font_mode <= 2'b0;
            fg_colour <= 3'd7;
            bg_colour <= 3'd0;
        end else begin
            case (ab[1:0])
            2'b00: begin
                vga_mode_dout = {6'b0, font_mode};
                if (vga_mode_cs & we & cpu_clken)
                    font_mode <= dbo[1:0];
            end
            2'b01: begin
                vga_mode_dout = {5'b0, fg_colour};
                if (vga_mode_cs & we & cpu_clken)
                    fg_colour <= dbo[2:0];
            end
            2'b10: begin
                vga_mode_dout = {5'b0, bg_colour};
                if (vga_mode_cs & we & cpu_clken)
                    bg_colour <= dbo[2:0];
            end
            default:
                vga_mode_dout = 8'b0;
            endcase
        end
    end

    // CPU Data In MUX
   // link up chip selected device to cpu input
    assign dbi = ram_cs      ? ram_dout :
                 rom_cs      ? rom_dout :
                 basic_cs    ? basic_dout :
                 vga_mode_cs ? vga_mode_dout :
                 8'hFF;

endmodule