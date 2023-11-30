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

entity glitcher_tb is
end glitcher_tb;

architecture behav of glitcher_tb is

signal clk, rst : std_logic;
signal period : time := 10 ns;
signal config_done, dut_working, glitch_out : std_logic := '0';
signal glitch_wait : std_logic_vector(31 downto 0);
signal glitch_pattern : std_logic_vector(63 downto 0);

begin

    uut: entity work.power_glitcher(behav)
    port map ( 
        clk => clk,
        rst => rst,
        config_done => config_done,
        dut_working => dut_working,
        glitch_pattern => glitch_pattern,
        glitch_wait => glitch_wait,
        glitch_out => glitch_out
    );
    
    clk_proc: process
    begin
        clk <= '0';
        wait for period / 2;
        clk <= '1';
        wait for period / 2;
    end process;
    
    rst_proc: process
    begin
        rst <= '1';
        wait for 2 * period;
        rst <= '0';
        wait;
    end process;
    
    stimulus: process
    begin
        --pepare
        wait for 4 * period;
        glitch_pattern <= x"0000000000000005";
        glitch_wait <= x"00000004";
        config_done <= '1';
        wait for period;
        config_done <= '0';
        wait for 4 * period;
        --dut running now
        dut_working <= '1';
        wait for 10 * period;
        dut_working <= '0';
        
        ---agian
        
         --pepare
        wait for 4 * period;
        glitch_pattern <= x"0000000000000005";
        glitch_wait <= x"00000004";
        config_done <= '1';
        wait for period;
        config_done <= '0';
        wait for 4 * period;
        --dut running now
        dut_working <= '1';
        wait for 10 * period;
        dut_working <= '0';
        wait;
    
    end process;

end behav;
