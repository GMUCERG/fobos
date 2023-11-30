#############################################################################
#                                                                           #   
#   Company: Crytpographic Engineering Research Group (CERG)                #
#   URL: http://cryptography.gmu.edu                                        # 
#   Author: Jens-Peter Kaps                                                 #
#   Description:                                                            #
#   Constraint file for FOBOS Shield revision 1.0 on PYNQ-Z2 board          #
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

## XADC inputs
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports {ck_an_p[0]}]; # Current on Var(iable) supply
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports {ck_an_n[0]}]; 
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports {ck_an_p[1]}]; # Voltage on Var(iable) supply
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {ck_an_n[1]}]; 
set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports {ck_an_p[2]}]; # Current on 5V supply
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports {ck_an_n[2]}]; 
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports {ck_an_p[3]}]; # Voltage on 5V supply
set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports {ck_an_n[3]}]; 
set_property -dict { PACKAGE_PIN J20   IOSTANDARD LVCMOS33 } [get_ports {ck_an_p[4]}]; # Current on 3V3 supply
set_property -dict { PACKAGE_PIN H20   IOSTANDARD LVCMOS33 } [get_ports {ck_an_n[4]}]; 
set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [get_ports {ck_an_p[5]}]; # Voltage on 3V3 supply
set_property -dict { PACKAGE_PIN G20   IOSTANDARD LVCMOS33 } [get_ports {ck_an_n[5]}]; 

## Current Sense Monitor Gain Selects
# set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { ar[0] }];    # 
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports {gain_3v3[0]}]; # CSM 3V3 supply
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports {gain_3v3[1]}]; #
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports {gain_5v[0]}];  # CSM 5V supply
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {gain_5v[1]}];  #
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports {gain_var[1]}]; # CSM Var(iable) supply
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports {gain_var[0]}]; #

## OpenADC ports
set_property -dict { PACKAGE_PIN W9    IOSTANDARD LVCMOS33 } [get_ports {adc[0]}];        # RPIO14 - rpio_26_r
set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS33 } [get_ports {adc[1]}];        # RPIO21 - rpio_20_r
set_property -dict { PACKAGE_PIN Y8    IOSTANDARD LVCMOS33 } [get_ports {adc[2]}];        # RPIO13 - rpio_19_r
set_property -dict { PACKAGE_PIN B19   IOSTANDARD LVCMOS33 } [get_ports {adc[3]}];        # RPIO20 - rpio_16_r
set_property -dict { PACKAGE_PIN W8    IOSTANDARD LVCMOS33 } [get_ports {adc[4]}];        # RPIO12 - rpio_13_r
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports {adc[5]}];        # JA3_P  - rpio_06_r
set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports {adc[6]}];        # RPIO19 - rpio_12_r
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports {adc[7]}];        # JA1_N  - rpio_05_r
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {adc[8]}];        # JA3_N  - rpio_07_r
set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports {adc[9]}];        # RPIO16 - rpio_08_r
set_property -dict { PACKAGE_PIN W10   IOSTANDARD LVCMOS33 } [get_ports {adc_or}];        # RPIO08 - rpio_11_r

set_property -dict { PACKAGE_PIN Y9    IOSTANDARD LVCMOS33 } [get_ports {adc_clk}];       # RPIO15 - rpio_21_r, bridge R65!
set_property drive 16 [get_ports adc_clk]

set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports {adc_gain_mode}]; # RPIO07 - rpio_09_r
set_property -dict { PACKAGE_PIN F20   IOSTANDARD LVCMOS33 } [get_ports {adc_gain}];      # RPIO17 - rpio_25_r

## Glitch Circuit
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports {glitch}];        # spi_mosi
set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports {glitch_lp}];     # spi_ss

## Power
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {power[0]}];      # ar[8]
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports {power[1]}];      # ar[9]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports {power[2]}];      # ar[10]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports {power[3]}];      # ar[11]
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports {power[4]}];      # ar[12]
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports {power[5]}];      # ar[13]

set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports {power_ok}];      # Power Good
set_property -dict { PACKAGE_PIN Y13   IOSTANDARD LVCMOS33 } [get_ports {power_en}];      # a

## TARGET Header
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {fc_rst}];        # JA4_P  - rpio_02_r

set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports {fc_dio[0]}];     # JA1_P  - rpio_04_r
set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33 } [get_ports {fc_dio[1]}];     # RPIO10 - rpio_15_r
set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33 } [get_ports {fc_dio[2]}];     # RPIO04 - rpio_27_r
set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33 } [get_ports {fc_dio[3]}];     # RPIO09 - rpio_23_r

set_property -dict { PACKAGE_PIN C20   IOSTANDARD LVCMOS33 } [get_ports {fc2d_hs}];       # RPIO18 - rpio_18_r
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS33 } [get_ports {fd2c_hs}];       # RPIO05 - rpio_22_r
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports {fc_io}];         # JA4_N  - rpio_03_r

