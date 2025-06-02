
#############################################################################
#                                                                           #
#   Copyright 2025 CERG                                                     #
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
# DUT utilities 
# This can be used to program Xilinx FPGAs using jtag
# Requiremet : This requires Vivado (tested using Vivado 2021.1)
# Requirement: This requires xc3sprog to be installed. apt install xc3sprog
import os
import sys
import subprocess
from .target import Target

class Jtag_target(Target):

    def __init__(self, jtag_cable, jtag_position, jtag_serial_number):
        self._type = 'Xilinx_jtag'
         
        self.jtag_cable = jtag_cable
        self.jtag_position = jtag_position
        self.jtag_serial_number = jtag_serial_number
        
    def program(self, bit_file):
        """
        Uses xc3sprog to program
        """
        if os.path.isfile(bit_file) == True:
            # print("programming DUT. Please wait ...")
            script_location = os.path.dirname(os.path.realpath(__file__))
            print(script_location)
            cmd = ['xc3sprog', '-c', self.jtag_cable,  '-p', self.jtag_position, '-v']
            if self.jtag_serial_number != "0":
                cmd += ['-s', self.jtag_serial_number]
            cmd += [bit_file+':w']
            subprocess.run(cmd)
            print("Jtag DUT programming done!")
        else:
            print(f"FATAL Error: DUT programming bit file : {bit_file} does not exist. \nPlease set it to a valid .bit file. Exiting...")
            sys.exit()

def test():
    jtag_target_type = "/xilinx_tcf" 
    jtag_target_name = "/Xilinx/13724327082e01"
    jtag_device_name = "xc7a100t_0"
    bit_file = "/home/bakry/projects/GMU/fobos-proj/fobos-dev1/fobos/projects/aes/vivado/aes-128/aes-128.runs/impl_1/half_duplex_dut.bit"

    target = Jtag_target(jtag_device_name, jtag_target_type, jtag_target_name)
    target.program(bit_file=bit_file)

if __name__ == "__main__":
    test()
