--#############################################################################
--#                                                                           #
--#   Copyright 2013-2023 Cryptographic Engineering Research Group (CERG)     #
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
-- Author: Shaunak Shah

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.STD_LOGIC_arith.all;

entity registern is		 
	 generic (N : integer := 128);
	 port(
		 clock : in STD_LOGIC;
		 la : in STD_LOGIC;
		 data_in : in STD_LOGIC_VECTOR(0 to N-1);
		 q : out STD_LOGIC_VECTOR(0 to N-1)
	     );	

end registern;

architecture registern_arch of registern is	
	--
begin
	process(clock)
	begin
	--	q <= (others => '0')  ;
		if (clock'event and clock = '1') then
			if la = '1' then
				q <= data_in ;
			end if;
		end if;
	end process;
end registern_arch;
