----------------------------------------------------------------------------------
-- Company: Crytpographic Engineering Research Group (CERG)
-- URL: http://cryptography.gmu.edu
-- Engineer: Jens-Peter Kaps
-- 
-- Create Date: 08/21/2017 16:48:30 
-- Design Name: 
-- Module Name: average - Behavioral
-- Project Name: 
-- Target Devices: PYNQ-Z1
-- Tool Versions: Vivado 2016.1
-- Description: 
--     Computes Average as M_k = M_{k-1} + \frac{ x_k - M_{k-1} }{ k }
--     where k is the measurement count, M_k is the current average and x_k
--     is the current measurement.
--     The alignment of data in "avg" is 
--     signbit | carry | 12 bits from ADC | 20 '0's = 34 bits
--     Therefor, the counter "cnt" can go up to 2^20 without loss of resolution.
--     Hence, if "cnt(20)" is one we set "cnt_over" as counter overflow.
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.00 - Added control logic
-- Revision 1.10 - Corrected so it can handle x_k - M_{k-1} becoming negative
--               - Made sure that overfow stays set till clear
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

entity average is
    Port ( value     : in  STD_LOGIC_VECTOR (15 downto 0); -- x_k
           value_vld : in  STD_LOGIC;                      -- new value valid, start computation
           average   : out STD_LOGIC_VECTOR (15 downto 0); -- result: M_k, stays constant till new result
           clear     : in  STD_LOGIC;                      -- clear average value and counter k
           done      : out STD_LOGIC;                      -- new average ready, 1 clk
           smpcnt    : out STD_LOGIC_VECTOR (19 downto 0); -- number of measurements           
           overflow  : out STD_LOGIC;                      -- counter k overflowed
           clk       : in  STD_LOGIC );
end average; 

architecture Behavioral of average is

    signal cnt       : unsigned (5 downto 0);            -- count 33 clk cycles till done
    signal cntk      : unsigned (19 downto 0);           -- k lets us average up to 2^20 values
    signal corr      : STD_LOGIC;                        -- correction step
    signal corr_bit  : STD_LOGIC;                        -- bit to be added for correction
    signal startdiv  : STD_LOGIC;                        -- start division
    signal newavg    : STD_LOGIC;                        -- new average is computed
    signal xmk       : STD_LOGIC;                        -- compute x-M_{k-1}
    signal dividend  : STD_LOGIC_VECTOR(33 downto 0);    -- result of x-M_{k-1}
    signal quotient  : STD_LOGIC_VECTOR(33 downto 0);    -- result of x-M_{k-1} / k
    signal avgadd    : unsigned (33 downto 0);           -- result of addition / subtraction
    signal avg       : unsigned (33 downto 0);           -- current average
    signal ain       : unsigned (33 downto 0);           -- input to adder
    signal bin       : unsigned (33 downto 0);           -- input to adder
    signal cin       : STD_LOGIC;                        -- carry in to adder
    signal wait_vld  : STD_LOGIC;                        -- 0 when value_vld = 0 and one clk after value_vld = 1 even if value_vld remains 1
    signal avgtmp    : STD_LOGIC_VECTOR(33 downto 0);    -- 
    signal ov        : STD_LOGIC;                        -- overflow
    
begin
   ---- DATAPATH ----
   ain <= unsigned("00" & value & "0000000000000000" ) when xmk = '1' else unsigned(quotient);
   
   bin <= not(avg) when xmk = '1' else avg;
   
   cin <= '1' when xmk = '1' else corr_bit;
   
   avgadd <= ain + bin + unsigned'("" & cin);
   
   divider: entity xil_defaultlib.divider_s(Behavioral) port map(
        dividend  => dividend, -- x_k - M_{k-1}
        divisor   => std_logic_vector(cntk),     -- division by k
        quotient  => quotient,   -- result
        corr_bit  => corr_bit,    -- correction bit to be added to quotient
        start     => startdiv, -- start division
        corr      => corr,     -- compute correction
        clk       => clk );
   
   avgtmp <= std_logic_vector(avg);
   average <= avgtmp(31 downto 16);
        
   averagereg: process(clk)  -- could be AXI register
   begin
      if clk'event and clk = '1' then
        if clear = '1' then
            avg <= (others => '0');
        elsif newavg = '1' then
            avg  <= avgadd;
        end if;
      end if;
   end process;

   dividendreg: process(clk)
   begin
      if clk'event and clk = '1' then
          if xmk = '1' then
             dividend <= std_logic_vector(avgadd);
          end if;
      end if;
   end process;

   ---- CONTROL ----
   countera: process(clk)  -- counts clock cycles for average computation
   begin
     if clk'event and clk = '1' then
       if clear = '1' then 
           cnt <= (others => '0');
       elsif cnt = "000000" and value_vld = '1' and ov = '0' then
           cnt <= cnt +1;
       elsif cnt = "100101" then
           cnt <= "000000";
       elsif NOT (cnt = "000000") then
           cnt <= cnt +1;
       end if; 
     end if;   
       
--     if clk'event and clk = '1' then
--       if value_vld = '1' then
--           cnt <= (others => '0');
--       else
--           if NOT (cnt = "100101") then
--               cnt <= cnt  +1;
--           end if;
--       end if;
--     end if;

   end process;
   
   xmk      <= '1' when cnt = "000000" else '0';  -- compute x-M_{k-1}
   startdiv <= '1' when cnt = "000001" else '0';  -- start division
   corr     <= '1' when cnt = "100011" else '0';  -- correction step (33 clk after start / )
   newavg   <= '1' when cnt = "100100" else '0';  -- new average into register (34 clk after start /)
   done     <= '1' when cnt = "100101" else '0';  -- new average ready at register output
   
   
   counterk: process(clk)  -- counts number of samples averaged
   begin
     if clk'event and clk = '1' then
       if value_vld = '0'  then
           wait_vld <= '0';
       end if;
       if clear = '1' then
           cntk <= (others => '0');
       elsif (value_vld = '1' and wait_vld = '0' and ov = '0' and cnt = "000000") then 
           cntk <= cntk +1;
           wait_vld <= '1';  -- prevents long valids from incrementing counter more than once
       end if;
     end if;
   end process;
   
   ov <= '1' when cntk = "11111111111111111111" else '0';
   overflow <= ov;
   smpcnt <= std_logic_vector(cntk);

end Behavioral;

