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
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY rst_mod_tb IS
END rst_mod_tb;

ARCHITECTURE behavior OF rst_mod_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	component rst_mod
		port(
			clk          : in  STD_LOGIC;
			rst          : in  STD_LOGIC;
			dut_working  : in  STD_LOGIC;
			time_to_rst  : in  std_logic_vector(31 downto 0);
			dut_rst_cmd  : out STD_LOGIC;
			wait_for_rst : out std_logic
		);
	end component rst_mod;

	--Inputs
	signal clk         : std_logic                     := '0';
	signal rst         : std_logic                     := '0';
	signal dut_working : std_logic                     := '0';
	signal time_to_rst : std_logic_vector(31 downto 0) := (others => '0');

	--Outputs
	signal dut_rst_cmd  : std_logic := '0';
	-- Clock period definitions
	constant clk_period : time      := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : rst_mod
		PORT MAP(
			clk         => clk,
			rst         => rst,
			dut_working => dut_working,
			time_to_rst => time_to_rst,
			dut_rst_cmd => dut_rst_cmd
		);

	-- Clock process definitions
	clk_process : process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		rst         <= '1';
		wait for 100 ns;
		rst         <= '0';
		wait for clk_period * 10;
		-- insert stimulus here 
		time_to_rst <= x"00000004";
		wait for 10 * clk_period;
		dut_working <= '1';
		wait for clk_period * 15;
		dut_working <= '0';
		wait;
	end process;

END;
