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
--
-- Description:
---DUT timeout and reset module
---sends reset signal to dut if 'time_to_rst' clocks has passed since dutworking is raised.
---sets status to 'TIMEOUT' if 'timeout clock cycles has elapsed sice snd_start is triggered

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity timeout_mod is
	Port(clk           : in  STD_LOGIC;
	     rst           : in  STD_LOGIC;
	     snd_start     : in  STD_LOGIC;
	     op_done       : in  std_logic;
	     ack           : in  std_logic; --ack from pc that it knows timeout happend
	     timeout       : in  STD_LOGIC_VECTOR(31 downto 0);
	     status        : out STD_LOGIC_VECTOR(7 downto 0);
	     d_en_module   : out std_logic;
	     d_timeout_cnt : out std_logic_vector(31 downto 0)
	    );
end timeout_mod;

architecture behav of timeout_mod is
	----timeout 
	type state is (S_IDLE, S_STARTED, S_TIMEDOUT);
	constant C_IDLE     : std_logic_vector(7 downto 0) := x"01";
	constant C_STARTED  : std_logic_vector(7 downto 0) := x"02";
	constant C_TIMEDOUT : std_logic_vector(7 downto 0) := x"04";
	constant C_ACK_SEEN : std_logic_vector(7 downto 0) := x"08";

	signal current_state, next_state : state;
	signal timeout_cnt, rst_cnt      : unsigned(31 downto 0);
	signal clr_timeout_cnt           : std_logic;
	signal en_timeout_cnt            : std_logic;
	signal timedout                  : std_logic;
	signal en_module                 : std_logic; --enables the state machine

begin

	p_timeout_cnt : process(clk)
	begin
		if rising_edge(clk) then
			if clr_timeout_cnt = '1' then
				timeout_cnt <= (others => '0');
			else
				if en_timeout_cnt = '1' then
					timeout_cnt <= timeout_cnt + 1;
				end if;
			end if;
		end if;
	end process;

	state_reg : process(clk)
	begin
		if (rising_edge(clk)) then
			if rst = '1' then
				current_state <= S_IDLE;
			else
				current_state <= next_state;
			end if;
		end if;
	end process;

	p_comb : process(current_state, snd_start, op_done, timedout, ack, en_module)
	begin
		--default outputs
		status          <= (others => '0');
		clr_timeout_cnt <= '0';
		en_timeout_cnt  <= '0';

		case current_state is
			when S_IDLE =>
				status <= C_IDLE;
				if snd_start = '1' and en_module = '1' then
					en_timeout_cnt <= '1';
					next_state     <= S_STARTED;
				else
					clr_timeout_cnt <= '1';
					next_state      <= S_IDLE;
				end if;

			when S_STARTED =>
				status         <= C_STARTED;
				en_timeout_cnt <= '1';
				if op_done = '1' then
					next_state <= S_IDLE;
				else
					if timedout = '1' then
						next_state <= S_TIMEDOUT;
					else
						next_state <= S_STARTED;
					end if;
				end if;

			when S_TIMEDOUT =>
				status <= C_TIMEDOUT;
				if ack = '1' then
					--next_state <= S_ACK_SEEN;
					next_state <= S_IDLE;
				else
					next_state <= S_TIMEDOUT;
				end if;

				--    when S_ACK_SEEN =>
				--        status <= C_ACK_SEEN;
				--        if ack = '1' then
				--            next_state <= S_ACK_SEEN;
				--        else
				--            next_state <= S_IDLE;
				--        end if;
		end case;

	end process;
	----
	timedout  <= '1' when unsigned(timeout_cnt) >= unsigned(timeout) else '0';
	en_module <= '1' when timeout /= x"00000000" else '0'; --if timeout not set then nothing to do

	--debug
	d_en_module   <= en_module;
	d_timeout_cnt <= std_logic_vector(timeout_cnt);

end behav;
