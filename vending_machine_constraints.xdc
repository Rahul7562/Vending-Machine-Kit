## =================================================================
## Real Digital Boolean Board — XC7S50CSGA324-1 Constraints
## Target: vending_machine_boolean (top module)
## =================================================================

## ---------------- Clock (100 MHz oscillator on F14) ----------------
set_property -dict { PACKAGE_PIN F14  IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

## ---------------- Slide Switches (sw[0]..sw[6]) ----------------
set_property -dict { PACKAGE_PIN V2   IOSTANDARD LVCMOS33 } [get_ports { sw[0] }];
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }];
set_property -dict { PACKAGE_PIN U1   IOSTANDARD LVCMOS33 } [get_ports { sw[2] }];
set_property -dict { PACKAGE_PIN T2   IOSTANDARD LVCMOS33 } [get_ports { sw[3] }];
set_property -dict { PACKAGE_PIN T1   IOSTANDARD LVCMOS33 } [get_ports { sw[4] }];
set_property -dict { PACKAGE_PIN R2   IOSTANDARD LVCMOS33 } [get_ports { sw[5] }];
set_property -dict { PACKAGE_PIN R1   IOSTANDARD LVCMOS33 } [get_ports { sw[6] }];

## ---------------- LEDs (led[0]..led[3]) ----------------
set_property -dict { PACKAGE_PIN G1   IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN F1   IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN F2   IOSTANDARD LVCMOS33 } [get_ports { led[3] }];

## ---------------- Buttons (btn[0]=reset, btn[3]=cancel) ----------------
set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports { btn[0] }];
set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports { btn[1] }];
set_property -dict { PACKAGE_PIN G6   IOSTANDARD LVCMOS33 } [get_ports { btn[2] }];
set_property -dict { PACKAGE_PIN G5   IOSTANDARD LVCMOS33 } [get_ports { btn[3] }];

## ---------------- 7-Segment Display — Segments (active low) ----------------
## seg[0..6] = a..g, seg[7] = DP
set_property -dict { PACKAGE_PIN D5   IOSTANDARD LVCMOS33 } [get_ports { seg[0] }];
set_property -dict { PACKAGE_PIN C4   IOSTANDARD LVCMOS33 } [get_ports { seg[1] }];
set_property -dict { PACKAGE_PIN C5   IOSTANDARD LVCMOS33 } [get_ports { seg[2] }];
set_property -dict { PACKAGE_PIN A4   IOSTANDARD LVCMOS33 } [get_ports { seg[3] }];
set_property -dict { PACKAGE_PIN B4   IOSTANDARD LVCMOS33 } [get_ports { seg[4] }];
set_property -dict { PACKAGE_PIN A3   IOSTANDARD LVCMOS33 } [get_ports { seg[5] }];
set_property -dict { PACKAGE_PIN B3   IOSTANDARD LVCMOS33 } [get_ports { seg[6] }];
set_property -dict { PACKAGE_PIN A5   IOSTANDARD LVCMOS33 } [get_ports { seg[7] }];

## ---------------- 7-Segment Display — Anodes (active low) ----------------
set_property -dict { PACKAGE_PIN H3   IOSTANDARD LVCMOS33 } [get_ports { an[0] }];
set_property -dict { PACKAGE_PIN J4   IOSTANDARD LVCMOS33 } [get_ports { an[1] }];
set_property -dict { PACKAGE_PIN F3   IOSTANDARD LVCMOS33 } [get_ports { an[2] }];
set_property -dict { PACKAGE_PIN E4   IOSTANDARD LVCMOS33 } [get_ports { an[3] }];

## ---------------- CFGBVS / CONFIG_VOLTAGE (suppress DRC CFGBVS-1) ----------------
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];

## NOTE: RGB LEDs removed — pins V9/V10/V11 do not exist on XC7S50CSGA324-1.
## If RGB is needed, identify correct pins from Boolean board schematic
## and add: set_property -dict { PACKAGE_PIN ??? IOSTANDARD LVCMOS33 } [get_ports { led_rgb[N] }];
