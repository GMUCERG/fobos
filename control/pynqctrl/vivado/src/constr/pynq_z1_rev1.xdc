	#############################################################################
#                                                                           #
#   Copyright 2019 CERG                                                     #
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
################PMOD Connector (option 1)
#JA
#+----------+----------+----------+----------+
#| SCL      |  din3    |  do_ready|  dut_rst |
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
##############20-pin Connector (option 2)
#FOBOS-Shield Target Connector
#+----------+----------+-------------+-------------+-------------+----------+----------+----------+----------+----------+
#|   GND  19|   GND  17|      T15  15|      V15  13|       V6  11|    V5   9|   U5   7 |   T14   5|    3V3  3|     5V  1|
#|          |          |             |handshake_d2c|handshake_c2d|          |        io|          |          |          |
#+----------+----------+-------------+-------------+-------------+----------+----------+----------+----------+----------+
#|    5V  20|   3V3  18|       V7  16|      V13  14|      U13  12|   U12  10|         8|    Y7   6|    U7   4|    GND  2|
#|          |          |         dio3|         dio2|         dio1|     dio0 |          |   clk_c2d|  d_rst   |          |
#+----------+----------+-------------+-------------+-------------+----------+----------+----------+----------+----------+
##Pmod Header JA
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports {dut_rst}]; #IO_L17P_T2_34 Sch=ja_p[1]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports do_ready]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {din[3]}]
#set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports {iic_rtl_scl_io}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports do_valid]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {din[1]}]; #IO_L12N_T1_MRCC_34 Sch=ja_n[3] 
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {din[2]}]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports {din[0]}]
#Pmod Header JB
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {dut_clk}]; #IO_L8P_T1_34 Sch=jb_p[1]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports di_ready]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {dout[3]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {dout[1]}]
#set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {iic_rtl_sda_io}]; #IO_L18P_T2_34 Sch=jb_p[3]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports di_valid]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {dout[2]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {dout[0]}]
#Audio Out
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { aud_pwm }]; #IO_L20N_T3_34 Sch=aud_pwm
#set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { aud_sd }]; #IO_L20P_T3_34 Sch=aud_sd
##Mic input
#set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports { m_clk }]; #IO_L6N_T0_VREF_35 Sch=m_clk
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { m_data }]; #IO_L16N_T2_35 Sch=m_data
##ChipKit Single Ended Analog Inputs
##NOTE: The ck_an_p pins can be used as single ended analog inputs with voltages from 0-3.3V (Chipkit Analog pins A0-A5).
##      These signals should only be connected to the XADC core. When using these pins as digital I/O, use pins ck_io[14-19].
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {ck_an_n[0]}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {ck_an_p[0]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {ck_an_n[1]}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {ck_an_p[1]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {ck_an_n[2]}]
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports {ck_an_p[2]}]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports {ck_an_n[3]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {ck_an_p[3]}]
set_property -dict { PACKAGE_PIN H20   IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[4] }]; #IO_L17N_T2_AD5N_35 Sch=ck_an_n[4]
set_property -dict { PACKAGE_PIN J20   IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[4] }]; #IO_L17P_T2_AD5P_35 Sch=ck_an_p[4]
set_property -dict { PACKAGE_PIN G20   IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[5] }]; #IO_L18N_T2_AD13N_35 Sch=ck_an_n[5]
set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[5] }]; #IO_L18P_T2_AD13P_35 Sch=ck_an_p[5]
##ChipKit Digital I/O Low
#set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { d_rst }]; #IO_L5P_T0_34 Sch=ck_io[0]
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { fc_dio[0] }]; #IO_L2N_T0_34 Sch=ck_io[1]
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { fc_dio[1] }]; #IO_L3P_T0_DQS_PUDC_B_34 Sch=ck_io[2]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { fc_dio[2] }]; #IO_L3N_T0_DQS_34 Sch=ck_io[3]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { fd2c_hs }]; #IO_L10P_T1_34 Sch=ck_io[4]
#set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { handshake_d2c }]; #IO_L5N_T0_34 Sch=ck_io[5]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { adc[1] }]; #IO_L19P_T3_34 Sch=ck_io[6]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { adc[3] }]; #IO_L9N_T1_DQS_34 Sch=ck_io[7]
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { adc[5] }]; #IO_L21P_T3_DQS_34 Sch=ck_io[8]
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { adc[7] }]; #IO_L21N_T3_DQS_34 Sch=ck_io[9]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { adc[9] }]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {power[0]}]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {power[2]}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {power[4]}]
##ChipKit Digital I/O On Outer Analog Header
##NOTE: These pins should be used when using the analog header signals A0-A5 as digital I/O (Chipkit digital pins 14-19)
#set_property -dict { PACKAGE_PIN Y11   IOSTANDARD LVCMOS33 } [get_ports { ck_io[14] }]; #IO_L18N_T2_13 Sch=ck_a[0]
#set_property -dict { PACKAGE_PIN Y12   IOSTANDARD LVCMOS33 } [get_ports { ck_io[15] }]; #IO_L20P_T3_13 Sch=ck_a[1]
#set_property -dict { PACKAGE_PIN W11   IOSTANDARD LVCMOS33 } [get_ports { ck_io[16] }]; #IO_L18P_T2_13 Sch=ck_a[2]
#set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { ck_io[17] }]; #IO_L21P_T3_DQS_13 Sch=ck_a[3]
#set_property -dict { PACKAGE_PIN T5    IOSTANDARD LVCMOS33 } [get_ports { ck_io[18] }]; #IO_L19P_T3_13 Sch=ck_a[4]
#set_property -dict { PACKAGE_PIN U10   IOSTANDARD LVCMOS33 } [get_ports { ck_io[19] }]; #IO_L12N_T1_MRCC_13 Sch=ck_a[5]
##ChipKit Digital I/O On Inner Analog Header
##NOTE: These pins will need to be connected to the XADC core when used as differential analog inputs (Chipkit analog pins A6-A11)
#set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33} [get_ports {gain_0[1]}]
#set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS33} [get_ports {gain_0[0]}]
#set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports {gain_1[1]}]
#set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports {gain_1[0]}]
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33} [get_ports trigger]
#set_property -dict { PACKAGE_PIN B19   IOSTANDARD LVCMOS33 } [get_ports { ck_io[25] }]; #IO_L2P_T0_AD8P_35 Sch=ad_p[8]
##ChipKit Digital I/O High
set_property -dict { PACKAGE_PIN U5    IOSTANDARD LVCMOS33 } [get_ports { fc_io }]; #IO_L19N_T3_VREF_13 Sch=ck_io[26]
#set_property -dict { PACKAGE_PIN V5    IOSTANDARD LVCMOS33 } [get_ports { d_tf }]; #IO_L6N_T0_VREF_13 Sch=ck_io[27]
set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33 } [get_ports { fc2d_hs }]; #IO_L22P_T3_13 Sch=ck_io[28]
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports { fc_rst }]; #IO_L11P_T1_SRCC_13 Sch=ck_io[29]
#set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports { clk_d2c }]; #IO_L11P_T1_SRCC_13 Sch=ck_io[29]
set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33 } [get_ports { fc_dio[3] }]; #IO_L11N_T1_SRCC_13 Sch=ck_io[30]
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS33 } [get_ports { adc[0] }]; #IO_L17N_T2_13 Sch=ck_io[31]
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports { adc[2] }]; #IO_L15P_T2_DQS_13 Sch=ck_io[32]
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { adc[4] }]; #IO_L21N_T3_DQS_13 Sch=ck_io[33]
set_property -dict { PACKAGE_PIN W10   IOSTANDARD LVCMOS33 } [get_ports { adc[6] }]; #IO_L16P_T2_13 Sch=ck_io[34]
set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33 } [get_ports { adc[8] }]; #IO_L22N_T3_13 Sch=ck_io[35]
set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33 } [get_ports { adc_or }]; #IO_L13N_T2_MRCC_13 Sch=ck_io[36]
set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33 } [get_ports { fc2d_clk }]; #IO_L13P_T2_MRCC_13 Sch=ck_io[37]
set_property -dict {PACKAGE_PIN W8 IOSTANDARD LVCMOS33} [get_ports {power[1]}]
set_property -dict {PACKAGE_PIN Y8 IOSTANDARD LVCMOS33} [get_ports {power[3]}]
set_property -dict {PACKAGE_PIN W9 IOSTANDARD LVCMOS33} [get_ports {power[5]}]
set_property -dict { PACKAGE_PIN Y9    IOSTANDARD LVCMOS33 } [get_ports { adc_clk }]; #IO_L14P_T2_SRCC_13 Sch=ck_io[41]
set_property drive 16 [get_ports adc_clk]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS33} [get_ports power_ok]
## ChipKit SPI
#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports { glitch_hp }]; #IO_L10N_T1_34 Sch=ck_miso
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { adc_gain }]; #IO_L2P_T0_34 Sch=ck_mosi
#set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { glitch }]; #IO_L19P_T3_35 Sch=ck_sck
set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { adc_gain_mode }]; #IO_L6P_T0_35 Sch=ck_ss
## ChipKit I2C
#set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { ck_scl }]; #IO_L24N_T3_34 Sch=ck_scl
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports power_en]
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
#set_property -dict { PACKAGE_PIN K18   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_n[0] }]; #IO_L12N_T1_MRCC_35 Sch=hdmi_tx_d_n[0]
#set_property -dict { PACKAGE_PIN K17   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_p[0] }]; #IO_L12P_T1_MRCC_35 Sch=hdmi_tx_d_p[0]
#set_property -dict { PACKAGE_PIN J19   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_n[1] }]; #IO_L10N_T1_AD11N_35 Sch=hdmi_tx_d_n[1]
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_p[1] }]; #IO_L10P_T1_AD11P_35 Sch=hdmi_tx_d_p[1]
#set_property -dict { PACKAGE_PIN H18   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_n[2] }]; #IO_L14N_T2_AD4N_SRCC_35 Sch=hdmi_tx_d_n[2]
#set_property -dict { PACKAGE_PIN J18   IOSTANDARD TMDS_33  } [get_ports { hdmi_tx_d_p[2] }]; #IO_L14P_T2_AD4P_SRCC_35 Sch=hdmi_tx_d_p[2]
#set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_hpdn }]; #IO_0_34 Sch=hdmi_tx_hpdn
#set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_scl }]; #IO_L8P_T1_AD10P_35 Sch=hdmi_tx_scl
#set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_sda }]; #IO_L8N_T1_AD10N_35 Sch=hdmi_tx_sda
##Crypto SDA
#set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { crypto_sda }]; #IO_25_35 Sch=crypto_sda