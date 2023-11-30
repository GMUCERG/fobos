----------------------------------------------------------------------------------
-- Company: Crytpographic Engineering Research Group (CERG)
-- URL: http://cryptography.gmu.edu
-- Engineer: Jens-Peter Kaps
-- 
-- Create Date: 07/28/2017 11:53:10 AM
-- Design Name: 
-- Module Name: powermanagetop - Behavioral
-- Project Name: 
-- Target Devices: PYNQ-Z1
-- Tool Versions: Vivado 2020.2
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
-- Revision 0.1  - Added 2 more channels
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
library UNISIM;
use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.all;
       
entity powermanagetop is
    port(  
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
          now_voltvar  : out std_logic_vector(15 downto 0);
          now_curvar   : out std_logic_vector(15 downto 0);
          avg_volt3v3  : out std_logic_vector(15 downto 0);
          max_volt3v3  : out std_logic_vector(15 downto 0);
          avg_cur3v3   : out std_logic_vector(15 downto 0);
          max_cur3v3   : out std_logic_vector(15 downto 0);
          avg_volt5v   : out std_logic_vector(15 downto 0);
          max_volt5v   : out std_logic_vector(15 downto 0);
          avg_cur5v    : out std_logic_vector(15 downto 0);
          max_cur5v    : out std_logic_vector(15 downto 0);
          avg_voltvar  : out std_logic_vector(15 downto 0);
          max_voltvar  : out std_logic_vector(15 downto 0);
          avg_curvar   : out std_logic_vector(15 downto 0);
          max_curvar   : out std_logic_vector(15 downto 0);
          samplcnt     : out std_logic_vector(19 downto 0);          
          trigger      : in  std_logic;
          ck_an_n      : in std_logic_vector(3 downto 0);
          ck_an_p      : in std_logic_vector(3 downto 0));
end powermanagetop;


architecture Behavioral of powermanagetop is

    signal volt3v3     : STD_LOGIC_VECTOR (15 downto 0);
    signal cur3v3      : STD_LOGIC_VECTOR (15 downto 0);
    signal volt5v      : STD_LOGIC_VECTOR (15 downto 0);
    signal cur5v       : STD_LOGIC_VECTOR (15 downto 0);
    signal voltvar     : STD_LOGIC_VECTOR (15 downto 0);
    signal curvar      : STD_LOGIC_VECTOR (15 downto 0);
    signal volt3v3_reg : STD_LOGIC_VECTOR (15 downto 0);
    signal cur3v3_reg  : STD_LOGIC_VECTOR (15 downto 0);
    signal volt5v_reg  : STD_LOGIC_VECTOR (15 downto 0);
    signal cur5v_reg   : STD_LOGIC_VECTOR (15 downto 0);
    signal voltvar_reg : STD_LOGIC_VECTOR (15 downto 0);
    signal curvar_reg  : STD_LOGIC_VECTOR (15 downto 0);
    signal trigged_sw  : STD_LOGIC;  -- SW Trigger has fired
    signal trigged_hw  : STD_LOGIC;  -- HW Trigger has fired
    signal trigon      : STD_LOGIC;  -- SW or HW trigger is on
    signal gotvalues   : STD_LOGIC;  -- ADC values collected and ready
    signal valueready  : STD_LOGIC;  -- got values and we are triggered
    signal adc_value   : STD_LOGIC_VECTOR (15 downto 0);
    signal avgvolt3v3  : STD_LOGIC_VECTOR (15 downto 0);
    signal avgcur3v3   : STD_LOGIC_VECTOR (15 downto 0);
    signal avgvolt5v   : STD_LOGIC_VECTOR (15 downto 0);        
    signal avgcur5v    : STD_LOGIC_VECTOR (15 downto 0);
    signal avgvoltvar  : STD_LOGIC_VECTOR (15 downto 0);        
    signal avgcurvar   : STD_LOGIC_VECTOR (15 downto 0);
    signal maxvolt3v3  : STD_LOGIC_VECTOR (15 downto 0);
    signal maxcur3v3   : STD_LOGIC_VECTOR (15 downto 0);        
    signal maxvolt5v   : STD_LOGIC_VECTOR (15 downto 0);
    signal maxcur5v    : STD_LOGIC_VECTOR (15 downto 0);
    signal maxvoltvar  : STD_LOGIC_VECTOR (15 downto 0);
    signal maxcurvar   : STD_LOGIC_VECTOR (15 downto 0);
    signal smpcnt      : STD_LOGIC_VECTOR (19 downto 0);    
    signal overflow    : STD_LOGIC;       
    signal drdy        : STD_LOGIC;                
    signal vauxp1      : STD_LOGIC;
    signal vauxn1      : STD_LOGIC;
    signal vauxp5      : STD_LOGIC;
    signal vauxn5      : STD_LOGIC;
    signal vauxp6      : STD_LOGIC;
    signal vauxn6      : STD_LOGIC;
    signal vauxp9      : STD_LOGIC;
    signal vauxn9      : STD_LOGIC;
    signal vauxp13     : STD_LOGIC;
    signal vauxn13     : STD_LOGIC;
    signal vauxp15     : STD_LOGIC;
    signal vauxn15     : STD_LOGIC;            
    signal eos         : STD_LOGIC;
    signal eoc         : STD_LOGIC;
    signal eocden      : STD_LOGIC;
    signal den         : STD_LOGIC;
    signal daddr       : STD_LOGIC_VECTOR(7 downto 0);
    type   state_type is ( start,
                           read_volt3v3, 
                           wait_volt3v3, 
                           read_cur3v3,
                           wait_cur3v3,  
                           read_volt5v,                           
                           wait_volt5v,  
                           read_cur5v, 
                           wait_cur5v,
                           read_voltvar,                           
                           wait_voltvar,  
                           read_curvar, 
                           wait_curvar      
                           );
    signal cur_state, nxt_state : state_type;

