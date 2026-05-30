## =================================================================
## Real Digital Boolean Board — XC7S50CSGA324-1
## Official pin mappings from Real Digital boolean.xdc
## Target top module: vending_machine_boolean
## =================================================================

## ---------------- Clock (100 MHz oscillator on F14) ----------------
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

## ---------------- CFGBVS / CONFIG_VOLTAGE ----------------
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];

## ---------------- Slide Switches (sw[0..6]) ----------------
set_property -dict {PACKAGE_PIN V2  IOSTANDARD LVCMOS33} [get_ports {sw[0]}];
set_property -dict {PACKAGE_PIN U2  IOSTANDARD LVCMOS33} [get_ports {sw[1]}];
set_property -dict {PACKAGE_PIN U1  IOSTANDARD LVCMOS33} [get_ports {sw[2]}];
set_property -dict {PACKAGE_PIN T2  IOSTANDARD LVCMOS33} [get_ports {sw[3]}];
set_property -dict {PACKAGE_PIN T1  IOSTANDARD LVCMOS33} [get_ports {sw[4]}];
set_property -dict {PACKAGE_PIN R2  IOSTANDARD LVCMOS33} [get_ports {sw[5]}];
set_property -dict {PACKAGE_PIN R1  IOSTANDARD LVCMOS33} [get_ports {sw[6]}];

## ---------------- Discrete LEDs ----------------
set_property -dict {PACKAGE_PIN G1  IOSTANDARD LVCMOS33} [get_ports {led[0]}];
set_property -dict {PACKAGE_PIN G2  IOSTANDARD LVCMOS33} [get_ports {led[1]}];
set_property -dict {PACKAGE_PIN F1  IOSTANDARD LVCMOS33} [get_ports {led[2]}];
set_property -dict {PACKAGE_PIN F2  IOSTANDARD LVCMOS33} [get_ports {led[3]}];

## ---------------- RGB LED 0 (active HIGH) ----------------
set_property -dict {PACKAGE_PIN V6  IOSTANDARD LVCMOS33} [get_ports {led_rgb[0]}];
set_property -dict {PACKAGE_PIN V4  IOSTANDARD LVCMOS33} [get_ports {led_rgb[1]}];
set_property -dict {PACKAGE_PIN U6  IOSTANDARD LVCMOS33} [get_ports {led_rgb[2]}];

## ---------------- Buttons ----------------
set_property -dict {PACKAGE_PIN J2  IOSTANDARD LVCMOS33} [get_ports {btn[0]}];
set_property -dict {PACKAGE_PIN J5  IOSTANDARD LVCMOS33} [get_ports {btn[1]}];
set_property -dict {PACKAGE_PIN H2  IOSTANDARD LVCMOS33} [get_ports {btn[2]}];
set_property -dict {PACKAGE_PIN J1  IOSTANDARD LVCMOS33} [get_ports {btn[3]}];

## ---------------- 7-Segment Display 0 (ones digit) ----------------
set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports {D0_AN[0]}];
set_property -dict {PACKAGE_PIN C4  IOSTANDARD LVCMOS33} [get_ports {D0_AN[1]}];
set_property -dict {PACKAGE_PIN C7  IOSTANDARD LVCMOS33} [get_ports {D0_AN[2]}];
set_property -dict {PACKAGE_PIN A8  IOSTANDARD LVCMOS33} [get_ports {D0_AN[3]}];
set_property -dict {PACKAGE_PIN D7  IOSTANDARD LVCMOS33} [get_ports {D0_SEG[0]}];
set_property -dict {PACKAGE_PIN C5  IOSTANDARD LVCMOS33} [get_ports {D0_SEG[1]}];
set_property -dict {PACKAGE_PIN A5  IOSTANDARD LVCMOS33} [get_ports {D0_SEG[2]}];
set_property -dict {PACKAGE_PIN B7  IOSTANDARD LVCMOS33} [get_ports {D0_SEG[3]}];
set_property -dict {PACKAGE_PIN A7  IOSTANDARD LVCMOS33} [get_ports {D0_SEG[4]}];
set_property -dict {PACKAGE_PIN D6  IOSTANDARD LVCMOS33} [get_ports {D0_SEG[5]}];
set_property -dict {PACKAGE_PIN B5  IOSTANDARD LVCMOS33} [get_ports {D0_SEG[6]}];
set_property -dict {PACKAGE_PIN A6  IOSTANDARD LVCMOS33} [get_ports {D0_SEG[7]}];

## ---------------- 7-Segment Display 1 (tens digit) ----------------
set_property -dict {PACKAGE_PIN H3  IOSTANDARD LVCMOS33} [get_ports {D1_AN[0]}];
set_property -dict {PACKAGE_PIN J4  IOSTANDARD LVCMOS33} [get_ports {D1_AN[1]}];
set_property -dict {PACKAGE_PIN F3  IOSTANDARD LVCMOS33} [get_ports {D1_AN[2]}];
set_property -dict {PACKAGE_PIN E4  IOSTANDARD LVCMOS33} [get_ports {D1_AN[3]}];
set_property -dict {PACKAGE_PIN F4  IOSTANDARD LVCMOS33} [get_ports {D1_SEG[0]}];
set_property -dict {PACKAGE_PIN J3  IOSTANDARD LVCMOS33} [get_ports {D1_SEG[1]}];
set_property -dict {PACKAGE_PIN D2  IOSTANDARD LVCMOS33} [get_ports {D1_SEG[2]}];
set_property -dict {PACKAGE_PIN C2  IOSTANDARD LVCMOS33} [get_ports {D1_SEG[3]}];
set_property -dict {PACKAGE_PIN B1  IOSTANDARD LVCMOS33} [get_ports {D1_SEG[4]}];
set_property -dict {PACKAGE_PIN H4  IOSTANDARD LVCMOS33} [get_ports {D1_SEG[5]}];
set_property -dict {PACKAGE_PIN D1  IOSTANDARD LVCMOS33} [get_ports {D1_SEG[6]}];
set_property -dict {PACKAGE_PIN C1  IOSTANDARD LVCMOS33} [get_ports {D1_SEG[7]}];
