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
use ieee.numeric_std.all;

entity power_glitcher is
    port ( clk : in std_logic;
           rst : in std_logic;
           config_done : in std_logic;
           dut_working : in std_logic;
           glitch_pattern : in std_logic_vector(63 downto 0);
           glitch_wait : in std_logic_vector(31 downto 0); --wait befor sending glitch by this num of cycles
           glitch_out : out std_logic);
end power_glitcher;

architecture behav of power_glitcher is

type state is (S_WAIT_PATTERN, S_WAIT_DUT, S_COUNT, S_SHIFT);
signal current_state, next_state : state;
signal pattern_reg, pattern_reg_next : std_logic_vector(63 downto 0);
signal load_pattern, shift_pattern : std_logic;
signal cnt_reg, cnt_reg_next : unsigned(31 downto 0);
signal en_cnt, clr_cnt, cnt_done : std_logic;
signal glitch_gate : std_logic; 

begin

--------------------------------------------------------------------------------------
    cnt_reg1: process(clk)
    begin
        if rising_edge(clk) then
            cnt_reg <= cnt_reg_next;
        end if;
    end process;
    
    cnt_reg_next <= (others=>'0') when clr_cnt = '1' else
                    cnt_reg + 1   when en_cnt  = '1' else
                    cnt_reg;

    cnt_done <= '1' when std_logic_vector(cnt_reg) = glitch_wait else '0';
--------------------------------------------------------------------------------------
    patter_shift_reg1: process(clk)
    begin
        if rising_edge(clk) then
            pattern_reg <= pattern_reg_next;
        end if;
    end process;
    
    pattern_reg_next <= (others=>'0')                  when rst           = '1' else
                        '0' & pattern_reg(63 downto 1) when shift_pattern = '1' else
                        glitch_pattern                 when load_pattern  = '1' else   
                        pattern_reg;
    --do not allow glitch signal utill correct states
    glitch_out <= pattern_reg(0) when glitch_gate = '1' else '0';
--------------------------------------------------------------------------------------

    state_reg: process(clk)
    begin
       if rising_edge(clk) then
            if rst = '1' then
                current_state <= S_WAIT_PATTERN;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;
    
    --next state and output logic
    comb: process(current_state, config_done, dut_working, cnt_done)
    begin
        --default values
        shift_pattern <= '0';
        load_pattern  <= '0';
        clr_cnt <= '0';
        en_cnt <= '0';
        glitch_gate <= '0';
        
        case current_state is
            when S_WAIT_PATTERN =>
                clr_cnt <= '1'; 
                if config_done = '1' then
                    load_pattern <= '1';
                    next_state <= S_WAIT_DUT;
                else
                    next_state <= S_WAIT_PATTERN;
                end if;
            
            when S_WAIT_DUT => --wait for dut to start crypto
                if dut_working = '1' then
                    next_state <= S_COUNT;
                    clr_cnt <= '1';
                else
                    next_state <= S_WAIT_DUT;    
                end if;
                
            when S_COUNT =>
                if cnt_done = '1' then
                    next_state <= S_SHIFT;
                    shift_pattern <= '1';
                    glitch_gate <= '1';
                else
                    en_cnt <= '1';
                    next_state <= S_COUNT;
                end if;
                
            when S_SHIFT =>
                if dut_working = '1' then
                    shift_pattern <= '1';
                    glitch_gate <= '1';
                    next_state <= S_SHIFT;
                else
                    load_pattern <= '1'; --reload pattern
                    next_state <= S_WAIT_DUT;
                end if;
                        
        end case;
         
    end process;
    
end behav;
