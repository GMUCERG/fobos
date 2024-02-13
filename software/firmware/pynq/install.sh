#! /bin/bash
#############################################################################
#   install - FOBOS                                                         #
#   -----------------------                                                 #          
#   wrapper for FOBOS install script for Xilinx Pynq Z1 or Z2               #
#                                                                           #
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



#--- Checking if $BOARD is set
if [ -z $BOARD ]; then
    echo "The environmen variable BOARD is not set."
#--- Check if running as root
    if [ "$EUID" -eq 0 ]; then
        echo "This might be because you are running this script as root. Try running it as normal user"
    else
        echo "Please set it manually and run this script again."
	exit
    fi
else
    sudo BOARD=$BOARD ./pynq-inst
fi
