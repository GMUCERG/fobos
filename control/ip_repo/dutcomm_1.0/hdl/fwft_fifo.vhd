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

entity fwft_fifo is
    generic (
        G_W             : integer := 64;    --! Width of I/O (bits)
        G_LOG2DEPTH     : integer := 9;     --! LOG(2) of depth
        G_ASYNC_RSTN    : boolean := False  --! Async reset active low
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        din             : in  std_logic_vector(G_W              -1 downto 0);
        din_valid       : in  std_logic;
        din_ready       : out std_logic;
        dout            : out std_logic_vector(G_W              -1 downto 0);
        dout_valid      : out std_logic;
        dout_ready      : in  std_logic
    );
end fwft_fifo;

architecture structure of fwft_fifo is
    type t_mem is array (2**G_LOG2DEPTH-1 downto 0)
        of std_logic_vector(G_W-1 downto 0);
    signal iready : std_logic;
    signal ovalid : std_logic;
begin
    din_ready  <= iready;
    dout_valid <= ovalid;
    
    gSync:
    if (not G_ASYNC_RSTN) generate
        process(clk)
            variable memory : t_mem;
            variable wrptr  : std_logic_vector(G_LOG2DEPTH      -1 downto 0);
            variable rdptr  : std_logic_vector(G_LOG2DEPTH      -1 downto 0);
            variable looped : boolean;
        begin
            if rising_edge(clk) then
                if (rst = '1') then
                    wrptr  := (others => '0');
                    rdptr  := (others => '0');
                    looped := False;
                    
                    iready <= '1';
                    ovalid <= '0';
                else                                
                    if (dout_ready = '1' and ovalid = '1') then
                        if ((looped = True) or (wrptr /= rdptr)) then
                            if (unsigned(rdptr) = 2**G_LOG2DEPTH-1) then
                                looped := False;
                            end if;                    
                            rdptr := std_logic_vector(unsigned(rdptr) + 1);
                        end if;
                    end if;
                    
                    if (din_valid = '1' and iready = '1') then
                        if ((looped = False) or (wrptr /= rdptr)) then
                            memory(to_integer(unsigned(wrptr))) := din;
                            
                            if (unsigned(wrptr) = 2**G_LOG2DEPTH-1) then
                                looped := True;
                            end if;
                            wrptr := std_logic_vector(unsigned(wrptr) + 1);                        
                        end if;                    
                    end if;
                                                                   
                    dout <= memory(to_integer(unsigned(rdptr)));
                    
                    --! Update flags
                    if (wrptr = rdptr) then
                        if (looped) then
                            iready <= '0';
                        else
                            ovalid <= '0';
                        end if;
                    else
                        iready <= '1';
                        ovalid <= '1';
                    end if;
                end if;
            end if;
        end process;    
    end generate;
    gAsync:
    if (G_ASYNC_RSTN) generate
        process(clk, rst)
            variable memory : t_mem;
            variable wrptr  : std_logic_vector(G_LOG2DEPTH      -1 downto 0);
            variable rdptr  : std_logic_vector(G_LOG2DEPTH      -1 downto 0);
            variable looped : boolean;
        begin
            if (rst = '0') then
                wrptr  := (others => '0');
                rdptr  := (others => '0');
                looped := False;
                
                iready <= '1';
                ovalid <= '0';
            elsif rising_edge(clk) then
                if (dout_ready = '1' and ovalid = '1') then
                    if ((looped = True) or (wrptr /= rdptr)) then
                        if (unsigned(rdptr) = 2**G_LOG2DEPTH-1) then
                            looped := False;
                        end if;                    
                        rdptr := std_logic_vector(unsigned(rdptr) + 1);
                    end if;
                end if;
                
                if (din_valid = '1' and iready = '1') then
                    if ((looped = False) or (wrptr /= rdptr)) then
                        memory(to_integer(unsigned(wrptr))) := din;
                        
                        if (unsigned(wrptr) = 2**G_LOG2DEPTH-1) then
                            looped := True;
                        end if;
                        wrptr := std_logic_vector(unsigned(wrptr) + 1);                        
                    end if;                    
                end if;
                                                               
                dout <= memory(to_integer(unsigned(rdptr)));
                
                --! Update flags
                if (wrptr = rdptr) then
                    if (looped) then
                        iready <= '0';
                    else
                        ovalid <= '0';
                    end if;
                else
                    iready <= '1';
                    ovalid <= '1';
                end if;
            end if;
        end process;    
    end generate;
end architecture structure;
