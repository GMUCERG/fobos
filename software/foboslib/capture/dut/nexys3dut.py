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
# DUT utilities 
# This can be used to program DUT
# Requiremet : This requires Digilent Adept runtime and utilities to be installed

import subprocess


class DUT:

    def __init__(self):
        self.bitFile = ""
        self.deviceID = "Nexys3"
        self.jtagID = 0

    def setBitFile(self, bitFile):
        self.bitFile = bitFile

    def program(self):
        """
        runs a command similar to
        djtgcfg prog -d Nexys3 -i 0 -f ~/fobos_workspace/aes/FOBOS_DUT.bit
        This requires Digilent Adept runtime and utilities to be installed
        """
        if self.bitFile == "":
            print("FATAL Error: DUT programming bit file not set. Please set it to a valid .bit file. Exiting...")
            exit()

        cmd_init = ['djtgcfg', 'init', '-d', self.deviceID]
        cmd_prog = ['djtgcfg', 'prog', '-d', self.deviceID, '-i',
                    str(self.jtagID), '-f', self.bitFile]
        print("Programming device using the following commands:")
        print(" ".join(cmd_init))
        print(" ".join(cmd_prog))
        subprocess.check_output(cmd_init)
        output = subprocess.check_output(cmd_prog)
        # print(output.decode('utf-8'))
        if not (output.strip().endswith(b"Programming succeeded.")):
            print("FATAL Error: DUT programming failed!. Exiting...")
            exit()
        else:
            print('DUT board programmed successfuly.')


def main():
    dut = DUT()
    dut.setBitFile("/home/aabdulga/fobos_workspace/aes/FOBOS_DUT.bit")
    dut.program()


if __name__ == "__main__":
    main()
