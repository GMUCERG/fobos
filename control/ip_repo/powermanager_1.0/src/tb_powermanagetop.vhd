----------------------------------------------------------------------------------
-- Company: Crytpographic Engineering Research Group (CERG)
-- URL: http://cryptography.gmu.edu
-- Engineer: Jens-Peter Kaps
-- 
-- Create Date: 07/28/2017 11:53:10 AM
-- Design Name: 
-- Module Name: tb_powermanagetop - tb
-- Project Name: 
-- Target Devices: PYNQ-Z1
-- Tool Versions: Vivado 2017.2
-- Description: 
--     Instantiates XADC and uses its '16'-bit value
--     Only the upper 12 bits have a value
--     When start='1' it determines maximum value
--     and average value until start='0'
--     max and average are only updated when a new value from XADC is ready
--     clear='1' resets maximum and average back to 0
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
use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.all;

entity tb_powermanagetop is
end tb_powermanagetop;

architecture Behavioral of tb_powermanagetop is

    signal clk            : std_logic := '0';
    signal clear          : std_logic := '0';
    signal busy           : std_logic;
    signal trigenhw       : std_logic := '0';
    signal trigsw         : std_logic := '0';   
    signal triggedhw      : std_logic;
    signal triggedsw      : std_logic;
    signal cntover        : std_logic;
    signal now_volt3v3    : std_logic_vector(15 downto 0);
    signal now_cur3v3     : std_logic_vector(15 downto 0);
    signal now_volt5v     : std_logic_vector(15 downto 0);
    signal now_cur5v      : std_logic_vector(15 downto 0);
    signal avg_volt3v3    : std_logic_vector(15 downto 0);
    signal max_volt3v3    : std_logic_vector(15 downto 0);
    signal avg_cur3v3     : std_logic_vector(15 downto 0);
    signal max_cur3v3     : std_logic_vector(15 downto 0);
    signal avg_volt5v     : std_logic_vector(15 downto 0);
    signal max_volt5v     : std_logic_vector(15 downto 0);
    signal avg_cur5v      : std_logic_vector(15 downto 0);
    signal max_cur5v      : std_logic_vector(15 downto 0);
    signal samplcnt       : std_logic_vector(19 downto 0);   
    signal trigger        : std_logic := '0';
    signal ck_an_n        : std_logic_vector(3 downto 0) := "0000";
    signal ck_an_p        : std_logic_vector(3 downto 0) := "0000";
        
component powermanagetop port(  
    clk          : in std_logic;
    clear        : in std_logic;
    busy         : out std_logic;  
    trigenhw     : in  std_logic;
    trigsw       : in  std_logic;
    triggedhw    : out std_logic;
    triggedsw    : out std_logic;
    cntover      : out std_logic;          
    now_volt3v3  : out std_logic_vector(15 downto 0);
    now_cur3v3   : out std_logic_vector(15 downto 0);
    now_volt5v   : out std_logic_vector(15 downto 0);
    now_cur5v    : out std_logic_vector(15 downto 0);
    avg_volt3v3  : out std_logic_vector(15 downto 0);
    max_volt3v3  : out std_logic_vector(15 downto 0);
    avg_cur3v3   : out std_logic_vector(15 downto 0);
    max_cur3v3   : out std_logic_vector(15 downto 0);
    avg_volt5v   : out std_logic_vector(15 downto 0);
    max_volt5v   : out std_logic_vector(15 downto 0);
    avg_cur5v    : out std_logic_vector(15 downto 0);
    max_cur5v    : out std_logic_vector(15 downto 0);
    samplcnt     : out std_logic_vector(19 downto 0);          
    trigger      : in  std_logic;
    ck_an_n      : in std_logic_vector(3 downto 0);
    ck_an_p      : in std_logic_vector(3 downto 0) );
end component;
                                     
begin
  uut: entity xil_defaultlib.powermanagetop(Behavioral) port map(
    clk          => clk,        
    clear        => clear,      
    busy         => busy,       
    trigenhw     => trigenhw,   
    trigsw       => trigsw,     
    triggedhw    => triggedhw,  
    triggedsw    => triggedsw,  
    cntover      => cntover,    
    now_volt3v3  => now_volt3v3,
    now_cur3v3   => now_cur3v3, 
    now_volt5v   => now_volt5v, 
    now_cur5v    => now_cur5v,  
    avg_volt3v3  => avg_volt3v3,
    max_volt3v3  => max_volt3v3,
    avg_cur3v3   => avg_cur3v3, 
    max_cur3v3   => max_cur3v3, 
    avg_volt5v   => avg_volt5v, 
    max_volt5v   => max_volt5v, 
    avg_cur5v    => avg_cur5v,  
    max_cur5v    => max_cur5v,  
    samplcnt     => samplcnt,   
    trigger      => trigger,    
    ck_an_n      => ck_an_n,    
    ck_an_p      => ck_an_p        
  );

  clk <= not clk after 10 ns;
  
  testsequence: process
  begin
    wait for 25ns;
    clear <= '1';
    wait for 20ns;
    clear <= '0';
  
    wait for 10000 ns;
    trigsw <= '1';
  
    wait for 30000 ns;
    trigsw <= '0';
    
  end process;

end Behavioral;

