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

entity half_duplex_int_tb is
	--  Port ( );
end half_duplex_int_tb;

architecture Behav of half_duplex_int_tb is
	constant clk_period                                                     : time      := 10 ns;
	---CTRL
	signal clk                                                              : STD_LOGIC;
	signal rst                                                              : STD_LOGIC; --also resets the dut
	signal tx_data                                                          : STD_LOGIC_VECTOR(31 downto 0);
	signal tx_valid                                                         : STD_LOGIC;
	signal tx_ready                                                         : STD_LOGIC;
	signal rx_data                                                          : STD_LOGIC_VECTOR(31 downto 0);
	signal rx_valid                                                         : STD_LOGIC;
	signal rx_ready                                                         : STD_LOGIC;
	signal rx_last                                                          : std_logic;
	signal din                                                              : STD_LOGIC_VECTOR(3 downto 0);
	signal di_valid                                                         : STD_LOGIC;
	signal di_ready                                                         : STD_LOGIC;
	signal dout                                                             : STD_LOGIC_VECTOR(3 downto 0);
	signal do_valid                                                         : STD_LOGIC;
	signal do_ready                                                         : STD_LOGIC;
	signal dut_rst                                                          : std_logic;
	signal start                                                            : std_logic;
	signal status                                                           : std_logic_vector(7 downto 0);
	signal snd_start                                                        : std_logic; --tell other that sending data to dut started.
	signal op_done                                                          : std_logic; --tell others that operation (i.e. encryption) is done.
	signal dut_working                                                      : std_logic;
	signal started                                                          : std_logic;
	signal expected_out_len                                                 : std_logic_vector(31 downto 0);
	signal legacy_interface                                                 : std_logic;
	------FIFO
	signal fifo_dout_valid, fifo_dout_ready, fifo_din_valid, fifo_din_ready : std_logic;
	signal fifo_din, fifo_dout                                              : std_logic_vector(31 downto 0);
	---
	signal enable_fifo_out                                                  : std_logic := '0'; --to enable fifo_data_valid 
	---
	signal shared_handshake_out                                             : std_logic;
	signal shared_handshake_in                                              : std_logic;
	signal dbus                                                             : STD_LOGIC_VECTOR(3 downto 0);
	signal direction_out                                                    : std_logic;
begin
	dutcm : entity work.dutcomm_wrapper(behav)
		port map(
			clk                  => clk,
			rst                  => rst,
			tx_data              => tx_data,
			tx_valid             => tx_valid,
			tx_ready             => tx_ready,
			rx_data              => rx_data,
			rx_valid             => rx_valid,
			rx_last              => rx_last,
			rx_ready             => rx_ready,
			din                  => din,
			di_valid             => di_valid,
			di_ready             => di_ready,
			dout                 => dout,
			do_valid             => do_valid,
			do_ready             => do_ready,
			dut_rst              => dut_rst,
			start                => start,
			status               => status,
			snd_start            => snd_start,
			op_done              => op_done,
			dut_working          => dut_working,
			started              => started,
			expected_out_len     => expected_out_len,
			legacy_interface     => legacy_interface,
			---
			shared_handshake_out => shared_handshake_out,
			shared_handshake_in  => shared_handshake_in,
			dbus                 => dbus,
			direction_out        => direction_out
		);

	dut_4bit_interface : entity work.half_duplex_dut(behav)
		generic map(
			W  => 128,
			SW => 128
		)
		port map(
			clk                  => clk,
			rst                  => rst,
			--External bus--half duplex interface 
			shared_handshake_out => shared_handshake_in,
			shared_handshake_in  => shared_handshake_out,
			dbus                 => dbus,
			direction_in         => direction_out
		);

	dut_8bit_interface : entity work.FOBOS_DUT(structural)
		generic map(
			W  => 128,
			SW => 128
		)
		port map(
			clk      => clk,
			rst      => rst,
			di_valid => di_valid,
			do_ready => do_ready,
			di_ready => di_ready,
			do_valid => do_valid,
			din      => din,
			dout     => dout
		);

	data_fifo : entity work.fwft_fifo(structure)
		generic map(
			G_W => 32
		)
		port map(
			clk        => clk,
			rst        => rst,
			din        => fifo_din,
			din_valid  => fifo_din_valid,
			din_ready  => fifo_din_ready,
			dout       => fifo_dout,
			dout_valid => fifo_dout_valid,
			dout_ready => fifo_dout_ready
		);
	-------
	tx_valid        <= fifo_dout_valid;
	tx_data         <= fifo_dout;
	fifo_dout_ready <= tx_ready;
	rx_ready        <= '1';
	--------------------------------------------------------------------
	clock_process : process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process;
	------------------------------------------------------------------- 
	stim : process
	begin
		rst              <= '1';
		enable_fifo_out  <= '0';
		legacy_interface <= '0';
		wait for 2 * clk_period;
		rst              <= '0';
		fifo_din_valid   <= '0';
		----
		expected_out_len <= x"00000004"; --4words --16 bytes

		---Fill fifo
		wait for 4 * clk_period;
		fifo_din       <= x"00c00010";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"e2c62052";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"78f788dc";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"74693892";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"6f315df5";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"00c10010";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"01234567";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"89abcdef";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"00112233";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"44556677";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"00810010";
		fifo_din_valid <= '1';
		wait for clk_period;
		fifo_din       <= x"00800001";
		fifo_din_valid <= '1';
		wait for clk_period;
		--    fifo_din <= x"00800001";
		--    fifo_din_valid <= '1';
		--    wait for clk_period;
		fifo_din_valid <= '0';
		---end fill fifo

		wait for 4 * clk_period;
		---start sending data
		enable_fifo_out <= '1';
		wait;

	end process;

end Behav;
