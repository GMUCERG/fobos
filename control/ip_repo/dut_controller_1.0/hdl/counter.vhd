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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter is
	generic(
		N : integer := 32
	);
	port(
		clk         : in  std_logic;
		reset       : in  std_logic;
		enable      : in  std_logic;
		counter_out : out std_logic_vector(N - 1 downto 0)
	);
end counter;

architecture Behavioral of counter is

	signal temp : std_logic_vector(N - 1 downto 0);

begin
	counting : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				temp <= (others => '0');
			else
				if (enable = '1') then
					temp <= unsigned(temp) + 1;
				end if;
			end if;
		end if;
	end process;
	counter_out <= temp;

end Behavioral;