COMPONENT xadc_wiz_0
      PORT (
        di_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        daddr_in : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        den_in : IN STD_LOGIC;
        dwe_in : IN STD_LOGIC;
        drdy_out : OUT STD_LOGIC;
        do_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        dclk_in : IN STD_LOGIC;  -- clock
        reset_in : IN STD_LOGIC; -- reset
        vp_in : IN STD_LOGIC;
        vn_in : IN STD_LOGIC;
        vauxp1 : IN STD_LOGIC;
        vauxn1 : IN STD_LOGIC;
        vauxp5 : IN STD_LOGIC;
        vauxn5 : IN STD_LOGIC;
        vauxp6 : IN STD_LOGIC;
        vauxn6 : IN STD_LOGIC;
        vauxp9 : IN STD_LOGIC;
        vauxn9 : IN STD_LOGIC;
        vauxp13 : IN STD_LOGIC;
        vauxn13 : IN STD_LOGIC;
        vauxp15 : IN STD_LOGIC;
        vauxn15 : IN STD_LOGIC;
        channel_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        eoc_out : OUT STD_LOGIC;
        alarm_out : OUT STD_LOGIC;
        eos_out : OUT STD_LOGIC;
        busy_out : OUT STD_LOGIC
      );
    END COMPONENT;


begin



ADC : xadc_wiz_0
  PORT MAP (
    daddr_in => daddr(6 downto 0),         -- Address bus for the dynamic reconfiguration port       
    den_in => den,                         -- Enable Signal for the dynamic reconfiguration port
    di_in => (others => '0'),              -- Input data bus for the dynamic reconfiguration port
    dwe_in => '0',                         -- Write Enable for the dynamic reconfiguration port
    do_out => adc_value,                   -- Output data bus for dynamic reconfiguration port
    drdy_out => drdy,                      -- Data ready signal for the dynamic reconfiguration port
    dclk_in => clk,                        -- Clock input for the dynamic reconfiguration port
    reset_in => '0',                       -- Reset signal for the System Monitor control logic
    vauxp1 => vauxp1,                      -- Auxiliary Channel 1
    vauxn1 => vauxn1,                                                                                
    vauxp5 => vauxp5,                      -- Auxiliary Channel 5
    vauxn5 => vauxn5,                                              
    vauxp6 => vauxp6,                      -- Auxiliary Channel 6
    vauxn6 => vauxn6,                                                                                
    vauxp9 => vauxp9,                      -- Auxiliary Channel 9
    vauxn9 => vauxn9,
    vauxp13 => vauxp13,                    -- Auxiliary Channel 13
    vauxn13 => vauxn13,                                                                                
    vauxp15 => vauxp15,                    -- Auxiliary Channel 15
    vauxn15 => vauxn15,                                                                              
    busy_out => open,                      -- ADC Busy signal
    channel_out => open,                   -- Channel Selection Outputs
    eoc_out => eoc,                       -- End of Conversion Signal
    eos_out => eos,                        -- End of Sequence Signal
    alarm_out => open,                     -- OR'ed output of all the Alarms
    vp_in => '0',                          -- Dedicated Analog Input Pair
    vn_in => '0'
  );

    vauxp1  <= ck_an_p(0);  -- A0 cur 3v3
    vauxn1  <= ck_an_n(0);  -- A0
    vauxp9  <= ck_an_p(1);  -- A1 volt 3v3
    vauxn9  <= ck_an_n(1);  -- A1
    vauxp6  <= ck_an_p(2);  -- A2 cur var
    vauxn6  <= ck_an_n(2);  -- A2
    vauxp15 <= ck_an_p(3);  -- A3 volt var
    vauxn15 <= ck_an_n(3);  -- A3
    vauxp5  <= ck_an_p(4);  -- A4 cur 5v
    vauxn5  <= ck_an_n(4);  -- A4
    vauxp13 <= ck_an_p(5);  -- A5 volt 5v
    vauxn13 <= ck_an_n(5);  -- A5

    
    eocden <= drdy OR den;
    
