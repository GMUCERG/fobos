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

----------------------------------------------------------------------------------
-- Company: Cryptographic Engineering Research Group (CERG)
-- ECE Department, George Mason University
--     Fairfax, VA, U.S.A.
--     URL: http://cryptography.gmu.edu
-- Author: Jens-Peter Kaps
--
-- Description:
-- DUT select module
-- modifies signal assigment on target connector based on dut
-- this is unfortunately necessary as we want to maintain compatibility with the
-- chip whisperer target connector and add functionality

library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 

entity dut_switch is 
    port (  fd2c_clk_O: out std_logic; -- output value
            fd2c_clk_I: in  std_logic; -- input clock
            fd2c_clk_D: out std_logic; -- direction '1' if output, '0' if input
            clk_out:    out std_logic; -- clock from DUT
            en_serial:  out std_logic; -- enable serial communication with DUT
            dut_rst:    in  std_logic;
            dut_select: in std_logic_vector(31 downto 0)
         );
end dut_switch;

architecture behav of dut_switch is

    signal dut        : std_logic_vector(3 downto 0);
    
begin

    dut <= dut_select(3 downto 0);
    
    SEL: process(dut, fd2c_clk_I, dut_rst)    
    begin
        case dut is 
        
        when "0001" =>   -- CW 308, reset not wired, we use fd2c_clk instead
            fd2c_clk_O <= dut_rst;
            fd2c_clk_D <= '1';
            clk_out    <= '0';
            en_serial  <= '0';
            
        when "0010" =>  -- CW 305, enable serial on DIO0 and DIO1
            fd2c_clk_O <= '0';
            fd2c_clk_D <= '0';
            clk_out    <= fd2c_clk_I;
            en_serial  <= '1';
            
        when others =>   -- FOBOS
            fd2c_clk_O <= '0';
            fd2c_clk_D <= '0';
            clk_out    <= fd2c_clk_I;
            en_serial  <= '0';
        
       end case;
    end process;
            
end behav;
