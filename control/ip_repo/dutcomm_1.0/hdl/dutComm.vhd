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
use ieee.std_logic_unsigned.all;

entity dutComm is
	port(
		clk              : in  STD_LOGIC;
		rst              : in  STD_LOGIC; --also resets the dut
		tx_data          : in  STD_LOGIC_VECTOR(31 downto 0);
		tx_valid         : in  STD_LOGIC;
		tx_ready         : out STD_LOGIC;
		rx_data          : out STD_LOGIC_VECTOR(31 downto 0);
		rx_valid         : out STD_LOGIC;
		rx_ready         : in  STD_LOGIC;
		rx_last          : out std_logic;
		din              : out STD_LOGIC_VECTOR(3 downto 0);
		di_valid         : out STD_LOGIC;
		di_ready         : in  STD_LOGIC;
		dout             : in  STD_LOGIC_VECTOR(3 downto 0);
		do_valid         : in  STD_LOGIC;
		do_ready         : out STD_LOGIC;
		direction        : out std_logic;
		dut_rst          : out std_logic;
		status           : out std_logic_vector(7 downto 0);
		snd_start        : out std_logic; --tell other that sending data to dut started.
		op_done          : out std_logic; --tell others that operation (i.e. encryption) is done.
		dut_working      : out std_logic;
		started          : out std_logic;
		expected_out_len : in  std_logic_vector(31 downto 0);
		wait_for_rst     : in  std_logic;
		rst_cmd          : in  std_logic
	);
end dutComm;

architecture Behav of dutComm is

	signal din_cnt, next_din_cnt     : std_logic_vector(2 downto 0); --select signal for din_mux
	signal din_cnt_clr, din_cnt_en   : std_logic;
	signal din_cnt_last              : std_logic;
	---dout logic signals
	signal dout_cnt, next_dout_cnt   : std_logic_vector(2 downto 0); --select signal for din_mux
	signal dout_cnt_clr, dout_cnt_en : std_logic;
	signal dout_cnt_last             : std_logic;
	signal sipo_reg                  : std_logic_vector(27 downto 0);
	signal sipo_en                   : std_logic;
	signal sel_rx_data               : std_logic_vector(2 downto 0);

begin
	---din_mux
	with din_cnt select din <=
		tx_data(31 downto 28) when "000",
		tx_data(27 downto 24) when "001",
    tx_data(23 downto 20) when "010",
    tx_data(19 downto 16) when "011",
    tx_data(15 downto 12) when "100",
    tx_data(11 downto 8) when "101",
    tx_data(7 downto 4) when "110",
    tx_data(3 downto 0) when "111",
    "0000"                when others;

	--din_cnt_reg-----------------------------------------------
	process(clk)
	begin
		if (rising_edge(clk)) then
			din_cnt <= next_din_cnt;
		end if;
	end process;
	next_din_cnt <= (others => '0') when din_cnt_clr = '1'
	                else din_cnt + 1 when din_cnt_en = '1'
	                else din_cnt;

	din_cnt_last <= '1' when din_cnt = "111" else '0';
	-------------------------------------------------------------

	--dout logic-------------------------------------------------
	sipo : process(clk)
	begin
		if rising_edge(clk) then
			if sipo_en = '1' then
				sipo_reg <= sipo_reg(23 downto 0) & dout;
			end if;
		end if;
	end process;
	--sipo cnt
	process(clk)
	begin
		if (rising_edge(clk)) then
			dout_cnt <= next_dout_cnt;
		end if;
	end process;
	next_dout_cnt <= (others => '0') when dout_cnt_clr = '1'
	                 else dout_cnt + 1 when dout_cnt_en = '1'
	                 else dout_cnt;

	dout_cnt_last <= '1' when dout_cnt = "111" else '0';

	--rx_data <= sipo_reg & dout;
	--need to shift data if not a complete 32-bit word

	sel_rx_data <= dout_cnt + 1;
	with sel_rx_data(2 downto 1) select rx_data <=
		sipo_reg & dout when "00",
		sipo_reg(19 downto 0) & dout & x"00" when "11",
    sipo_reg(11 downto 0) & dout & x"0000" when "10",
    sipo_reg(3 downto 0) & dout & x"000000" when "01",
    x"00000000" when others;

	-------------------------------------------------------------
	---controller

	ctrl : entity work.dutCommCtrl(behav)
		port map(
			clk              => clk,
			rst              => rst,
			tx_valid         => tx_valid,
			tx_ready         => tx_ready,
			rx_valid         => rx_valid,
			rx_ready         => rx_ready,
			rx_last          => rx_last,
			di_valid         => di_valid,
			di_ready         => di_ready,
			do_valid         => do_valid,
			do_ready         => do_ready,
			dut_rst          => dut_rst,
			direction        => direction,
			---Internal control/status
			din_cnt_clr      => din_cnt_clr,
			din_cnt_en       => din_cnt_en,
			din_cnt_last     => din_cnt_last,
			dout_cnt_clr     => dout_cnt_clr,
			dout_cnt_en      => dout_cnt_en,
			dout_cnt_last    => dout_cnt_last,
			sipo_en          => sipo_en,
			status           => status,
			op_done          => op_done,
			dut_working      => dut_working,
			started          => started,
			expected_out_len => expected_out_len,
			wait_for_rst     => wait_for_rst,
			rst_cmd          => rst_cmd
			---     
		);

end Behav;
