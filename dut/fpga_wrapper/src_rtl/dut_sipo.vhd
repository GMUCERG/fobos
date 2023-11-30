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

entity dut_sipo is

generic(       
    WI : natural:=4;  --input size in bits
    WO : natural:=16  --output size in bits --Warning max ratio of WO/WI must be less than 2048        
);
port(
    clk      : in std_logic;
    rst      : in std_logic;
    di_valid : in std_logic;
    di_ready : out std_logic;
    din	     : in std_logic_vector(WI-1 downto 0);
    do_valid : out std_logic;
    do_ready : in std_logic;
    dout     : out std_logic_vector(WO-1 downto 0)
);

end dut_sipo;

architecture behav of dut_sipo is

signal sipo : std_logic_vector(WO-WI-1 downto 0);
signal cnt, nx_cnt : unsigned(12-1 downto 0);
signal full : std_logic;
signal en_sipo : std_logic;

begin


    --ctrl===============================================================================
    state_reg: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cnt <= (others=>'0');
            else
                cnt <= nx_cnt;
                if en_sipo = '1' then
                    sipo <= sipo(WO-WI-WI-1 downto 0) & din;
                end if;
            end if;
        end if;
    end process;

    
    full <= '1' when cnt = (WO/WI-1) else '0';

    witre_proc: process(all)
    begin
        en_sipo <= '0';
        di_ready <= '0';
        
        if full = '0' or do_ready = '1' then
            di_ready <= '1';
        end if;
        
        if di_valid = '1' and full = '0' then
            en_sipo <= '1';
        end if;
        
    end process;

    read_proc: process(all)
    begin
        do_valid <= '0';
        
        if full = '1' and di_valid = '1' then
            do_valid <= '1';
        end if;
    end process;

    cnt_proc: process(all)
    begin
        
        nx_cnt <= cnt;

        if (do_valid = '1' and do_ready = '1') then  -- read
            nx_cnt <= to_unsigned(0, nx_cnt'length);
        elsif en_sipo = '1' then --wite
            nx_cnt <=  cnt + 1;
        end if;

    end process;

    dout <= sipo & din;

end behav;
