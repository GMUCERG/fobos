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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
entity dummy is
	Generic(
		N        : integer := 32;
		NUMWORDS : integer := 4
	);
	Port(clk       : in  STD_LOGIC;
	     rst       : in  STD_LOGIC;
	     pdi_data  : in  STD_LOGIC_VECTOR(N - 1 downto 0);
	     pdi_valid : in  STD_LOGIC;
	     pdi_ready : out STD_LOGIC;
	     sdi_data  : in  STD_LOGIC_VECTOR(N - 1 downto 0);
	     sdi_valid : in  STD_LOGIC;
	     sdi_ready : out STD_LOGIC;
	     do_data   : out STD_LOGIC_VECTOR(N - 1 downto 0);
	     do_valid  : out STD_LOGIC;
	     do_ready  : in  STD_LOGIC
	    );
end dummy;

architecture behav of dummy is
	type state is (IDLE, RUN);
	signal current_state             : state;
	signal next_state                : state;
	signal cnt_clr, cnt_en, cnt_done : std_logic;
	signal cnt, next_cnt             : std_logic_vector(15 downto 0);

begin

	ctrl : process(clk)
	begin
		IF (rising_edge(clk)) THEN
			if (rst = '1') then
				current_state <= IDLE;
			else
				current_state <= next_state;
			END if;

		END IF;

	end process;

	comb : process(current_state, pdi_valid, sdi_valid, do_ready, cnt_done)
	begin
		-- defaults
		pdi_ready <= '0';
		sdi_ready <= '0';
		do_valid  <= '0';
		cnt_clr   <= '0';
		cnt_en    <= '0';

		case current_state is
			when IDLE =>
				cnt_clr <= '1';
				if pdi_valid = '1' and sdi_valid = '1' and do_ready = '1' then
					next_state <= RUN;
				else
					next_state <= IDLE;
				end if;

			when RUN =>
				if cnt_done = '1' then
					next_state <= IDLE;
				else
					if pdi_valid = '1' and sdi_valid = '1' and do_ready = '1' then
						pdi_ready <= '1';
						sdi_ready <= '1';
						do_valid  <= '1';
						cnt_en    <= '1';
					end if;
					next_state <= RUN;
				end if;

			when others =>
				next_state <= IDLE;

		end case;

	END process;
	do_data <= pdi_data xor sdi_data;
	-- do_data <= pdi_data;

	count : process(clk)
	begin
		if (rising_edge(clk)) then
			cnt <= next_cnt;
		end if;
	end process;
	next_cnt <= (others => '0') when cnt_clr = '1'
	            else cnt + 1 when cnt_en = '1'
	            else cnt;

	cnt_done <= '1' when (cnt = NUMWORDS) else '0';

end behav;

