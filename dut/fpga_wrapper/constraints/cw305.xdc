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

#Purpose : XDC file for CW305 target board to connect to FOBOS Shield 20-pin connector
#Author : Abubakr Abdulgadir
#Date : 3/25/2021
#Updated: 8/11/22 Kaps, updated pin names to new standard
#Note make sure that the xdc file in pynq board is pynq_cw305_half_duplex.xdc

#CW305 20-pin connector pin map
#+----------+----------+---------+----------+----------+----------+----------+----------+----------+----------+
#|   GND  19|   GND  17|       15|  R15   13|   P15  11|         9|    N16  7|         5|    3V3  3|     5V  1|
#|          |          |         |   fd2c_hs|   fc2d_hs|          |     fc_io|          |          |          |
#+----------+----------+---------+----------+----------+----------+----------+----------+----------+----------+
#|    5V  20|   3V3  18| T14   16|  T15   14|   R16  12|   P16  10|         8|   N14   6|    M16  4|    GND  2|
#|          |          |  fc_dio3|   fc_dio2|   fc_dio1|   fc_dio0|          |  fc2d_clk|    fc_rst|          |
#+----------+----------+---------+----------+----------+----------+----------+----------+----------+----------+

#clock
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports fc2d_clk]
create_clock -period 50.000 -name sys_clk [get_ports fc2d_clk]

#handshake
set_property -dict { PACKAGE_PIN N16    IOSTANDARD LVCMOS33 } [get_ports { fc_io }];
set_property -dict { PACKAGE_PIN M16    IOSTANDARD LVCMOS33 } [get_ports { fc_rst }];
set_property -dict { PACKAGE_PIN P15    IOSTANDARD LVCMOS33 } [get_ports { fc2d_hs }];
set_property -dict { PACKAGE_PIN R15    IOSTANDARD LVCMOS33 } [get_ports { fd2c_hs }];

#data
set_property -dict { PACKAGE_PIN P16    IOSTANDARD LVCMOS33 } [get_ports { fc_dio[0] }];
set_property -dict { PACKAGE_PIN R16    IOSTANDARD LVCMOS33 } [get_ports { fc_dio[1] }];
set_property -dict { PACKAGE_PIN T15    IOSTANDARD LVCMOS33 } [get_ports { fc_dio[2] }];
set_property -dict { PACKAGE_PIN T14    IOSTANDARD LVCMOS33 } [get_ports { fc_dio[3] }];


