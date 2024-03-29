##################################################################################
#                                                                                #
#   Copyright 2022 Cryptographic Engineering Research Group (CERG)               #
#   George Mason University                                                      #
#   http://cryptography.gmu.edu/fobos                                            #
#                                                                                #
#   you may not use this file except in compliance with the License.             #
#   You may obtain a copy of the License at                                      #
#                                                                                #
#       http://www.apache.org/licenses/LICENSE-2.0                               #
#                                                                                #
#   Licensed under the Apache License, Version 2.0 (the "License");              #
#   Unless required by applicable law or agreed to in writing, software          #
#   distributed under the License is distributed on an "AS IS" BASIS,            #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.     #
#   See the License for the specific language governing permissions and          #
#   limitations under the License.                                               #
#                                                                                #
##################################################################################
## xdc file for the FOBOS Artix-7 DUT board with an XC7A12T-CPG238 FPGA
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project


## Target Connector
# ====================================================================================
# Pin name = IO_L2P_T0_D02_14              Schematic name = FC_RST
set_property PACKAGE_PIN E19 [get_ports {fc_rst}] 
	set_property IOSTANDARD LVCMOS33 [get_ports {fc_rst}]
# Pin name = IO_L15P_T2_DQS_RDWR_B_14      Schematic name = FC_IO
set_property PACKAGE_PIN R19 [get_ports {fc_io}] 
	set_property IOSTANDARD LVCMOS33 [get_ports {fc_io}]
# Pin name = IO_L20P_T3_A08_D24_14         Schematic name = FC2D_HS
set_property PACKAGE_PIN W17 [get_ports {fc2d_hs}] 
	set_property IOSTANDARD LVCMOS33 [get_ports {fc2d_hs}]
# Pin name = IO_L24N_T3_A00_D16_14         Schematic name = FD2C_HS
set_property PACKAGE_PIN W16 [get_ports {fd2c_hs}] 
	set_property IOSTANDARD LVCMOS33 [get_ports {fd2c_hs}]
# Pin name = IO_L12P_T1_MRCC_14            Schematic name = FD2C_CLK
# set_property PACKAGE_PIN K17 [get_ports {fd2c_clk}] 
#	set_property IOSTANDARD LVCMOS33 [get_ports {fd2c_clk}]
# Pin name = IO_L13P_T2_MRCC_14            Schematic name = FC2D_CLK
set_property PACKAGE_PIN N19 [get_ports {fc2d_clk}] 
	set_property IOSTANDARD LVCMOS33 [get_ports {fc2d_clk}]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports fc2d_clk]
    # set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets fc2d_clk_IBUF]
# Pin name = IO_L15N_T2_DQS_DOUT_CSO_B_14  Schematic name = FC_DIO0_MUX
set_property PACKAGE_PIN T19 [get_ports {fc_dio[0]}] 
	set_property IOSTANDARD LVCMOS33 [get_ports {fc_dio[0]}]
# Pin name = IO_L16P_T2_CSI_B_14           Schematic name = FC_DIO1_MUX
set_property PACKAGE_PIN U19 [get_ports {fc_dio[1]}] 
	set_property IOSTANDARD LVCMOS33 [get_ports {fc_dio[1]}]
# Pin name = IO_L16N_T2_A15_D31_14         Schematic name = FC_DIO2_MUX
set_property PACKAGE_PIN V19 [get_ports {fc_dio[2]}] 
	set_property IOSTANDARD LVCMOS33 [get_ports {fc_dio[2]}]
# Pin name = IO_L20N_T3_A07_D23_14         Schematic name = FC_DIO3_MUX
set_property PACKAGE_PIN W18 [get_ports {fc_dio[3]}] 
	set_property IOSTANDARD LVCMOS33 [get_ports {fc_dio[3]}]
 

## User Buttons
# ====================================================================================
# Pin name = IO_L10N_T1_AD4N_15            Schematic name = USER_BTN_1
# set_property PACKAGE_PIN A15 [get_ports {user_btn1}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {user_btn1}]
# 	# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets user_btn1]
# # Pin name = IO_L3P_T0_DQS_34              Schematic name = USER_BTN_2
# set_property PACKAGE_PIN H1  [get_ports {user_btn2}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {user_btn2}]
# 	set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets user_btn2]


