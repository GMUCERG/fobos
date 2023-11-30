#############################################################################
#                                                                           #   
#   Company: Crytpographic Engineering Research Group (CERG)                #
#   URL: http://cryptography.gmu.edu                                        # 
#   Author: Jens-Peter Kaps                                                 #
#   Description:                                                            #
#   Constraint file for FOBOS Shield revision 2.0 on PYNQ-Z1 board          #
#                                                                           # 
#   Copyright 2023 CERG                                                     #
#                                                                           #
#   Licensed under the Apache License, Version 2.0 (the "License");         #
#   you may not use this file except in compliance with the License.        #
#   You may obtain a copy of the License at                                 #
#                                                                           #
#       http://www.apache.org/licenses/LICENSE-2.0                          #
#                                                                           #
#   Unless required by applicable law or agreed to in writing, software     #
#   distributed under the License is distributed on an "AS IS" BASIS,       #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.#
#   See the License for the specific language governing permissions and     #
#   limitations under the License.                                          #
#                                                                           #
#############################################################################
#JA
#+----------+----------+----------+----------+
#| SCL      |  din3    |  do_ready|  rst     |
#|          |          |          |          |
#+----------+----------+----------+----------+
#|  din0    |  din2    |  din1    |  do_valid|
#|          |          |          |          |
#+----------+----------+----------+----------+

#JB
#+----------+----------+----------+----------+
#|  dout1   |  dout3   |  di_ready|  dut_clk |
#|          |          |          |          |
#+----------+----------+----------+----------+
#|  dout0   |  dout2   |  di_valid|  SDA     |
#|          |          |          |          |
#+----------+----------+----------+----------+

##Pmod Header JA

set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports { dut_rst }]; #IO_L17P_T2_34 Sch=ja_p[1]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports do_ready]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {din[3]}]
#set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports {iic_rtl_scl_io}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports do_valid]
##repeated for Artix7 DUT
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {din[1]}]; #IO_L12N_T1_MRCC_34 Sch=ja_n[3] 
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {din[2]}]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports {din[0]}]

#Pmod Header JB

set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {dut_clk}]; #IO_L8P_T1_34 Sch=jb_p[1]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports di_ready]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {dout[3]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {dout[1]}]
#set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports { iic_rtl_sda_io }]; #IO_L18P_T2_34 Sch=jb_p[3]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports di_valid]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {dout[2]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {dout[0]}]

## XADC inputs
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {ck_an_n[0]}];  # Current on 3V3 supply
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {ck_an_p[0]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {ck_an_n[1]}];  # Voltage on 3V3 supply
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {ck_an_p[1]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {ck_an_n[2]}];  # Current on Var(iable) supply
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports {ck_an_p[2]}]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports {ck_an_n[3]}];  # Voltage on Var(iable) supply
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {ck_an_p[3]}]
set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS33} [get_ports {ck_an_n[4]}];  # Current on 5V supply
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports {ck_an_p[4]}]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports {ck_an_n[5]}];  # Voltage on 5V supply
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {ck_an_p[5]}]

## Current Sense Monitor Gain Selects
set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports {gain_3v3[1]}];  # CSM 3V3 supply
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports {gain_3v3[0]}]
set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS33} [get_ports {gain_var[1]}];  # CSM Var(iable) supply
set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33} [get_ports {gain_var[0]}]
set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS33} [get_ports {gain_5v[0]}];  # CSM 5V supply
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33} [get_ports {gain_5v[1]}]

## OpenADC ports
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {adc[0]}];        #IO0
set_property -dict {PACKAGE_PIN U5  IOSTANDARD LVCMOS33} [get_ports {adc[1]}];        #IO26
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {adc[2]}];        #IO1
set_property -dict {PACKAGE_PIN V5  IOSTANDARD LVCMOS33} [get_ports {adc[3]}];        #IO27
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {adc[4]}];        #IO2
set_property -dict {PACKAGE_PIN V6  IOSTANDARD LVCMOS33} [get_ports {adc[5]}];        #IO28
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {adc[6]}];        #IO3
set_property -dict {PACKAGE_PIN V7  IOSTANDARD LVCMOS33} [get_ports {adc[7]}];        #IO30
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {adc[8]}];        #IO4
set_property -dict {PACKAGE_PIN U8  IOSTANDARD LVCMOS33} [get_ports {adc[9]}];        #IO31
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {adc_or}];        #IO5

set_property -dict {PACKAGE_PIN U7  IOSTANDARD LVCMOS33} [get_ports {adc_clk}];       #IO29
set_property drive 16 [get_ports adc_clk]

set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {adc_gain_mode}]; #spi-miso
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {adc_gain}];      #spi-sck

## Glitch Circuit
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports {glitch}];        #spi-mosi
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports {glitch_lp}];     #spi-ss

## Power
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {power[0]}];      #IO11
set_property -dict {PACKAGE_PIN W8  IOSTANDARD LVCMOS33} [get_ports {power[1]}];      #IO38
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {power[2]}];      #IO12
set_property -dict {PACKAGE_PIN Y8  IOSTANDARD LVCMOS33} [get_ports {power[3]}];      #IO39
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {power[4]}];      #IO13
set_property -dict {PACKAGE_PIN W9  IOSTANDARD LVCMOS33} [get_ports {power[5]}];      #IO40

set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {power_ok}];      #IO10
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS33} [get_ports {power_en}];      #IOA

## TARGET Header
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {fc_rst}];        #i2c-sda

set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports {fc_dio[0]}];     #IO9
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {fc_dio[1]}];     #IO8
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {fc_dio[2]}];     #IO7
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {fc_dio[3]}];     #IO6

set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS33} [get_ports {fc2d_hs}];       #IO34 
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {fd2c_hs}];       #IO33
set_property -dict {PACKAGE_PIN Y6  IOSTANDARD LVCMOS33} [get_ports {fc_io}];         #IO36


set_property -dict {PACKAGE_PIN V8  IOSTANDARD LVCMOS33} [get_ports {fc_prog}];       #IO32
set_property -dict {PACKAGE_PIN W6  IOSTANDARD LVCMOS33} [get_ports {fd_tf}];         #IO35

set_property -dict {PACKAGE_PIN Y7  IOSTANDARD LVCMOS33} [get_ports {fc2d_clk}];      #IO37
set_property -dict {PACKAGE_PIN Y9  IOSTANDARD LVCMOS33} [get_ports {fd2c_clk}];      #IO41

## TRIGGER
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {trigger_osc}];   #i2c-scl

## LEDs
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports { led[0] }];       #LED 0
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports { led[1] }];       #LED 1
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports { led[2] }];       #LED 2
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports { led[3] }];       #LED 3
