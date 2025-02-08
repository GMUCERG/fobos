
#############################################################################
#                                                                           #
#   Copyright 2021 CERG                                                     #
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
import os
import sys
import subprocess
from .target import Target

class Jtag_target(Target):

    def __init__(self, jtag_device_name, jtag_target_type, jtag_target_name):
        self._type = 'Xilinx_jtag'
        # self._device_id = device_id # here device id is the device name in Vivado Hardware Manager, e.g, 
        self.jtag_target_type = jtag_target_type
        self.jtag_target_name = jtag_target_name
        self.jtag_device_name = jtag_device_name

        # Serail number can be found using : lsusb -d 2b3e:c305 -v  | grep iSerial | awk '{print $3}'

    def program(self, bit_file):
        """
        Uses Vivado tcl to program e.g
        vivado -mode batch -source prog_fpga.tcl
            -tclargs "xc7a100t_0" 
            -tclargs "/xilinx_tcf" 
            -tclargs "/Xilinx/13724327082e01" 
            -tclargs "path/to/bitfile.bit"
        """
        if os.path.isfile(bit_file) == True:
            # print("programming DUT. Please wait ...")
            script_location = os.path.dirname(os.path.realpath(__file__))
            print(script_location)
            cmd = ['vivado', '-mode', 'batch', '-source']
            cmd += [os.path.join(script_location,  'prog_fpga.tcl')]
            cmd += ['-tclargs', self.jtag_device_name]
            cmd += ['-tclargs', self.jtag_target_type]
            cmd += ['-tclargs', self.jtag_target_name]
            cmd += ['-tclargs', bit_file]
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
