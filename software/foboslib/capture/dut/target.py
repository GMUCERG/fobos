
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
# Target (DUT) parent class
class Target:

    def __init__(self):
        self._bit_file = ""
        self._type = None # jtag, cw305, digilent
        self._device_id = None

    def program(self):
        pass
