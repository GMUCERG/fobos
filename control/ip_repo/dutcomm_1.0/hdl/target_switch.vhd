--#############################################################################
--#                                                                           #
--#   Copyright 2021-2023 Cryptographic Engineering Research Group (CERG)     #
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
------------------------------------------------------------------------------------
-- Company: Cryptographic Engineering Research Group (CERG)
-- ECE Department, George Mason University
--     Fairfax, VA, U.S.A.
--     URL: http://cryptography.gmu.edu
-- Author: Jens-Peter Kaps
--
-- Description:
-- DUT select module
-- modifies signal assigment on target connector based on dut
-- this is unfortunately necessary as we want to maintain compatibility with the
-- chip whisperer target connector and add functionality

library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 

entity target_switch is
    port (
        serial_en       : in  std_logic;
        serial_tx       : in  std_logic;
        serial_rx       : out std_logic;
        dio_I           : in  std_logic_vector(3 downto 0);
	    dio_O           : out std_logic_vector(3 downto 0);
	    dio_T           : out std_logic_vector(3 downto 0);
	    dio_out         : in  std_logic_vector(3 downto 0);
	    dio_dir         : in  std_logic_vector(3 downto 0);
        dut_working     : out std_logic;
        dut_busy        : in  std_logic
    );
end target_switch;

architecture behav of target_switch is

begin

    serial_rx <= dio_I(0);  -- RX is TX from DUT 

    dio_O(0) <= dio_out(0);
    dio_O(1) <= serial_tx when serial_en = '1' else dio_out(1);  -- TX is RX from DUT
    dio_O(2) <= dio_out(2);
    dio_O(3) <= dio_out(3);
    
    dio_T(0) <= '0' when serial_en = '1' else dio_dir(0); -- RX is input
    dio_T(1) <= '1' when serial_en = '1' else dio_dir(1); -- TX is output
    dio_T(2) <= dio_dir(2);
    dio_T(3) <= '0' when serial_en = '1' else dio_dir(3); -- Trigger is input
    
    dut_working <= dio_I(3) when serial_en = '1' else dut_busy; -- Trigger is high during operation
    

end behav;