process(clk)
begin
    if rising_edge(clk) then
        if (clear = '1') then
            cur_state <= start;
            volt3v3_reg <= (others=>'0');
            cur3v3_reg  <= (others=>'0');
            volt5v_reg  <= (others=>'0');
            cur5v_reg   <= (others=>'0');
            voltvar_reg <= (others=>'0');
            curvar_reg  <= (others=>'0');
            valueready  <= '0';
        else   
            cur_state <= nxt_state;
            volt3v3_reg <= volt3v3 ;
            cur3v3_reg  <= cur3v3  ;
            volt5v_reg  <= volt5v  ;
            cur5v_reg   <= cur5v   ;
            voltvar_reg <= voltvar ;
            curvar_reg  <= curvar  ;
            valueready  <= trigon AND gotvalues;
        end if;
    end if;
end process;

process(cur_state, eos, drdy, adc_value, volt3v3_reg, cur3v3_reg, volt5v_reg, cur5v_reg, voltvar_reg, curvar_reg)
begin
     volt3v3 <= volt3v3_reg;
     cur3v3  <= cur3v3_reg ;
     volt5v  <= volt5v_reg ;
     cur5v   <= cur5v_reg  ;
     voltvar <= voltvar_reg;
     curvar  <= curvar_reg ;
     gotvalues <= '0';

     case (cur_state) is
         when start =>
             daddr     <= x"00";
             den       <= '0';
             if (eos = '1') then
                 nxt_state <= read_volt3v3;
             else
                 nxt_state <= start;
             end if;
         when read_volt3v3 =>
             daddr     <=  x"19";         -- AUX9 channel
             den       <=  '1';
             nxt_state <= wait_volt3v3;
         when wait_volt3v3 =>
             den       <= '0';
             daddr     <= x"19";
             if (drdy = '1') then
                 volt3v3   <= adc_value;
                 nxt_state <= read_cur3v3;
             else
                 nxt_state <= wait_volt3v3;
             end if;
         when read_cur3v3 =>
             daddr     <=  x"11";         -- AUX1 channel
             den       <=  '1';
             nxt_state <= wait_cur3v3;
         when wait_cur3v3 =>
             daddr     <= x"11";
             den       <= '0';
             if (drdy = '1') then
                 cur3v3    <= adc_value;
                 nxt_state <= read_volt5v;
             else
                 nxt_state <= wait_cur3v3;
             end if;
         when read_volt5v =>
             daddr     <=  x"1D";         -- AUX13 channel
             den       <=  '1';
             nxt_state <= wait_volt5v;
         when wait_volt5v =>
             daddr     <= x"1D";
             den       <= '0';
             if (drdy = '1') then
                 volt5v    <= adc_value;
                 nxt_state <= read_cur5v;
             else
                 nxt_state <= wait_volt5v;
             end if;
         when read_cur5v =>
             daddr     <=  x"15";         -- AUX5 channel
             den       <=  '1';
             nxt_state <= wait_cur5v;
         when wait_cur5v =>
             daddr     <= x"15";
             den       <= '0';
             if (drdy = '1') then
                 cur5v     <= adc_value;
                 gotvalues <= '1'; -- now all values are ready
                 nxt_state <= read_voltvar;
             else
                 nxt_state <= wait_cur5v;
             end if;
         when read_voltvar =>
             daddr     <=  x"1F";         -- AUX15 channel
             den       <=  '1';
             nxt_state <= wait_voltvar;
         when wait_voltvar =>
             daddr     <= x"1F";
             den       <= '0';
             if (drdy = '1') then
                 volt5v    <= adc_value;
                 nxt_state <= read_curvar;
             else
                 nxt_state <= wait_voltvar;
             end if;
         when read_curvar =>
             daddr     <=  x"16";         -- AUX6 channel
             den       <=  '1';
             nxt_state <= wait_curvar;
         when wait_curvar =>
             daddr     <= x"16";
             den       <= '0';
             if (drdy = '1') then
                 cur5v     <= adc_value;
                 gotvalues <= '1'; -- now all values are ready
                 nxt_state <= start;
             else
                 nxt_state <= wait_curvar;
             end if;
  
         when others =>
            daddr      <= x"00";
             den       <= '0';
             nxt_state <= start;
     end case;


