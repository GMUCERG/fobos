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
-- Revision 1.00 - adjusted to updated divider_s, testing corner cases
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

entity tb_divider_s is
--  Port ( );
end tb_divider_s;

architecture Behavioral of tb_divider_s is

    signal dividend : STD_LOGIC_VECTOR (33 downto 0);
    signal count    : STD_LOGIC_VECTOR (19 downto 0);
    signal result   : STD_LOGIC_VECTOR (33 downto 0);
    signal corr_bit : STD_LOGIC;
    signal start    : STD_LOGIC;
    signal corr     : STD_LOGIC;
    signal clk      : STD_LOGIC := '0';

begin
    dut: entity xil_defaultlib.divider_s(Behavioral) port map(
        dividend  => dividend, 
        divisor   => count, 
        quotient  => result,
        corr_bit  => corr_bit,
        start     => start,   -- ADC value ready
        corr      => corr,
        clk       => clk );
        
    clk <= not clk after 50 ns;
   

    testsequence: process
    begin
    
        start    <= '0';
        corr     <= '0';
        dividend <= "0000000000011101110000000000000000";
        count    <= "00000000000000000001";
--        dividend <= "1110000000000000000000000000000000";
--        count    <= "11100000000000000000";        
--        dividend <= "0000000000000011100000000000000000";
--        count    <= "11100000000000000000";
--        dividend <= "0000000000000000000000000001110111";
--        count    <= "00000000000000000010";
--        dividend <= "0000000000000000000000000001110101";
--        count    <= "00000000000000100111";

        wait until clk='1';
        wait for 5 ns;
        
        start <= '1';
        wait until clk='1';
        
        wait until clk='1';
        wait for 5 ns;
        
        start <= '0';
                              
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;                                                                                                                                                  
                              
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;         
        wait until clk='1';
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns; 
        wait until clk='1';
        wait for 5 ns;
        wait until clk='1';
        wait for 5 ns;
        wait until clk='1';
        wait for 5 ns;
        wait until clk='1';
        wait for 5 ns; 
        
        corr <= '1';
        wait until clk='1';
        wait for 5 ns;
        wait until clk='1';
        wait for 5 ns;
        wait until clk='1';
        wait for 5 ns;
    end process;

end Behavioral;
