--#############################################################################
--#                                                                           #
--#   Copyright 2017-2023 Cryptographic Engineering Research Group (CERG)     #
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

-- =====================================================================
-- Copyright 2017-2023 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- Author: Farnoud Farahmand
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity trivium is
    generic(
        M_SIZE  : integer := 64
    );
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        done    : out std_logic;

        key     : in std_logic_vector(80-1 downto 0);
        iv      : in std_logic_vector(80-1 downto 0);
        key_iv_update  : in std_logic;
        init_done  : out std_logic;

        din        : in std_logic_vector(M_SIZE - 1 downto 0);
        din_valid  : in std_logic;
        din_ready  : out std_logic;

        dout       : out std_logic_vector(M_SIZE - 1 downto 0);
        dout_valid : out std_logic;
        dout_ready : in std_logic
    );

end trivium;

architecture behavioral of trivium is

    constant ONES : std_logic_vector(57 downto 0) := (others => '1');
    constant STATE_SIZE : integer := 288;

    type t_state is (S_RESET, S_INIT, S_ENC);
    signal state       : t_state;
    signal state_next  : t_state;
    signal count_r     : std_logic_vector(57 downto 0);
    signal count_next  : std_logic_vector(57 downto 0);

    signal s_in, state_init, s_out, SReg_in : std_logic_vector(STATE_SIZE-1 downto 0);
    signal t1_a, t1_b, t2_a, t2_b, t3_a, t3_b, z, z_bswap : std_logic_vector(M_SIZE-1 downto 0);

    signal rst_StateReg, en_StateReg, sel_init : std_logic;
    signal key_bswap, iv_bswap : std_logic_vector(80-1 downto 0);

begin

    --! DATAPATH --!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!
    Gen_bit_endian_swap_in: for i in 0 to 9 generate
        -- key_bswap (79 -i) <= key(i);
        -- iv_bswap (79 -i)  <= iv(i);
        -- key_bswap ((i*4) +3 downto i*4)  <= key(80 -(i*4)-1 downto 80 -(i*4)-4);
        -- iv_bswap ((i*4) +3 downto i*4)  <= iv(80 -(i*4)-1 downto 80 -(i*4)-4);
        gen_little_end: for j in 0 to 7 generate
            key_bswap ((i*8) +j)  <= key((i*8)+8-1 - j);
            iv_bswap ((i*8) +j)   <= iv((i*8)+8-1 - j);
        end generate;
        --key_bswap ((i*8) +7 downto i*8)  <= key(80 -(i*8)-1 downto 80 -(i*8)-8);
        --iv_bswap  ((i*8) +7 downto i*8)  <= iv (80 -(i*8)-1 downto 80 -(i*8)-8);
        --z_bswap  ((i*8) +7 downto i*8)  <= z (80 -(i*8)-1 downto 80 -(i*8)-8);
    end generate;

    Gen_bit_endian_swap_out: for i in 0 to (M_SIZE/8) -1 generate
        -- z_bswap(M_SIZE-1 -i) <= z(i);
        --z_bswap(i) <= z(i);
        z_bswap  ((i*8) +7 downto i*8)  <= z (M_SIZE -(i*8)-1 downto M_SIZE -(i*8)-8);
    end generate;

    state_init(92 downto 0)    <= "0000000000000" & key_bswap;
    state_init(176 downto 93)  <= "0000" & iv_bswap;
    state_init(287 downto 177) <= "111" & x"000000000000000000000000000";

    SReg_in <= state_init when sel_init = '1' else s_out;

    State_Reg: entity work.Register_s(behavioral)
                generic map(N => STATE_SIZE)
                port map(
                        d       => SReg_in,
                        enable  => en_StateReg,
                        reset   => '0',
                        clock   => clk,
                        q       => s_in
                );

    Gen_State: for i in 0 to M_SIZE-1 generate

        t1_a(i) <= s_in(65-i) xor s_in(92-i);
        t2_a(i) <= s_in(161-i) xor s_in(176-i);
        t3_a(i) <= s_in(242-i) xor s_in(287-i);

        z(i)    <= t1_a(i) xor t2_a(i) xor t3_a(i);

        t1_b(i) <= t1_a(i) xor (s_in(90-i) and s_in(91-i)) xor s_in(170-i);
        t2_b(i) <= t2_a(i) xor (s_in(174-i) and s_in(175-i)) xor s_in(263-i);
        t3_b(i) <= t3_a(i) xor (s_in(285-i) and s_in(286-i)) xor s_in(68-i);

        s_out(i)     <= t3_b(M_SIZE-1 -i);
        s_out(i+93)  <= t1_b(M_SIZE-1 -i);
        s_out(i+177) <= t2_b(M_SIZE-1 -i);

    end generate Gen_State;

    s_out(92 downto M_SIZE)      <= s_in(92-M_SIZE downto 0);
    s_out(176 downto 93+M_SIZE)  <= s_in(176-M_SIZE downto 93);
    s_out(287 downto 177+M_SIZE) <= s_in(287-M_SIZE downto 177);

    dout <= din xor z_bswap;


    --! CONTROLLER --!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!-

    p_fsm: process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                state       <= S_RESET;
            else
                state       <= state_next;
            end if;
            count_r     <= count_next;
        end if;
    end process;

    p_comb: process(state, key_iv_update, count_r, din_valid, dout_ready)
    begin
        --! Default values
        state_next    <= state;
        count_next    <= count_r;
        en_StateReg   <= '0';
        sel_init      <= '0';
        din_ready     <= '0';
        dout_valid    <= '0';
        done          <= '0';
        init_done     <= '0';

        case state is
            when S_RESET =>
                if (key_iv_update = '1') then
                    en_StateReg    <= '1';
                    sel_init       <= '1';
                    count_next	   <= (others => '0');
                    state_next     <= S_INIT;
                end if;

            when S_INIT =>
                if (count_r = ((288*4)/M_SIZE)) then
                    init_done      <= '1';
                    count_next	   <= (others => '0');
                    state_next     <= S_ENC;
                else
                    en_StateReg    <= '1';
                    count_next     <= count_r + 1;
                end if;

            when S_ENC =>
                if (count_r = ONES) then
                    done           <= '1';
                    state_next     <= S_RESET;
                elsif key_iv_update = '1' then
                    en_StateReg    <= '1';
                    sel_init       <= '1';
                    count_next	   <= (others => '0');
                    state_next     <= S_INIT;
                else
                    if (din_valid = '1') then
                        dout_valid <= '1';
                        if (dout_ready = '1') then
                            din_ready    <= '1';
                            en_StateReg  <= '1';
                            count_next   <= count_r + 1;
                        end if;
                    end if;
                end if;

        end case;
    end process;

end behavioral;
