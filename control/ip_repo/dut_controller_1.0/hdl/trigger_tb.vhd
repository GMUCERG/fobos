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
use work.fobos_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY trigger_tb IS
END trigger_tb;

ARCHITECTURE behavior OF trigger_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT trigger_module
		PORT(
			clk            : IN  std_logic;
			rst            : IN  std_logic;
			dut_working    : IN  std_logic;
			trigger_length : IN  std_logic_vector(31 downto 0);
			trigger_wait   : IN  std_logic_vector(31 downto 0);
			trigger_mode   : IN  std_logic_vector(7 downto 0);
			trigger_out    : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	signal clk            : std_logic                     := '0';
	signal rst            : std_logic                     := '0';
	signal dut_working    : std_logic                     := '0';
	signal trigger_length : std_logic_vector(31 downto 0) := (others => '0');
	signal trigger_wait   : std_logic_vector(31 downto 0) := (others => '0');
	signal trigger_mode   : std_logic_vector(7 downto 0);

	--Outputs
	signal trigger_out : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : trigger_module
		PORT MAP(
			clk            => clk,
			rst            => rst,
			dut_working    => dut_working,
			trigger_length => trigger_length,
			trigger_wait   => trigger_wait,
			trigger_mode   => trigger_mode,
			trigger_out    => trigger_out
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
		rst            <= '1';
		wait for 100 ns;
		rst            <= '0';
		wait for clk_period * 10;
		-- insert stimulus here 
		trigger_length <= x"00000001";
		trigger_wait   <= x"00000000";
		trigger_mode   <= TRG_NORM;
		---encryption 1
		wait for 5 * clk_period;
		dut_working    <= '1';
		wait for clk_period * 15;
		dut_working    <= '0';
		--ecryption 2
		wait for 5 * clk_period;
		dut_working    <= '1';
		wait for clk_period * 15;
		dut_working    <= '0';
		wait;

	end process;

END;