end process;
    

    now_volt3v3 <= volt3v3_reg;
    now_cur3v3  <= cur3v3_reg;
    now_volt5v  <= volt5v_reg;
    now_cur5v   <= cur5v_reg;
    now_voltvar <= voltvar_reg;
    now_curvar  <= curvar_reg;

    
----------------------
-- Software Trigger --
----------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if (clear = '1') then
                trigged_sw <= '0';
            elsif (trigsw = '1') then
                trigged_sw <= '1';
            end if;
        end if;
    end process;

    triggedsw <= trigged_sw;

------------------------
-- Hardware Trigger 0 --
------------------------

    -- triggered?
    process(clk)
    begin
        if rising_edge(clk) then
            if (clear = '1') then
                trigged_hw <= '0';
            elsif (trigenhw = '1' and trigger = '1') then
                trigged_hw <= '1';
            end if;
        end if;
    end process;

    triggedhw <= trigged_hw;

------------------------
-- Trigger --
------------------------
    trigon <= trigsw OR (trigger AND trigenhw);    -- trigger is on

    busy <= trigon;                 -- busy when any trigger active, i.e. we are measuring

    
------------------------
-- 3V3 Measurements   --
------------------------
--- Maximum Voltage 
    process(clk)
    begin
        if rising_edge(clk) then
            if clear = '1' then
                maxvolt3v3 <= (others=>'0');
            elsif (valueready = '1') then
                if volt3v3_reg > maxvolt3v3 then                     
                    maxvolt3v3 <= volt3v3_reg;
                end if;
            end if;
        end if; 
    end process;
    max_volt3v3 <= maxvolt3v3;

--- invoke Averaging Circuit      
    avgcirvolt3v3: entity xil_defaultlib.average(Behavioral) port map(
            value     => volt3v3_reg,    -- x_k
            value_vld => valueready,   -- new value valid, start computation
            average   => avgvolt3v3,   -- result: M_k, stays constant till new result
            clear     => clear,        -- clear average value and counter k
            done      => open,         -- new average ready, 1 clk
            smpcnt    => smpcnt,       -- number of measurements
            overflow  => overflow,     -- counter k overflowed
            clk       => clk);
    avg_volt3v3 <= avgvolt3v3;
    cntover     <= overflow; 
    samplcnt    <= smpcnt;

--- Maximum Current 
    process(clk)
    begin
        if rising_edge(clk) then
            if clear = '1' then
                maxcur3v3 <= (others=>'0');
            elsif (valueready = '1') then
                if cur3v3_reg > maxcur3v3 then                     
                    maxcur3v3 <= cur3v3_reg;
                end if;
            end if;
        end if; 
    end process;
    max_cur3v3 <= maxcur3v3;

--- invoke Averaging Circuit      
    avgcircur3v3: entity xil_defaultlib.average(Behavioral) port map(
            value     => cur3v3_reg,    -- x_k
            value_vld => valueready,   -- new value valid, start computation
            average   => avgcur3v3,   -- result: M_k, stays constant till new result
            clear     => clear,        -- clear average value and counter k
            done      => open,         -- new average ready, 1 clk
            smpcnt    => open,       -- number of measurements
            overflow  => open,     -- counter k overflowed
            clk       => clk);
    avg_cur3v3 <= avgcur3v3;

    
