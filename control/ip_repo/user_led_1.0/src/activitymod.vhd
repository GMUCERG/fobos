--#############################################################################
--#                                                                           #
--#   Copyright 2023 Cryptographic Engineering Research Group (CERG)          #
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
-- Author: Jens-Peter Kaps
-- 
-- Create Date: 06/02/2023 06:53:46 PM
-- Design Name: 
-- Module Name: activitymod - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity activity_mod is
    Port ( clk     :  in STD_LOGIC;
           rst     :  in STD_LOGIC;
           trigger :  in STD_LOGIC;
           led     : out STD_LOGIC);
end activity_mod;

architecture Behavioral of activity_mod is

type state is (IDLE, LEDOFF, LEDON);
signal current_state, next_state : state;
signal count     : unsigned(23 downto 0);
signal en_count  : std_logic;
--signal clr_count : std_logic;
signal period    : std_logic;

begin

    counter : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                count <= (others => '0');
            else
                if en_count = '1' then
                    count <= count +1;
                end if;
            end if;
        end if;
    end process;
    
    state_reg : process(clk)
	begin
		if (rising_edge(clk)) then
			if rst = '1' then
				current_state <= IDLE;
			else
				current_state <= next_state;
			end if;
		end if;
	end process;
	
	state_logic : process(current_state, trigger, period)
	begin
	
	   case current_state is
	       when IDLE =>
	           if trigger = '1' then 
	               next_state <= LEDON;
	           else
	               next_state <= IDLE;
	           end if;
	       when LEDON =>
	           if period = '1' then 
	               next_state <= LEDOFF;
	           else 
	               next_state <= LEDON;
	           end if;
	       when LEDOFF =>
	           if period = '1' then
	               next_state <= IDLE;
	           else
	               next_state <= LEDOFF;
	           end if;
	   end case;
    end process;
    
    -- Output logic
    led <= '1' when current_state = LEDON else '0';
    en_count <= '1' when current_state = LEDON OR current_state = LEDOFF else '0';
    
    period <= '1' when count = x"FFFFFF" else '0';


end Behavioral;
