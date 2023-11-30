----------------------------------------------------------------------------------
-- Company: Crytpographic Engineering Research Group (CERG)
-- URL: http://cryptography.gmu.edu
-- Engineer: Jens-Peter Kaps
-- 
-- Create Date: 08/25/2017 03:39:27 PM
-- Design Name: 
-- Module Name: tb_divider - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.all;

entity tb_divider is
--  Port ( );
end tb_divider;

architecture Behavioral of tb_divider is

    signal divident : STD_LOGIC_VECTOR (31 downto 0);
    signal count    : STD_LOGIC_VECTOR (19 downto 0);
    signal result   : STD_LOGIC_VECTOR (31 downto 0);
    signal start    : STD_LOGIC;
    signal done     : STD_LOGIC;
    signal clk      : STD_LOGIC := '0';

begin
    dut: entity xil_defaultlib.divider(Behavioral) port map(
        divident  => divident, 
        divisor   => count, 
        quotient  => result,
        start     => start,   -- ADC value ready
        done      => done,    -- output ready (1 clk only)
        clk       => clk );
        
    clk <= not clk after 50 ns;
   

    testsequence: process
    begin
    
        start <= '0';
        divident<= "00000000000000000000000001110101";
        count   <= "00000000000000100111";

        wait until clk='1';
        wait for 5 ns;
        
        start <= '1';
        wait until clk='1';
        
        wait until clk='1';
        wait for 5 ns;
        
        start <= '0';
                                                                                                                                                                        
        wait until done='1';                
        wait for 5 ns;
    
    end process;

end Behavioral;
