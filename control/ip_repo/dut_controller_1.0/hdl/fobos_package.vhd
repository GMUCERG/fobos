--#############################################################################
--#                                                                           #
--#   Copyright 2019-2023 Cryptographic Engineering Research Group (CERG)     #
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
----------------------------------------------------------------------------------
-- Company: Cryptographic Engineering Research Group (CERG)
-- ECE Department, George Mason University
--     Fairfax, VA, U.S.A.
--     URL: http://cryptography.gmu.edu
-- Author: Abubakr Abdulgadir

library ieee;
use ieee.std_logic_1164.all;

package fobos_package is

	------------------------------------------------------------------------
	-- Trigger Modes
	------------------------------------------------------------------------
	constant TRG_NORM     : std_logic_vector(7 downto 0) := x"00"; --Normal trigger. 
	                                                               --Trigger wait and length apply
	constant TRG_FULL     : std_logic_vector(7 downto 0) := x"01"; --Follows dut_working signal
	--From di_ready=0 until do_valid=1
	constant TRG_NORM_CLK : std_logic_vector(7 downto 0) := x"02"; --Same as TRG_NORM but anded with clk
	constant TRG_FULL_CLK : std_logic_vector(7 downto 0) := x"03"; --Same as TRG_FULL but anded with clk

end fobos_package;
