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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE ieee.std_logic_textio.all;


entity piso_tb is

end piso_tb;

architecture behav of piso_tb is

constant WI : natural := 16;
constant WO : natural := 4;

constant period : time:= 10 ns;

signal clk : std_logic := '0';
signal rst : std_logic;

signal di_valid, do_ready : std_logic := '0';
signal di_ready, do_valid : std_logic;

signal in_fifo_din	: std_logic_vector(WI-1 downto 0);
signal in_fifo_dout : std_logic_vector(WI-1 downto 0);
signal in_fifo_di_valid : std_logic := '0';
signal in_fifo_di_ready : std_logic;
signal in_fifo_do_valid : std_logic;
signal in_fifo_do_ready : std_logic;


signal piso_dout : std_logic_vector(WO-1 downto 0);
signal piso_do_valid : std_logic;
signal piso_do_ready : std_logic := '0';


begin

in_fifo: entity work.fwft_fifo(structure)
        generic map(
            G_W  => WI,
            G_LOG2DEPTH => 4
        )
        port map(
            clk => clk,
            rst => rst,

            -- Input Port
            din  => in_fifo_din,
            din_valid => in_fifo_di_valid,
            din_ready => in_fifo_di_ready,
    
            -- Output Port
            dout => in_fifo_dout,
            dout_valid => in_fifo_do_valid,
            dout_ready => in_fifo_do_ready

);

dut : entity work.piso(behav)
    generic map(
    WI => WI,
    WO => WO
    )
    port map(

        clk => clk,
        rst => rst,
        di_valid => in_fifo_do_valid,
        di_ready => in_fifo_do_ready,
        do_valid => piso_do_valid,
        do_ready => piso_do_ready,
        din => in_fifo_dout,
        dout => piso_dout
        
    );

clk <= not clk after period/2;

stimulus: process
begin

    rst <= '1';
    wait for period;
    rst <= '0';
    wait for period;

    in_fifo_din <= x"1234";
    in_fifo_di_valid <= '1';
    wait for period;

    in_fifo_din <= x"5678";
    in_fifo_di_valid <= '1';
    wait for period;

    in_fifo_di_valid <= '0';

    wait for 10*period;
    piso_do_ready <= '1';
    wait for 3*period;
    piso_do_ready <= '0';
    wait for 3*period;
    piso_do_ready <= '1';
    
   
    

    wait;

end process;
     
end behav;
