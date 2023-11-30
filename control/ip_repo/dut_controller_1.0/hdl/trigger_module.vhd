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
use work.fobos_package.all;

entity trigger_module is
	port(
		clk            : in  std_logic;
		rst            : in  std_logic;
		dut_working    : in  std_logic;
		trigger_length : in  std_logic_vector(31 downto 0);
		trigger_wait   : in  std_logic_vector(31 downto 0);
		trigger_mode   : in  std_logic_vector(7 downto 0);
		trigger_out    : out std_logic;    -- trigger signal never ANDed with clock
		trigger_osc    : out std_logic     -- trigger signal for oscilloscope
	);

end trigger_module;

architecture behav of trigger_module is

	component counter is
		generic(N : integer := 32);
		port(
			clk         : in  std_logic;
			reset       : in  std_logic;
			enable      : in  std_logic;
			counter_out : out std_logic_vector(N - 1 downto 0)
		);
	end component;

	type STATE is (S_RST, S_WAIT_START, S_DELAY, S_LENGTH, S_DONE);
	signal current_state, next_state : state;

	signal wait_cnt_rst, wait_cnt_en, wait_cnt_expired : std_logic;
	signal wait_cnt_out                                : std_logic_vector(31 downto 0);
	signal len_cnt_rst, len_cnt_en, len_cnt_expired    : std_logic;
	signal len_cnt_out                                 : std_logic_vector(31 downto 0);

	signal trigger_s : std_logic;

begin

	triggerWaitCounter : counter
		generic map(N => 32)
		port map(clk         => clk,
		         reset       => wait_cnt_rst,
		         enable      => wait_cnt_en,
		         counter_out => wait_cnt_out);

	triggerLenghtCounter : counter
		generic map(N => 32)
		port map(clk         => clk,
		         reset       => len_cnt_rst,
		         enable      => len_cnt_en,
		         counter_out => len_cnt_out);

	wait_cnt_expired <= '1' when wait_cnt_out >= trigger_wait else '0';
	len_cnt_expired  <= '1' when len_cnt_out >= trigger_length else '0';

	state_reg : process(clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				current_state <= S_RST;
			else
				current_state <= next_state;
			end if;
		end if;
	end process;

	process(current_state, dut_working, wait_cnt_expired, len_cnt_expired)
	begin
		--default values
		wait_cnt_rst <= '0';
		wait_cnt_en  <= '0';
		len_cnt_rst  <= '0';
		len_cnt_en   <= '0';
		trigger_s    <= '0';

		case current_state is
			when S_RST =>
				wait_cnt_rst <= '1';
				len_cnt_rst  <= '1';
				next_state   <= S_WAIT_START;

			when S_WAIT_START =>
				if (dut_working = '1') then
					if wait_cnt_expired = '1' then
						trigger_s <= '1';
					end if;
					wait_cnt_en <= '1';
					next_state  <= S_DELAY;
				else
					next_state <= S_WAIT_START;
				end if;

			when S_DELAY =>             --wait for "trigger_wait clock cycles"
				if (wait_cnt_expired = '1') then
					trigger_s  <= '1';
					len_cnt_en <= '1';
					next_state <= S_LENGTH; --change to lenght state
				else
					wait_cnt_en <= '1';
					next_state  <= S_DELAY;
				end if;

			when S_LENGTH =>
				if (len_cnt_expired = '1') then
					next_state <= S_DONE;
				else
					trigger_s  <= '1';
					len_cnt_en <= '1';
					next_state <= S_LENGTH;
				end if;

			when S_DONE =>
				if dut_working = '1' then
					next_state <= S_DONE;
				else
					next_state <= S_RST;
				end if;

		end case;

	end process;

    with trigger_mode select trigger_osc <=
        trigger_s when TRG_NORM,
        dut_working when TRG_FULL,
        trigger_s and clk when TRG_NORM_CLK,
        dut_working and clk when TRG_FULL_CLK,
        trigger_s when others;
        
    with trigger_mode select trigger_out <=
        trigger_s when TRG_NORM,
        dut_working when TRG_FULL,
        trigger_s when TRG_NORM_CLK,
        dut_working when TRG_FULL_CLK,
        trigger_s when others;

end behav;
