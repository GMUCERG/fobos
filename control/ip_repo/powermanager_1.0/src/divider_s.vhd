----------------------------------------------------------------------------------
-- Company: Crytpographic Engineering Research Group (CERG)
-- URL: http://cryptography.gmu.edu
-- Engineer: Jens-Peter Kaps
-- 
-- Create Date: 08/21/2017 16:48:30 
-- Design Name: 
-- Module Name: divider_s - Behavioral
-- Project Name: 
-- Target Devices: PYNQ-Z1
-- Tool Versions: Vivado 2016.1
-- Description: 
--     Non restoring signed division
--     divider divides a signed 34 bit divident by an unsigned 20 bit divisor in 21 clock cycles
--     the result is a 34 bit value
--     final correction value still has to be added to result
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.02 - Added control logic
-- Revision 0.03 - Enabled signed division
-- Revision 0.04 - Moved control logic to external entity
-- Revision 1.00 - Increased divident to 34 bits for signed number
--               - Changed divisor to 20 bit unsigned positive number
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

entity divider_s is
    Port ( dividend  : in  STD_LOGIC_VECTOR (33 downto 0); -- 
           divisor   : in  STD_LOGIC_VECTOR (19 downto 0); 
           quotient  : out STD_LOGIC_VECTOR (33 downto 0); -- result
           corr_bit  : out STD_LOGIC;                      -- correction bit to be added to quotient
           start     : in  STD_LOGIC;                      -- ADC value ready
           corr      : in  STD_LOGIC;                      -- compute correction
           clk       : in  STD_LOGIC );
end divider_s; 

architecture Behavioral of divider_s is
    signal d      : UNSIGNED (20 downto 0);
    signal s_up   : UNSIGNED (20 downto 0);           -- upper 21 bits of s
    signal s_low  : STD_LOGIC_VECTOR (32 downto 0);   -- lower 31 bits of s
    signal s_upn  : UNSIGNED (20 downto 0);           -- new upper 21 bits (after adder)
    signal s      : STD_LOGIC_VECTOR (53 downto 0);   -- remainder and quotient
    signal s_in   : STD_LOGIC_VECTOR (53 downto 0);   -- remainder and quotient before register
    signal rema   : STD_LOGIC_VECTOR (19 downto 0);   -- partial remainder
    signal quot   : STD_LOGIC_VECTOR (33 downto 0);   -- partial quotient 
    signal addsub : STD_LOGIC;                        -- add = 0, subtract = 1

begin
   ---- DATAPATH ----

    -- determine if we add or subtract, add = 0, sub = 1
    addsub <= dividend(33) xnor '0' when start = '1' else s(53) xnor '0';

    -- expand divisor with sign bit '0' as divisor is unsigned and built 1's complement of divisor if subtract
    d      <= unsigned('0' & divisor) when addsub = '0' else unsigned(not('0' & divisor)) ;
    
    -- shifted s or initial values, adc_value(3 downto 0) are "0"
    s_up   <= unsigned(s(52 downto 32)) when start = '0' else (others => dividend(33));
    s_low  <= s(31 downto 0) & (not(s(53)) xor '0') when start = '0' else dividend(32 downto 0); 

    -- add divisor from upper part of state / remainder, convert 1's comp to 2's comp if subtract
    s_upn  <= d + s_up + unsigned'("" & addsub);

    -- assemble and store the partial remainder and quotient
    s_in   <= std_logic_vector(s_upn) & s_low when corr = '0' else std_logic_vector(s_upn(20 downto 1)) & s_up(0) & s_low;
    
    remainderreg: process(clk)
    begin
      if clk'event and clk = '1' then
        rema  <= s_in(53 downto 34);
      end if;
    end process;

    quotientreg: process(clk, corr)
    begin
      if clk'event and clk = '1' then
--        if corr = '0' then
            quot <= s_in(33 downto 0);
--        end if; 
      end if;
    end process;

    s <= rema & quot;
    
    corr_bit <= not(s(53)) xor '0';
    quotient <= quot;

   ---- CONTROL ----
   -- external --

end Behavioral;
