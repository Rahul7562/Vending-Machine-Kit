## Clock signal 100 MHz
set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_15 Sch=uclk

## Switches
set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]; #IO_L9P_T1_DQS_34 Sch=sw[0]
set_property -dict { PACKAGE_PIN U2    IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]; #IO_L9N_T1_DQS_34 Sch=sw[1]
set_property -dict { PACKAGE_PIN U1    IOSTANDARD LVCMOS33 } [get_ports { sw[2] }]; #IO_L10P_T1_34 Sch=sw[2]
set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports { sw[3] }]; #IO_L10N_T1_34 Sch=sw[3]
set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports { sw[4] }]; #IO_L11P_T1_SRCC_34 Sch=sw[4]
set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports { sw[5] }]; #IO_L11N_T1_SRCC_34 Sch=sw[5]
set_property -dict { PACKAGE_PIN R1    IOSTANDARD LVCMOS33 } [get_ports { sw[6] }]; #IO_L12P_T1_MRCC_34 Sch=sw[6]

## LEDs
set_property -dict { PACKAGE_PIN G1    IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; #IO_L24N_T3_35 Sch=led[0]
set_property -dict { PACKAGE_PIN G2    IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; #IO_L24P_T3_35 Sch=led[1]
set_property -dict { PACKAGE_PIN F1    IOSTANDARD LVCMOS33 } [get_ports { led[2] }]; #IO_L23N_T3_35 Sch=led[2]
set_property -dict { PACKAGE_PIN F2    IOSTANDARD LVCMOS33 } [get_ports { led[3] }]; #IO_L23P_T3_35 Sch=led[3]

## RGB LEDs
set_property -dict { PACKAGE_PIN V9    IOSTANDARD LVCMOS33 } [get_ports { led_rgb[0] }]; #IO_L21P_T3_DQS_34 Sch=led0_b
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { led_rgb[1] }]; #IO_L21N_T3_DQS_34 Sch=led0_g
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { led_rgb[2] }]; #IO_L22P_T3_34 Sch=led0_r

## Buttons
set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { btn[0] }]; #IO_L22N_T3_35 Sch=btn[0]
set_property -dict { PACKAGE_PIN J1    IOSTANDARD LVCMOS33 } [get_ports { btn[1] }]; #IO_L22P_T3_35 Sch=btn[1]
set_property -dict { PACKAGE_PIN G6    IOSTANDARD LVCMOS33 } [get_ports { btn[2] }]; #IO_L20P_T3_35 Sch=btn[2]
set_property -dict { PACKAGE_PIN G5    IOSTANDARD LVCMOS33 } [get_ports { btn[3] }]; #IO_L20N_T3_35 Sch=btn[3]

## 7-Segment Display
set_property -dict { PACKAGE_PIN D5    IOSTANDARD LVCMOS33 } [get_ports { seg[0] }]; #IO_L11P_T1_SRCC_35 Sch=seg[0]
set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports { seg[1] }]; #IO_L11N_T1_SRCC_35 Sch=seg[1]
set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports { seg[2] }]; #IO_L10P_T1_AD11P_35 Sch=seg[2]
set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { seg[3] }]; #IO_L12N_T1_MRCC_35 Sch=seg[3]
set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { seg[4] }]; #IO_L12P_T1_MRCC_35 Sch=seg[4]
set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { seg[5] }]; #IO_L13N_T2_MRCC_35 Sch=seg[5]
set_property -dict { PACKAGE_PIN B3    IOSTANDARD LVCMOS33 } [get_ports { seg[6] }]; #IO_L13P_T2_MRCC_35 Sch=seg[6]
set_property -dict { PACKAGE_PIN A5    IOSTANDARD LVCMOS33 } [get_ports { seg[7] }]; #IO_L10N_T1_AD11N_35 Sch=seg[7]

set_property -dict { PACKAGE_PIN H3    IOSTANDARD LVCMOS33 } [get_ports { an[0] }]; #IO_L21N_T3_DQS_35 Sch=an[0]
set_property -dict { PACKAGE_PIN J4    IOSTANDARD LVCMOS33 } [get_ports { an[1] }]; #IO_L21P_T3_DQS_35 Sch=an[1]
set_property -dict { PACKAGE_PIN F3    IOSTANDARD LVCMOS33 } [get_ports { an[2] }]; #IO_L19N_T3_VREF_35 Sch=an[2]
set_property -dict { PACKAGE_PIN E4    IOSTANDARD LVCMOS33 } [get_ports { an[3] }]; #IO_L19P_T3_35 Sch=an[3]
