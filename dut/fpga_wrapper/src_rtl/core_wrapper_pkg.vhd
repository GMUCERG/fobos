--#############################################################################
--#                                                                           #
--#   Copyright 2018-2023 Cryptographic Engineering Research Group (CERG)     #
--#                                                                           #
--#   Licensed under the Apache License, Version 2.0 (the "License");         #
--#   you may not use this file except in compliance with the License.        #
--#   You may obtain a copy of the License at                                 #
--#                                                                           #
--#       http://www.apache.org/licenses/LICENSE-2.0                          #
--#                                                                           #
--#   Unless required by applicable law or agreed to in writing, software     #
--#   distributed under the License is distributed on an "AS IS" BASIS,       #
--#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.#
--#   See the License for the specific language governing permissions and     #
--#   limitations under the License.                                          #
--#                                                                           #
--#############################################################################
library ieee;
use ieee.std_logic_1164.all;

package core_wrapper_pkg is
    -- input fifos
    constant FIFO_0_WIDTH           : natural := 128    ;
    constant FIFO_0_LOG2DEPTH       : natural := 1      ;
    constant FIFO_1_WIDTH           : natural := 128    ;
    constant FIFO_1_LOG2DEPTH       : natural := 1      ;
    -- output fifo
    constant FIFO_OUT_WIDTH         : natural := 128    ;    
    constant FIFO_OUT_LOG2DEPTH     : natural := 1      ;
    -- random data
    constant RAND_WORDS             : natural := 8      ;
    constant FIFO_RDI_WIDTH         : natural := 64     ;
    constant FIFO_RDI_LOG2DEPTH     : natural := 3      ;  

end core_wrapper_pkg;

package body core_wrapper_pkg is
end package body;