## User LEDs
# ====================================================================================
# Pin name = IO_L10P_T1_AD4P_15            Schematic name = USER_LED_1
# set_property PACKAGE_PIN A14 [get_ports {user_led1}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {user_led1}]
# # Pin name = IO_L1N_T0_34                  Schematic name = USER_LED_2
# set_property PACKAGE_PIN G1  [get_ports {user_led2}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {user_led2}]
# # Pin name = IO_L3N_T0_DQS_34              Schematic name = USER_LED_3
# set_property PACKAGE_PIN J1  [get_ports {user_led3}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {user_led3}]
# # Pin name = IO_L4N_T0_34                  Schematic name = USER_LED_4
# set_property PACKAGE_PIN K1  [get_ports {user_led4}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {user_led4}]


## PMOD Connector
# ====================================================================================
# Pin name = IO_L14N_T2_SRCC_34            Schematic name = JA1
# set_property PACKAGE_PIN V1  [get_ports {ja[0]}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {ja[0]}]
# # Pin name = IO_L11N_T1_SRCC_34            Schematic name = JA2
# set_property PACKAGE_PIN T1  [get_ports {ja[1]}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {ja[1]}]
# # Pin name = IO_L9N_T1_DQS_34              Schematic name = JA3
# set_property PACKAGE_PIN P1  [get_ports {ja[2]}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {ja[2]}]
# # Pin name = IO_L7N_T1_34                  Schematic name = JA4
# set_property PACKAGE_PIN M1  [get_ports {ja[3]}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {ja[3]}]
# # Pin name = IO_L14P_T2_SRCC_34            Schematic name = JA7
# set_property PACKAGE_PIN U1  [get_ports {ja[4]}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {ja[4]}]
# # Pin name = IO_L11P_T1_SRCC_34            Schematic name = JA8
# set_property PACKAGE_PIN R1  [get_ports {ja[5]}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {ja[5]}]
# # Pin name = IO_L9P_T1_DQS_34              Schematic name = JA9
# set_property PACKAGE_PIN N1  [get_ports {ja[6]}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {ja[6]}]
# # Pin name = IO_L7P_T1_34                  Schematic name = JA10
# set_property PACKAGE_PIN L1  [get_ports {ja[7]}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {ja[7]}]


## Current Measurement
# ====================================================================================
# Pin name = IO_L20P_T3_34                 Schematic name = VCORE_CURRENT_GAIN_0
# set_property PACKAGE_PIN W6  [get_ports {gain[0]}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {gain[0]}]
# # Pin name = IO_L20N_T3_34                 Schematic name = VCORE_CURRENT_GAIN_1
# set_property PACKAGE_PIN W5  [get_ports {gain[1]}] 
# 	set_property IOSTANDARD LVCMOS33 [get_ports {gain[1]}]


## Don't use these signals
# ====================================================================================
# 
# W9   IO_L23P_T3_34                 TDO
# D17  IO_0_14                       MOSI
# D18  IO_L1P_T0_D00_MOSI_14         MOSI
# D19  IO_L1N_T0_D01_DIN_14          DIN
# E17  IO_L3P_T0_DQS_PUDC_B_14       PUDC
# G19  IO_L6P_T0_FCS_B_14            FCS
# K19  IO_L8N_T1_D12_14              FD2C_CLK - Don't use
# K18  IO_L11P_T1_SRCC_14            FD2C_CLK - Don't use
# W14  IO_L23N_T3_A02_D18_14         MODE_0
# 
# F17  IO_L5P_T0_D06_14              GND
# J19  IO_L8P_T1_D11_14              GND
# M17  IO_L10P_T1_D14_14             GND
# J3   IO_L5P_T0_34                  GND
# M3   IO_L10P_T1_34                 GND
# R3   IO_L12N_T1_MRCC_34            GND
# U5   IO_L19N_T3_VREF_34            GND
# W8   IO_L23N_T3_34                 GND
# C7   MGTRREF_216                   GND
# B6   MGTPRXP1_216                  GND
# B4   MGTPRXP0_216                  GND
# A6   MGTPRXN1_216                  GND
# A4   MGTPRXN0_216                  GND
#
# Other pins are not connected

 



