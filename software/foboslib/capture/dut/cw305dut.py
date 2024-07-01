
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
from chipwhisperer.capture.targets.CW305 import CW305


class DUT:

    def __init__(self):
        self.bitFile = ""
        self.deviceID = "CW305"
        
    def setBitFile(self, bitFile):
        self.bitFile = bitFile

    def program(self):
        """
        Uses NewAE Chipwhisperer library to program CW305 
        This requires Chipwhisperer to be installed
        """
        if self.bitFile == "":
            print("FATAL Error: DUT programming bit file not set. Please set it to a valid .bit file. Exiting...")
            exit()

        if os.path.isfile(self.bitFile) == True:
            # print("programming DUT. Please wait ...")
            cw = CW305()
            cw.con(bsfile=self.bitFile, force=True)
            print("CW305 DUT programming done!")
            cw.dis()
        else:
            print(f"FATAL Error: DUT programming bit file :{self.bitFile} does not exist. \nPlease set it to a valid .bit file. Exiting...")
            exit()

def test():
    dut = DUT()
    bitFile = "/home/aabdulga/vivado_projects/aes_cw305_half_duplex/aes_cw305_half_duplex.runs/impl_1/half_duplex_dut.bit"
    dut.setBitFile(bitFile)
    dut.program()

if __name__ == "__main__":
    test()