------------------------
-- 5V Measurements   --
------------------------
--- Maximum Voltage 
    process(clk)
    begin
        if rising_edge(clk) then
            if clear = '1' then
                maxvolt5v <= (others=>'0');
            elsif (valueready = '1') then
                if volt5v_reg > maxvolt5v then                     
                    maxvolt5v <= volt5v_reg;
                end if;
            end if;
        end if; 
    end process;
    max_volt5v <= maxvolt5v;

--- invoke Averaging Circuit      
    avgcirvolt5v: entity xil_defaultlib.average(Behavioral) port map(
            value     => volt5v_reg,    -- x_k
            value_vld => valueready,   -- new value valid, start computation
            average   => avgvolt5v,   -- result: M_k, stays constant till new result
            clear     => clear,        -- clear average value and counter k
            done      => open,         -- new average ready, 1 clk
            smpcnt    => open,       -- number of measurements
            overflow  => open,     -- counter k overflowed
            clk       => clk);
    avg_volt5v <= avgvolt5v;
    cntover     <= overflow; 
    samplcnt    <= smpcnt;

--- Maximum Current 
    process(clk)
    begin
        if rising_edge(clk) then
            if clear = '1' then
                maxcur5v <= (others=>'0');
            elsif (valueready = '1') then
                if cur5v_reg > maxcur5v then                     
                    maxcur5v <= cur5v_reg;
                end if;
            end if;
        end if; 
    end process;
    max_cur5v <= maxcur5v;

--- invoke Averaging Circuit      
    avgcircur5v: entity xil_defaultlib.average(Behavioral) port map(
            value     => cur5v_reg,    -- x_k
            value_vld => valueready,   -- new value valid, start computation
            average   => avgcur5v,   -- result: M_k, stays constant till new result
            clear     => clear,        -- clear average value and counter k
            done      => open,         -- new average ready, 1 clk
            smpcnt    => open,       -- number of measurements
            overflow  => open,     -- counter k overflowed
            clk       => clk);
    avg_cur5v <= avgcur5v;

------------------------
-- Var Measurements   --
------------------------
--- Maximum Voltage 
    process(clk)
    begin
        if rising_edge(clk) then
            if clear = '1' then
                maxvoltvar <= (others=>'0');
            elsif (valueready = '1') then
                if voltvar_reg > maxvoltvar then                     
                    maxvoltvar <= voltvar_reg;
                end if;
            end if;
        end if; 
    end process;
    max_voltvar <= maxvoltvar;

--- invoke Averaging Circuit      
    avgcirvoltvar: entity xil_defaultlib.average(Behavioral) port map(
            value     => voltvar_reg,    -- x_k
            value_vld => valueready,   -- new value valid, start computation
            average   => avgvoltvar,   -- result: M_k, stays constant till new result
            clear     => clear,        -- clear average value and counter k
            done      => open,         -- new average ready, 1 clk
            smpcnt    => open,       -- number of measurements
            overflow  => open,     -- counter k overflowed
            clk       => clk);
    avg_voltvar <= avgvoltvar;
    cntover     <= overflow; 
    samplcnt    <= smpcnt;

--- Maximum Current 
    process(clk)
    begin
        if rising_edge(clk) then
            if clear = '1' then
                maxcurvar <= (others=>'0');
            elsif (valueready = '1') then
                if curvar_reg > maxcurvar then                     
                    maxcurvar <= curvar_reg;
                end if;
            end if;
        end if; 
    end process;
    max_curvar <= maxcurvar;

--- invoke Averaging Circuit      
    avgcircurvar: entity xil_defaultlib.average(Behavioral) port map(
            value     => curvar_reg,    -- x_k
            value_vld => valueready,   -- new value valid, start computation
            average   => avgcurvar,   -- result: M_k, stays constant till new result
            clear     => clear,        -- clear average value and counter k
            done      => open,         -- new average ready, 1 clk
            smpcnt    => open,       -- number of measurements
            overflow  => open,     -- counter k overflowed
            clk       => clk);
    avg_curvar <= avgcurvar;



end Behavioral;

