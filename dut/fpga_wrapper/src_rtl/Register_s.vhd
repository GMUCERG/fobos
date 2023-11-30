--#############################################################################
--#                                                                           #
--#   Copyright 2017-2023 Cryptographic Engineering Research Group (CERG)     #
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

-- =====================================================================
-- Copyright 2017-2023 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- Author: Farnoud Farahmand
-- =====================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register_s is
          generic ( N : integer := 128 ) ;
          port   (
			         d                      : in  std_logic_vector(N-1 downto 0) ;
                  reset, clock, enable   : in  std_logic ;
                  q                      : OUT std_logic_vector(N-1 DOWNTO 0)
				 );

end Register_s;

architecture behavioral of Register_s is

begin

    process (clock)
      begin
		   if rising_edge(clock) then
            if reset = '1' then
               q <= (others => '0') ;
            elsif enable= '1' then
               q <= d ;
            end if ;
		   end if ;

     end process ;

end behavioral;
