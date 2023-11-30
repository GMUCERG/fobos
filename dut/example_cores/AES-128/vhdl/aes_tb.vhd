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
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:53:57 03/29/2018
-- Design Name:   
-- Module Name:   /nhome/aabdulga/axi_aes/aes_tb.vhd
-- Project Name:  axi_aes
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: aes_non_pipe
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY aes_tb IS
END aes_tb;
 
ARCHITECTURE behavior OF aes_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT aes_non_pipe
    PORT(
         clock : IN  std_logic;
         start : IN  std_logic;
         data_in : IN  std_logic_vector(0 to 127);
         key_in : IN  std_logic_vector(0 to 127);
         data_out : OUT  std_logic_vector(0 to 127);
         done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal start : std_logic := '0';
   signal data_in : std_logic_vector(0 to 127) := (others => '0');
   signal key_in : std_logic_vector(0 to 127) := (others => '0');

 	--Outputs
   signal data_out : std_logic_vector(0 to 127);
   signal done : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: aes_non_pipe PORT MAP (
          clock => clock,
          start => start,
          data_in => data_in,
          key_in => key_in,
          data_out => data_out,
          done => done
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		start <= '1';

      wait for clock_period*10;
		
      -- insert stimulus here 
		data_in <= x"0123456789abcdef0123456789abcdef";
		key_in <=  x"00112233445566778899aabbccddeeff";
		wait for clock_period;
		start <= '0';
      wait;
   end process;

END;
