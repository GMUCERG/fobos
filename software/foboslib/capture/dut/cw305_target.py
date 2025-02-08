
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
# This can be used to program CW305 DUT
# Requiremet : This requires Chipwhispere utilities to be installed
import os
import sys
from .target import Target
from chipwhisperer.capture.targets.CW305 import CW305


class Cw305_target(Target):

    def __init__(self, device_id=None):
        self._type = 'cw305'
        self._device_id = device_id # here device id is the board serial number
        # Serail number can be found using : lsusb -d 2b3e:c305 -v  | grep iSerial | awk '{print $3}'

    def program(self, bit_file):
        """
        Uses NewAE Chipwhisperer library to program CW305 
        This requires Chipwhisperer to be installed
        """
        if os.path.isfile(bit_file) == True:
            # print("programming DUT. Please wait ...")
            cw = CW305()
            cw.con(bsfile=bit_file, sn=self._device_id, force=True)
            print("CW305 DUT programming done!")
            cw.dis()
        else:
            print(f"FATAL Error: DUT programming bit file : {bit_file} does not exist. \nPlease set it to a valid .bit file. Exiting...")
            sys.exit()

def test():
    sn1 = '50203120355448513230353238313038'
    sn2 = '4420312043304a383330313238313036'
    target = Cw305_target(device_id=sn1)
    bit_file = "/home/bakry/projects/GMU/fobos-proj/fobos-dev1/fobos/projects/aes/vivado/aes-128/aes-128.runs/impl_1/half_duplex_dut.bit"
    target.program(bit_file=bit_file)

if __name__ == "__main__":
    test()
