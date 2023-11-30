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

ENTITY timeout_mod_tb IS
END timeout_mod_tb;

ARCHITECTURE behavior OF timeout_mod_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	component timeout_mod
		Port(clk       : in  STD_LOGIC;
		     rst       : in  STD_LOGIC;
		     snd_start : in  STD_LOGIC;
		     op_done   : in  std_logic;
		     ack       : in  std_logic; --ack from pc that it knows timeout happend
		     timeout   : in  STD_LOGIC_VECTOR(31 downto 0);
		     status    : out STD_LOGIC_VECTOR(7 downto 0));
	end component;

	--Inputs
	signal clk       : std_logic                     := '0';
	signal rst       : std_logic                     := '0';
	signal snd_start : std_logic                     := '0';
	signal op_done   : std_logic                     := '0';
	signal ack       : std_logic                     := '0';
	signal timeout   : std_logic_vector(31 downto 0) := (others => '0');

	--Outputs
	signal status       : std_logic_vector(7 downto 0);
	-- Clock period definitions
	constant clk_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : timeout_mod
		PORT MAP(
			clk       => clk,
			rst       => rst,
			snd_start => snd_start,
			op_done   => op_done,
			ack       => ack,
			timeout   => timeout,
			status    => status
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
		rst       <= '1';
		wait for 100 ns;
		rst       <= '0';
		ack       <= '0';
		op_done   <= '0';
		snd_start <= '0';
		wait for clk_period * 10;
		-- insert stimulus here 
		timeout   <= x"00000004";
		wait for 10 * clk_period;
		snd_start <= '1';
		wait for clk_period;
		snd_start <= '0';
		wait for clk_period * 15;
		----------------------------------
		ack       <= '1';
		wait for clk_period;
		ack       <= '0';
		--------no timeout
		wait for 5 * clk_period;
		snd_start <= '1';
		wait for clk_period;
		snd_start <= '0';
		wait for clk_period;
		op_done   <= '1';
		wait;
	end process;

END;
