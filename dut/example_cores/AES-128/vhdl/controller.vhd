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

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.STD_LOGIC_arith.all;

entity controller is
	port (
			clock : in std_logic ;
			start : in std_logic ;
			loads : out std_logic ;
			loadk : out std_logic ;	
			li : out std_logic ;
			ei : out std_logic ;
			zi : in std_logic ;  
			lk : out std_logic ;
			ek : out std_logic ;
			--zk : in std_logic ;  
			r_key_sel : out std_logic ;
			load_data : out std_logic_vector (1 downto 0) ;	
			load_out : out std_logic ;
--			trigger : out std_logic	;
			done : out std_logic 
		 );
end controller;

architecture controller_arch of controller is

type state is (s0, s1, s2, s3, s4);
signal pr_state, nx_state: state;

begin
	-- section 1: fsm register
	--process (start,clock)
	process (clock) --make it synchronous
	begin
		
		if (clock'event and clock='1') then
		   if (start ='1') then
		       pr_state <= s0;
		   else
			    pr_state <= nx_state;
		   end if;
		end if;
	end process;

	-- section 2: next state function
	process (zi, pr_state)
	begin 
		case pr_state is 
			
			when s0 =>
				nx_state <= s1;
			
			when s1 =>
				nx_state <= s2;
							
			when s2 =>
				if (zi = '0') then
					 nx_state <= s2;
				else
					 nx_state <= s3;
				end if;
						
			--when s3 =>
				--if (zk = '0') then
					-- nx_state <= s1;
				--else
					-- nx_state <= s4;
				--end if;
						
			when s3 =>
			nx_state <= s4;	
			
			when s4 =>
				nx_state <= s4;
			
			when others =>
				nx_state <= s4;
					
		end case;
	end process;
			
	--section 3: output function
	process (zi, pr_state)
	begin
		loads <= '0'; loadk <= '0'; li <= '0'; ei <= '0'; load_data <= "00"; r_key_sel <= '0'; done <= '0';
		load_out <= '0'; lk <= '0'; ek <= '0'; 
		--trigger <= '0';
	
		case pr_state is
		
			when s0 =>
				lk <= '1';
				--loads <= '1'; loadk <= '1'; li <= '1';
				--load_out <= '1';
				
			when s1 =>
				loads <= '1'; loadk <= '1'; li <= '1'; 
--				load_out <= '1';		-- output register to be enabled only in the last round
				
			when s2 =>
				load_data <= "10"; r_key_sel <= '1'; loads<= '1'; loadk <= '1';
--				load_out <= '1'; 		-- output register to be enabled only in the last round
				ei <= '1';
--				if (zi = '0') then
--					ei <= '1'; -- Mealy type output after the IF statement
--				end if;
			
			when s3 =>
				ei <= '1';
				load_data <= "01"; r_key_sel <= '1'; loads <= '1'; loadk <= '1';
				load_out <= '1';
				--done <= '1';
				--if (zk = '0') then
					--ek <= '1'; -- Mealy type output after the IF statement 
--					trigger <= '1';   ------------- Trigger signal after each encryption
				--end if;

			
			when s4 =>
--				load_data <= "01"; r_key_sel <= '1'; loads <= '1'; loadk <= '1';
--				load_out <= '1';
				done <= '1';
			when others =>
				done <= '1';
				
		end case;
	end process;	
	
end controller_arch;
			

