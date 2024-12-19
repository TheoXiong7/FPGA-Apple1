# Clock signal
set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports { CLK_50MHZ }]
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports { CLK_50MHZ }]
# Create a derived 25 MHz clock
create_generated_clock -name clk_25MHz -source [get_ports {CLK_50MHZ}] [get_pins {div_50_to_25/clk_out}] -divide_by 2
# Create a derived 1 MHz clock
create_generated_clock -name clk_1MHz -source [get_ports {CLK_50MHZ}] [get_pins {div_50_to_1/clk_out}] -divide_by 50

# USB Signals
set_property IOSTANDARD LVCMOS33 [get_ports uart_rtl_0_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rtl_0_txd]
set_property PACKAGE_PIN B16 [get_ports uart_rtl_0_rxd]
set_property PACKAGE_PIN A16 [get_ports uart_rtl_0_txd]

set_property IOSTANDARD LVCMOS33 [get_ports {gpio_usb_int_tri_i[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports usb_spi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports usb_spi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports usb_spi_sclk]
set_property PACKAGE_PIN T13 [get_ports {gpio_usb_int_tri_i[0]}]
set_property PACKAGE_PIN V14 [get_ports usb_spi_sclk]
set_property PACKAGE_PIN V15 [get_ports usb_spi_mosi]
set_property PACKAGE_PIN U12 [get_ports usb_spi_miso]

set_property IOSTANDARD LVCMOS33 [get_ports gpio_usb_rst_tri_o]
set_property PACKAGE_PIN V13 [get_ports gpio_usb_rst_tri_o]
set_property PACKAGE_PIN T12 [get_ports usb_spi_ss]
set_property IOSTANDARD LVCMOS33 [get_ports usb_spi_ss]


# Buttons and Switches
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports { BUTTON }]
set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVCMOS33 } [get_ports { SWITCH }]

# Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# False paths
set_false_path -from [get_ports {BUTTON SWITCH}]

#HDMI Signals
set_property -dict { PACKAGE_PIN V17   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_clk_n}]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_clk_p}]

set_property -dict { PACKAGE_PIN U18   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_n[0]}]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_n[1]}]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_n[2]}]
                                    
set_property -dict { PACKAGE_PIN U17   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_p[0]}]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_p[1]}]
set_property -dict { PACKAGE_PIN R14   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_p[2]}]

# HEX Displays
set_property IOSTANDARD LVCMOS33 [get_ports {hex_gridA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_gridA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_gridA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_gridA[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_gridB[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_gridB[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_gridB[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_gridB[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segA[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segA[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segA[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segA[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segA[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segB[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segB[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segB[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segB[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segB[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segB[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segB[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hex_segB[0]}]
set_property PACKAGE_PIN G6 [get_ports {hex_gridA[0]}]
set_property PACKAGE_PIN H6 [get_ports {hex_gridA[1]}]
set_property PACKAGE_PIN C3 [get_ports {hex_gridA[2]}]
set_property PACKAGE_PIN B3 [get_ports {hex_gridA[3]}]
set_property PACKAGE_PIN E6 [get_ports {hex_segA[0]}]
set_property PACKAGE_PIN B4 [get_ports {hex_segA[1]}]
set_property PACKAGE_PIN D5 [get_ports {hex_segA[2]}]
set_property PACKAGE_PIN C5 [get_ports {hex_segA[3]}]
set_property PACKAGE_PIN D7 [get_ports {hex_segA[4]}]
set_property PACKAGE_PIN D6 [get_ports {hex_segA[5]}]
set_property PACKAGE_PIN C4 [get_ports {hex_segA[6]}]
set_property PACKAGE_PIN B5 [get_ports {hex_segA[7]}]
set_property PACKAGE_PIN F3 [get_ports {hex_segB[0]}]
set_property PACKAGE_PIN G5 [get_ports {hex_segB[1]}]
set_property PACKAGE_PIN J3 [get_ports {hex_segB[2]}]
set_property PACKAGE_PIN H4 [get_ports {hex_segB[3]}]
set_property PACKAGE_PIN F4 [get_ports {hex_segB[4]}]
set_property PACKAGE_PIN H3 [get_ports {hex_segB[5]}]
set_property PACKAGE_PIN E5 [get_ports {hex_segB[6]}]
set_property PACKAGE_PIN J4 [get_ports {hex_segB[7]}]
set_property PACKAGE_PIN E4 [get_ports {hex_gridB[0]}]
set_property PACKAGE_PIN E3 [get_ports {hex_gridB[1]}]
set_property PACKAGE_PIN F5 [get_ports {hex_gridB[2]}]
set_property PACKAGE_PIN H5 [get_ports {hex_gridB[3]}]