set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports {fc_prog}];       # RPIO06 - rpio_10_r
set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33 } [get_ports {fd_tf}];         # RPIO02 - rpio_14_r

set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33 } [get_ports {fc2d_clk}];      # RPIO11 - rpio_24_r
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports {fd2c_clk}];      # RPIO03 - rpio_17_r

## TRIGGER
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports {trigger_osc}];   # ar_scl

##LEDs

set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { led[0] }];      #LED 0
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { led[1] }];      #LED 1
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { led[2] }];      #LED 2
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { led[3] }];      #LED 3



## Clock signal 125 MHz

#set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { sysclk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
#create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sysclk }];



##PmodB

#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports { jb[0] }]; #IO_L8P_T1_34 Sch=jb_p[1]
#set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33 } [get_ports { jb[1] }]; #IO_L8N_T1_34 Sch=jb_n[1]
#set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { jb[2] }]; #IO_L1P_T0_34 Sch=jb_p[2]
#set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { jb[3] }]; #IO_L1N_T0_34 Sch=jb_n[2]
#set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { jb[4] }]; #IO_L18P_T2_34 Sch=jb_p[3]
#set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { jb[5] }]; #IO_L18N_T2_34 Sch=jb_n[3]
#set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { jb[6] }]; #IO_L4P_T0_34 Sch=jb_p[4]
#set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { jb[7] }]; #IO_L4N_T0_34 Sch=jb_n[4]


## Arduino SPI

#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports { ck_miso }]; #IO_L10N_T1_34 Sch=miso
#set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { ck_sck }]; #IO_L19P_T3_35 Sch=sck

## Arduino I2C

#set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { ar_sda }]; #IO_L24P_T3_34 Sch=ar_sda


##HDMI Rx

#set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_cec }]; #IO_L13N_T2_MRCC_35 Sch=hdmi_rx_cec
#set_property -dict { PACKAGE_PIN P19   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx_clk_n }]; #IO_L13N_T2_MRCC_34 Sch=hdmi_rx_clk_n
#set_property -dict { PACKAGE_PIN N18   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx_clk_p }]; #IO_L13P_T2_MRCC_34 Sch=hdmi_rx_clk_p
#set_property -dict { PACKAGE_PIN W20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx_d_n[0] }]; #IO_L16N_T2_34 Sch=hdmi_rx_d_n[0]
#set_property -dict { PACKAGE_PIN V20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx_d_p[0] }]; #IO_L16P_T2_34 Sch=hdmi_rx_d_p[0]
#set_property -dict { PACKAGE_PIN U20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx_d_n[1] }]; #IO_L15N_T2_DQS_34 Sch=hdmi_rx_d_n[1]
#set_property -dict { PACKAGE_PIN T20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx_d_p[1] }]; #IO_L15P_T2_DQS_34 Sch=hdmi_rx_d_p[1]
#set_property -dict { PACKAGE_PIN P20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx_d_n[2] }]; #IO_L14N_T2_SRCC_34 Sch=hdmi_rx_d_n[2]
#set_property -dict { PACKAGE_PIN N20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx_d_p[2] }]; #IO_L14P_T2_SRCC_34 Sch=hdmi_rx_d_p[2]
#set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_hpd }]; #IO_25_34 Sch=hdmi_rx_hpd
#set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_scl }]; #IO_L11P_T1_SRCC_34 Sch=hdmi_rx_scl
#set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_sda }]; #IO_L11N_T1_SRCC_34 Sch=hdmi_rx_sda

##HDMI Tx

#set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_cec }]; #IO_L19N_T3_VREF_35 Sch=hdmi_tx_cec
#set_property -dict { PACKAGE_PIN L17   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_clk_n }]; #IO_L11N_T1_SRCC_35 Sch=hdmi_tx_clk_n
#set_property -dict { PACKAGE_PIN L16   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_clk_p }]; #IO_L11P_T1_SRCC_35 Sch=hdmi_tx_clk_p
#set_property -dict { PACKAGE_PIN K18   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_n[0] }]; #IO_N_T1_MRCC_35 Sch=hdmi_tx_d_n[0]
#set_property -dict { PACKAGE_PIN K17   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_p[0] }]; #IO_L12P_T1_MRCC_35 Sch=hdmi_tx_d_p[0]
#set_property -dict { PACKAGE_PIN J19   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_n[1] }]; #IO_L10N_T1_AD11N_35 Sch=hdmi_tx_d_n[1]
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_p[1] }]; #IO_L10P_T1_AD11P_35 Sch=hdmi_tx_d_p[1]
#set_property -dict { PACKAGE_PIN H18   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_n[2] }]; #IO_L14N_T2_AD4N_SRCC_35 Sch=hdmi_tx_d_n[2]
#set_property -dict { PACKAGE_PIN J18   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_p[2] }]; #IO_L14P_T2_AD4P_SRCC_35 Sch=hdmi_tx_d_p[2]
#set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_hpdn }]; #IO_0_34 Sch=hdmi_tx_hpdn


##Crypto SDA 

#set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { crypto_sda }]; #IO_25_35 Sch=crypto_sda
