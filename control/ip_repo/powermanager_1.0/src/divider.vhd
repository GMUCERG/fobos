----------------------------------------------------------------------------------
-- Company: Crytpographic Engineering Research Group (CERG)
-- URL: http://cryptography.gmu.edu
-- Engineer: Jens-Peter Kaps
-- 
-- Create Date: 08/21/2017 16:48:30 
-- Design Name: 
-- Module Name: divider - Behavioral
-- Project Name: 
-- Target Devices: PYNQ-Z1
-- Tool Versions: Vivado 2016.1
-- Description: 
--     Computes Average as M_k = M_{k-1} + \frac{ x_k - M_{k-1} }{ k }
--     where k is the measurement count, M_k is the current average and x_k
--     is the current measurement.
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.all;

entity divider is
    Port ( adc_value : in  STD_LOGIC_VECTOR (15 downto 0); -- note: only 12 MSB have data
           divisor   : in  STD_LOGIC_VECTOR (19 downto 0); 
           drdy      : in  STD_LOGIC;                      -- ADC value ready
           done      : out STD_LOGIC;                      -- output ready (1 clk only)
           clk       : in  STD_LOGIC
           );
end divider; 

architecture Behavioral of divider is
    signal d      : UNSIGNED (20 downto 0);
    signal s_up   : UNSIGNED (20 downto 0);           -- upper 21 bits of s
    signal s_low  : STD_LOGIC_VECTOR (10 downto 0);   -- lower 11 bits of s
    signal s_upn  : UNSIGNED (20 downto 0);           -- new upper 21 bits (after adder)
    signal s      : STD_LOGIC_VECTOR (31 downto 0);   -- state / remainder
    signal addsub : STD_LOGIC;
    signal start  : STD_LOGIC;

begin
    start <= drdy;

    -- determine if we add or subtract, add = 0, sub = 1
    addsub <= '0' when start = '1' else not(s(31 downto 31));

    -- expand divisor with sign bit and built 1's complement of divisor if subtract
    d      <= '0' & unsigned(divisor) when addsub = '0' else '1' & unsigned(not(divisor)) ;
    
    -- shifted s or initial values, adc_value(3 downto 0) are "0"
    s_up   <= unsigned(s(30 downto 10)) when start = '0' else unsigned (others => '0' & adc_value(15 downto 15);
    s_low  <= s(9 downto 0) & not(s(31 downto 31)) when start = '1' else adc_value(14 downto 3); 

    -- add divisor from upper part of state / remainder, convert 1's comp to 2's comp if subtract
    s_upn  <= d + s_up + unsigned(addsub);

    -- assemble and store the state / remainder
    remainder: process(clk)
    begin
      if clk'event and clk = '1' then
        s  <= std_logic_vector(s_upn & l_low);
      end if
    end process;

begin


end Behavioral
