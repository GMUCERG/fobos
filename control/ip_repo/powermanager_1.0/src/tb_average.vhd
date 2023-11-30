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

entity tb_average is
--  Port ( );
end tb_average;

architecture Behavioral of tb_average is

    signal value     : STD_LOGIC_VECTOR (15 downto 0);
    signal value_vld : STD_LOGIC;
    signal average   : STD_LOGIC_VECTOR (15 downto 0);
    signal clear     : STD_LOGIC;
    signal done      : STD_LOGIC;
    signal overflow  : STD_LOGIC;
    signal clk       : STD_LOGIC := '0';


begin
    dut: entity xil_defaultlib.average(Behavioral) port map(
        value     => value,       -- x_k
        value_vld => value_vld,   -- new value valid, start computation
        average   => average,     -- result: M_k, stays constant till new result
        clear     => clear,       -- clear average value and counter k
        done      => done,        -- new average ready, 1 clk
        overflow  => overflow,    -- counter k overflowed
        clk       => clk); 
        
    clk <= not clk after 50 ns;
   

    testsequence: process
        variable i       : integer := 0;
    begin
    
        value_vld <= '0';
        clear     <= '1';
        value     <= "1111111111111111";

        wait until clk='1';
        wait for 5 ns;
        clear     <= '0';

-- 0077h
        wait until clk='1';
        wait for 5 ns;
        value_vld <= '1';
        value     <= "0000000001110111";
        -- value     <= "0000000001110101";

        wait until clk='1';        
        wait for 5 ns;
        value_vld <= '0';
                                                                                                                                                                        
        wait until done='1';                
        wait for 5 ns;

-- 0000h        
        wait until clk='1';
        wait for 5 ns;        
        value_vld <= '1';
        value     <= "0000000000000000";

        wait until clk='1';
        wait for 5 ns;
        value_vld <= '0';
                                                                                                                                                                        
        wait until done='1';                
        wait for 5 ns;
        
-- c000h
        wait until clk='1';
        wait for 5 ns;
        value_vld <= '1';
        value     <= "1100000000000000";
        
        wait until clk='1';
        wait for 5 ns;
        value_vld <= '0';
                                                                                                                                                                        
        wait until done='1'; 
        wait for 5 ns;
        
-- check subtraction
-- 00c0h        
        wait until clk='1';
        wait for 5 ns;
        value_vld <= '1';
        value     <= "0000000011000000";
        
        wait until clk='1';
        wait for 5 ns;
        value_vld <= '0';
                                                                                                                                                                        
        wait until done='1'; 
        wait for 5 ns;

-- check delay
-- 0077h
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
        value_vld <= '1';
        value     <= "0000000001110111";

        wait until clk='1';
        wait for 5 ns;
        value_vld <= '0';
                                                                                                                                                                        
        wait until done='1'; 
        wait for 5 ns;
        
-- check long valid signal
-- 0076h
        wait until clk='1';
        wait for 5 ns;
        clear     <= '0';

        wait until clk='1';
        wait for 5 ns;
        value_vld <= '1';
        value     <= "0000000001110110";

        wait until clk='1';        
        wait for 5 ns;        
        wait until clk='1';
        wait for 5 ns;                
        wait until clk='1';
        wait for 5 ns;                        
        wait until clk='1';
        wait for 5 ns;        
        value_vld <= '0';
                                                                                                                                                                
        wait until done='1';                
        wait for 5 ns;
                
-- check valid during computation (new value is 0078h)
-- 007Fh
        wait until clk='1';
        wait for 5 ns;
        clear     <= '0';

        wait until clk='1';
        wait for 5 ns;
        value_vld <= '1';
        value     <= "0000000001111111";

        wait until clk='1';        
        wait for 5 ns;
        value_vld <= '0';
        
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
        value_vld <= '1';
        value     <= "0000000001111000";
  
        wait until clk='1';        
        wait for 5 ns;
        value_vld <= '0';
                                                                                                                                                                         
        wait until done='1'; 
        wait for 5 ns;        

-- run in loop until counter overlows, check overflow
-- 0077h
longloop: for i in 0 to 1048580 loop
            wait until clk='1';
            wait for 5 ns;
            value_vld <= '1';
            value <= "0000000011101110";
            
            wait until clk='1';
            wait for 5 ns;
            value_vld <= '0';

            wait until done='1'; 
            wait for 5 ns;       
        end loop longloop;

        wait;
    end process;

end Behavioral;
