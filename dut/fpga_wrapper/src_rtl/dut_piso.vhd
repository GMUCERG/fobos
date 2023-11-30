--#############################################################################
--#                                                                           #
--#   Copyright 2022-2023 Cryptographic Engineering Research Group (CERG)     #
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
--File  : sipo.vhd
--Author: Abubakr Abdulgadir
--Date  : 2/6/2022

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;  
use ieee.numeric_std.all;

entity dut_piso is

generic(       
    WI : natural := 16;  -- input size in bits
    WO : natural := 4    -- output size in bits --Warning max ratio of WO/WI must be less than 2048        
);
port(
    clk      : in  std_logic;
    rst      : in  std_logic;
    di_valid : in  std_logic;
    di_ready : out std_logic;
    din	     : in  std_logic_vector(WI-1 downto 0);
    do_valid : out std_logic;
    do_ready : in  std_logic;
    dout     : out std_logic_vector(WO-1 downto 0)
);
end dut_piso;

architecture behav of dut_piso is

signal cnt, nx_cnt : unsigned(12-1 downto 0);
type state_type is (S_WAIT, S_VALID);
signal state, nx_state : state_type;
type data_array is array (WI/WO-1 downto 0) of std_logic_vector(WO-1 downto 0);
signal mux_ar : data_array;

begin

    -- mux
    mux : for i in 0 to WI/WO-1 generate
        mux_ar(WI/WO-1-i) <= din((i+1)*WO-1 downto i*WO); --output in big endian
    end generate;

    dout <= mux_ar(to_integer(cnt));

    -- ctrl ===================================================
    state_reg: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= S_WAIT;
                cnt <= (others=>'0');
            else
                state <= nx_state;
                cnt <= nx_cnt;
            end if;
        end if;
    end process;

    do_valid <= di_valid;

    comb : process(all)
    begin
        -- default values
        nx_state <= state;
        nx_cnt <= cnt;

        di_ready <= '0';
        
        case state is
            when S_WAIT => 
                nx_cnt <= (others=>'0');
                if di_valid = '1' then
                    if do_ready = '1' then
                        nx_cnt <= cnt + 1;
                    end if;
                    nx_state <= S_VALID;
                end if;

            when S_VALID =>
                if do_ready = '1' then
                    if cnt = WI/WO-1 then
                        di_ready <= '1';
                        nx_cnt <= (others=>'0');
                        nx_state <= S_WAIT;
                    else
                        nx_cnt <= cnt + 1;
                    end if;
                end if;

            when others =>
                nx_state <= S_WAIT;
        end case;

    end process;

end behav;
