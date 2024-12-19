/* APPLE ONE COMPUTER */
/* karans4, tyxiong2 */

module apple1_s3e_starterkit_top #(
    parameter BASIC_FILENAME      = "basic.hex",
    parameter FONT_ROM_FILENAME   = "vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "ram.hex",
    parameter VRAM_FILENAME       = "vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "wozmon.hex"
) (    
    input   CLK_50MHZ,      // the 50 MHz master clock
    input   BUTTON,         // Button for RESET
    input   SWITCH,         // Switch between PS/2 input and UART

    /* HDMI Signals */    
    output hdmi_tmds_clk_n,
    output hdmi_tmds_clk_p,
    output [2:0]hdmi_tmds_data_n,
    output [2:0]hdmi_tmds_data_p,
    
    /* UART */
    input uart_rtl_0_rxd,
    output uart_rtl_0_txd,
    
    /* USB Signals */
    input [0:0] gpio_usb_int_tri_i,
    output gpio_usb_rst_tri_o,
    input usb_spi_miso,
    output usb_spi_mosi,
    output usb_spi_sclk,
    output usb_spi_ss
);
    /* USB Signals */
    wire [31:0] keycode0_gpio, keycode1_gpio;
    
    mb_snes mb_block_i (
        .clk_100MHz(clk_100MHz),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~BUTTON), //Block designs expect active low reset, all other modules are active high
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );
    //////////////////////////////////////////////////////////////////////////    
    // Registers and Wires
    reg clk25;
    wire [15:0] pc_monitor;

    wire rst_n;    
    assign rst_n = ~BUTTON;

    // generate 25MHz clock from 50MHz master clock
    always @(posedge CLK_50MHZ)
    begin
        clk25 <= ~clk25;
    end    
        
    // Core of system
    apple1 #(
        .BASIC_FILENAME (BASIC_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME),
        .RAM_FILENAME (RAM_FILENAME),
        .VRAM_FILENAME (VRAM_FILENAME),
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) apple1_top(
        .clk25(clk25),
        .rst_n(rst_n),         // we don't have any reset pulse..
        .keycode0(keycode0_gpio[7:0]),
        .keycode1(keycode0_gpio[15:8]),

        .vga_h_sync(VGA_HS),
        .vga_v_sync(VGA_VS),
        .vga_red(VGA_R),
        .vga_grn(VGA_G),
        .vga_blu(VGA_B),
        .vde(vde),
        .vga_cls(~rst_n),
        .pc_monitor(pc_monitor)
    );
    
    wire locked;
    wire vde;
    wire clk_25MHz, clk_100MHz, clk_125MHz;
    
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .clk_out3(clk_100MHz),
        .reset(BUTTON),
        .locked(locked),
        .clk_in1(CLK_50MHZ)
    );
    
    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        //Reset is active LOW
        .rst(BUTTON),
        //Color and Sync Signals
        .red(VGA_R),
        .green(VGA_G),
        .blue(VGA_B),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );
    
endmodule
