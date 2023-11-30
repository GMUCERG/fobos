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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dutCommCtrl is
	port(
		clk              : in  STD_LOGIC;
		rst              : in  STD_LOGIC;
		tx_valid         : in  STD_LOGIC;
		tx_ready         : out STD_LOGIC;
		di_valid         : out STD_LOGIC;
		di_ready         : in  std_logic;
		rx_valid         : out STD_LOGIC;
		rx_ready         : in  STD_LOGIC;
		rx_last          : out std_logic;
		do_ready         : out STD_LOGIC;
		do_valid         : in  std_logic;
		dut_rst          : out std_logic;
		direction        : out std_logic; -- to control half duplex interface -- 0 means data is going from ctrl-> dut
		---Internal control/status
		din_cnt_clr      : out std_logic;
		din_cnt_en       : out std_logic;
		din_cnt_last     : in  std_logic;
		dout_cnt_clr     : out std_logic;
		dout_cnt_en      : out std_logic;
		dout_cnt_last    : in  std_logic;
		sipo_en          : out std_logic;
		status           : out std_logic_vector(7 downto 0);
		op_done          : out std_logic;
		dut_working      : out std_logic;
		started          : out std_logic;
		expected_out_len : in  std_logic_vector(31 downto 0);
		wait_for_rst     : in  std_logic;
		rst_cmd          : in  std_logic
		---     
	);
end dutCommCtrl;

architecture Behav of dutCommCtrl is

	type STATE is (S_IDLE, S_WAIT_TXVALID, S_WAIT_READY, S_SND, S_WAIT_RST, S_WAIT_VALID, S_RCV, S_DONE);
	signal current_state, next_state              : state;
	--status codes
	constant IDLE                                 : std_logic_vector(7 downto 0) := x"01";
	constant C_TX_VALID                           : std_logic_vector(7 downto 0) := x"02";
	constant WAIT_READY                           : std_logic_vector(7 downto 0) := x"05";
	constant SND                                  : std_logic_vector(7 downto 0) := x"0a";
	constant WAIT_RST                             : std_logic_vector(7 downto 0) := x"0c";
	constant WAIT_VALID                           : std_logic_vector(7 downto 0) := x"0f";
	constant RCV                                  : std_logic_vector(7 downto 0) := x"15";
	constant DONE                                 : std_logic_vector(7 downto 0) := x"1a";
	--------
	signal tlast_cnt                              : unsigned(31 downto 0);
	signal clr_tlast_cnt, en_tlast_cnt, last_word : std_logic;
	signal s_rx_valid                             : std_logic;
	signal s_do_ready                             : std_logic;

begin

	state_reg : process(clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				current_state <= S_IDLE;
			else
				current_state <= next_state;
			end if;
		end if;
	end process;

	process(current_state, tx_valid, di_ready, do_valid, din_cnt_last, rx_ready, dout_cnt_last, last_word, wait_for_rst, rst_cmd)
	begin
		--default outputs
		direction     <= '0';
		di_valid      <= '0';
		tx_ready      <= '0';
		s_do_ready    <= '0';
		s_rx_valid    <= '0';
		--rx_last         <= '0';
		op_done       <= '0';
		dut_working   <= '0';
		dut_rst       <= '0';
		---Internal ctrl
		din_cnt_clr   <= '0';
		din_cnt_en    <= '0';
		dout_cnt_clr  <= '0';
		dout_cnt_en   <= '0';
		sipo_en       <= '0';
		started       <= '0';
		clr_tlast_cnt <= '0';

		case current_state is
			when S_IDLE =>
				status        <= IDLE;
				din_cnt_clr   <= '1';
				dout_cnt_clr  <= '1';
				dut_rst       <= '1';
				clr_tlast_cnt <= '1';
				next_state    <= S_WAIT_TXVALID;

			when S_WAIT_TXVALID =>      --we do not want started to be issue when we reset this FSM
				status <= C_TX_VALID;
				if tx_valid = '1' then
					next_state <= S_WAIT_READY;
					started    <= '1';
				else
					next_state <= S_WAIT_TXVALID;
				end if;

			when S_WAIT_READY =>
				status <= WAIT_READY;
				if di_ready = '1' then
					next_state <= S_SND;
				else
					next_state <= S_WAIT_READY;
				end if;

			when S_SND =>
				status <= SND;
				if tx_valid = '1' then
					di_valid <= '1';
				end if;
				if di_ready = '1' then
					if tx_valid = '1' then
						din_cnt_en <= '1';
						--di_valid <= '1';
					end if;
					if din_cnt_last = '1' then
						tx_ready <= '1';
					end if;
					next_state <= S_SND;
				else
					dut_working <= '1';
					--due to inverted clock, last 4bit block sent is not counted. So it stays in the FIFO and software will hang
					--this is becaus di_ready is set to zero half-cycle early.
					--drain the fifo
					tx_ready    <= '1';
					next_state  <= S_WAIT_RST;
				end if;

			when S_WAIT_RST =>
				--no output will be returned in this case. we wait unitl dut_rst. this 
				--should not reset this ip or it will forget all settings
				status      <= WAIT_RST;
				dut_working <= '1';
				if wait_for_rst = '1' then
					if rst_cmd = '1' then
						next_state <= S_DONE;
					else
						next_state <= S_WAIT_RST;
					end if;
				else
					next_state <= S_WAIT_VALID;
				end if;

			when S_WAIT_VALID =>
				direction  <= '1';      --get data from dut
				status     <= WAIT_VALID;
				s_do_ready <= '1';
				if do_valid = '1' then
					next_state  <= S_RCV;
					dout_cnt_en <= '1';
					sipo_en     <= '1';
				else
					dut_working <= '1';
					next_state  <= S_WAIT_VALID;
				end if;

			when S_RCV =>
				direction <= '1';
				status    <= RCV;
				if rx_ready = '1' then
					s_do_ready <= '1';
				end if;
				if do_valid = '1' then
					if dout_cnt_last = '1' or last_word = '1' then
						s_rx_valid <= '1';
						if rx_ready = '1' then
							dout_cnt_clr <= '1';
							--do_ready <= '1';
						end if;
					else
						--do_ready <= '1';
						dout_cnt_en <= '1';
						sipo_en     <= '1';
					end if;
					next_state <= S_RCV;
				else
					next_state <= S_DONE; --when do_valid = 0 we are done
					--rx_last <= '1'; 
					-- rx_valid <= '1'; --needed for slave to accept tlast-- ivalid  data -- Chnged for DUT SOC
					op_done    <= '1';
				end if;

			when S_DONE =>
				status <= DONE;
				if tx_valid = '1' then  --wait unit upper level consumes the data
					next_state <= S_IDLE;
				else
					next_state <= S_DONE;
				end if;

		end case;

	end process;

	do_ready <= s_do_ready;
	rx_valid <= s_rx_valid;

	---tlast logic
	en_tlast_cnt <= '1' when s_do_ready = '1' and do_valid = '1' else '0';
	last_word    <= '1' when tlast_cnt >= unsigned(expected_out_len) - 1 else '0';
	rx_last      <= '1' when last_word = '1' and s_rx_valid = '1' else '0';

	tlast_cnt_poc : process(clk)
	begin
		if rising_edge(clk) then
			if clr_tlast_cnt = '1' then
				tlast_cnt <= (others => '0');
			else
				if en_tlast_cnt = '1' then
					tlast_cnt <= tlast_cnt + 1;
				end if;
			end if;
		end if;
	end process;

end Behav;

