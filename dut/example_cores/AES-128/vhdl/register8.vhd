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
-- Author: Shaunak

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

ENTITY reg IS 

PORT (   a     : IN  std_logic_vector(15 downto 0);
         clk   : IN  std_logic;
         reset : IN  std_logic;
         en    : IN  std_logic;                         -- enable '1', idle '0'
         b     : OUT std_logic_vector(15 downto 0));
END reg;

ARCHITECTURE behav OF reg IS

BEGIN

    PROCESS(a,en,clk,reset)
    BEGIN
        IF reset='1' THEN
            b <= (others => '0');

        ELSIF clk'EVENT AND clk = '1' THEN
            if en='1' then
                b <= a;
            end if;
        END IF;

    END PROCESS;

END behav;
