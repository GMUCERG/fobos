##################################################################################
#                                                                                #
#   Copyright 2019 Cryptographic Engineering Research Group (CERG)               #
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
## xdc file for the Nexys4 rev B board and usage with the FOBOS MTC
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
##Bank = 35, Pin name = IO_L12P_T1_MRCC_35,					Sch name = CLK100MHZ
#set_property PACKAGE_PIN E3 [get_ports clk]							
	#set_property IOSTANDARD LVCMOS33 [get_ports clk]
	#create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
 
##Pmod Header JA and JB are used for the MTC
# ======================== Data in/out from/to Control ===========================
##Bank = 14, Pin name = IO_L19N_T3_A09_D25_VREF_14,	                Sch name = JB10 
set_property PACKAGE_PIN U11 [get_ports {dio[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {dio[0]}]
##Bank = CONFIG, Pin name = IO_L16P_T2_CSI_B_14,                    Sch name = JB4
set_property PACKAGE_PIN V15 [get_ports {dio[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {dio[1]}]
##Bank = 14, Pin name = IO_L24P_T3_A01_D17_14,                      Sch name = JB9
set_property PACKAGE_PIN T9 [get_ports {dio[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {dio[2]}]
##Bank = 14, Pin name = IO_L21N_T3_DQS_A06_D22_14,                  Sch name = JB3
set_property PACKAGE_PIN V11 [get_ports {dio[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {dio[3]}]
# ============================= CONTROL SIGNALS ==================================
##Bank = 15, Pin name = IO_L20N_T3_A19_15,                          Sch name = JA8
set_property PACKAGE_PIN C17 [get_ports {clk_c2d}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {clk_c2d}]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_c2d]
    set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_c2d_IBUF]
##Bank = 14, Pin name = IO_L13P_T2_MRCC_14,                         Sch name = JB2
set_property PACKAGE_PIN P15 [get_ports {handshake_c2d}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {handshake_c2d}]
##Bank = CONFIG, Pin name = IO_L15P_T2_DQS_RWR_B_14,                Sch name = JB8
set_property PACKAGE_PIN R16 [get_ports {handshake_d2c}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {handshake_d2c}]
##Bank = 15, Pin name = IO_L15N_T2_DQS_ADV_B_15,                    Sch name = JB1
set_property PACKAGE_PIN G14 [get_ports {d_rst}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {d_rst}]
##Bank = 15, Pin name = IO_25_15,                                   Sch name = JB7
set_property PACKAGE_PIN K16 [get_ports {io}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {io}]

# ============================ OPTIONAL SIGNALS ==================================

##Pmod Header JA
##Bank = 15, Pin name = IO_L1N_T0_AD0N_15,                          Sch name = JA1
#set_property PACKAGE_PIN B13 [get_ports {tfd}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {tfd}]
##Bank = 15, Pin name = IO_L16P_T2_A28_15,                          Sch name = JA4
#set_property PACKAGE_PIN E17 [get_ports {clk_d2c}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {clk_d2c}]
##Bank = 15, Pin name = IO_0_15,                                    Sch name = JA7
#set_property PACKAGE_PIN G13 [get_ports {aux}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {aux}]

## DEBUG
##Pmod Header JC
##Bank = 35, Pin name = IO_L23P_T3_35,						Sch name = JC1
set_property PACKAGE_PIN K2 [get_ports {di_valid_deb}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {di_valid_deb}]
##Bank = 35, Pin name = IO_L6P_T0_35,						Sch name = JC2
set_property PACKAGE_PIN E7 [get_ports {di_ready_deb}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {di_ready_deb}]
##Bank = 35, Pin name = IO_L22P_T3_35,						Sch name = JC3
set_property PACKAGE_PIN J3 [get_ports {do_valid_deb}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {do_valid_deb}]
##Bank = 35, Pin name = IO_L21P_T3_DQS_35,					Sch name = JC4
set_property PACKAGE_PIN J4 [get_ports {do_ready_deb}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {do_ready_deb}]


##Bank = 15, Pin name = IO_L5N_T0_AD9N_15,					Sch name = JA2
#set_property PACKAGE_PIN F14 [get_ports {JA[1]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[1]}]
##Bank = 15, Pin name = IO_L16N_T2_A27_15,					Sch name = JA3
#set_property PACKAGE_PIN D17 [get_ports {JA[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[2]}]
##Bank = 15, Pin name = IO_L21N_T3_A17_15,					Sch name = JA9
#set_property PACKAGE_PIN D18 [get_ports {JA[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[6]}]
##Bank = 15, Pin name = IO_L21P_T3_DQS_15,					Sch name = JA10
#set_property PACKAGE_PIN E18 [get_ports {JA[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[7]}]




 



