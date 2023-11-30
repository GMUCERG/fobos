--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
--Date        : Wed Jul  7 16:43:49 2021
--Host        : goedel running 64-bit Ubuntu 20.04.2 LTS
--Command     : generate_target ctrl_top_wrapper.bd
--Design      : ctrl_top_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ctrl_top_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    adc : in STD_LOGIC_VECTOR ( 9 downto 0 );
    adc_clk : out STD_LOGIC;
    adc_gain : out STD_LOGIC;
    adc_gain_mode : out STD_LOGIC;
    adc_or : in STD_LOGIC;
    ck_an_n : in STD_LOGIC_VECTOR ( 5 downto 0 );
    ck_an_p : in STD_LOGIC_VECTOR ( 5 downto 0 );
    fc_dio : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    fc2d_clk : out STD_LOGIC_VECTOR ( 0 to 0 );
    fc2d_hs : out STD_LOGIC;
    fc_io : out STD_LOGIC;
    fc_prog : out STD_LOGIC;
    fc_rst : out STD_LOGIC;
    fd2c_clk : inout STD_LOGIC;
    fd2c_hs : in STD_LOGIC;
    fd_tf : in STD_LOGIC;
    gain_3v3 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gain_5v : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gain_var : out STD_LOGIC_VECTOR ( 1 downto 0 );
    glitch : out STD_LOGIC;
    glitch_lp : out STD_LOGIC;
    power_en : out STD_LOGIC;
    power_ok : in STD_LOGIC;
    power : out STD_LOGIC_VECTOR ( 5 downto 0 );
    led : out STD_LOGIC_VECTOR ( 3 downto 0 );
    trigger_osc : out STD_LOGIC
  );
end ctrl_top_wrapper;

architecture STRUCTURE of ctrl_top_wrapper is
  component ctrl_top is
  port (
    adc : in STD_LOGIC_VECTOR ( 9 downto 0 );
    adc_clk : out STD_LOGIC;
    adc_gain : out STD_LOGIC;
    adc_gain_mode : out STD_LOGIC;
    power_en : out STD_LOGIC;
    power_ok : in STD_LOGIC;
    led : out STD_LOGIC_VECTOR ( 3 downto 0 );
    trigger_osc : out STD_LOGIC;
    ck_an_n : in STD_LOGIC_VECTOR ( 5 downto 0 );
    ck_an_p : in STD_LOGIC_VECTOR ( 5 downto 0 );
    glitch : out STD_LOGIC;
    glitch_lp : out STD_LOGIC;
    adc_or : in STD_LOGIC;
    fc_prog : out STD_LOGIC;
    fc_io : out STD_LOGIC;
    fc_rst : out STD_LOGIC;
    fd_tf : in STD_LOGIC;
    fd2c_clk_I : in STD_LOGIC;
    fd2c_clk_O : out STD_LOGIC;
    fd2c_clk_D : out STD_LOGIC;
    fc2d_clk : out STD_LOGIC_VECTOR ( 0 to 0 );
    fc2d_hs : out STD_LOGIC;
    fd2c_hs : in STD_LOGIC;
    gain_3v3 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gain_5v : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gain_var : out STD_LOGIC_VECTOR ( 1 downto 0 );
    pwr_O : out STD_LOGIC_VECTOR ( 5 downto 0 );
    pwr_T : out STD_LOGIC_VECTOR ( 5 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    dio_I : in STD_LOGIC_VECTOR ( 3 downto 0 );
    dio_O : out STD_LOGIC_VECTOR ( 3 downto 0 );
    dio_T : out STD_LOGIC_VECTOR (3 downto 0)
  );
  end component ctrl_top;
  
  signal pwr_O: std_logic_vector(5 downto 0);
  signal pwr_T: std_logic_vector(5 downto 0);
  
  signal dio_I: std_logic_vector(3 downto 0);
  signal dio_O: std_logic_vector(3 downto 0);
  signal dio_T: std_logic_vector(3 downto 0);
  
  signal fd2c_clk_I: std_logic;
  signal fd2c_clk_O: std_logic;
  signal fd2c_clk_D: std_logic;
   
begin
    
    POWERTRI: for i in 0 to 5 generate
      power(i) <= 'Z' when pwr_T(i) = '1' else pwr_O(i);
    end generate POWERTRI;
    
    fc_dio(0) <= dio_O(0)  when dio_T(0) = '1' else 'Z';
    dio_I(0)  <= fc_dio(0) when dio_T(0) = '0' else '0';
    fc_dio(1) <= dio_O(1)  when dio_T(1) = '1' else 'Z';
    dio_I(1)  <= fc_dio(1) when dio_T(1) = '0' else '0';
    fc_dio(2) <= dio_O(2)  when dio_T(2) = '1' else 'Z';
    dio_I(2)  <= fc_dio(2) when dio_T(2) = '0' else '0';
    fc_dio(3) <= dio_O(3)  when dio_T(3) = '1' else 'Z';
    dio_I(3)  <= fc_dio(3) when dio_T(3) = '0' else '0';
    
    fd2c_clk <= fd2c_clk_O when fd2c_clk_D = '1' else 'Z';
    fd2c_clk_I <= fd2c_clk when fd2c_clk_D = '0' else '0';

    
ctrl_top_i: component ctrl_top
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      adc(9 downto 0) => adc(9 downto 0),
      adc_clk => adc_clk,
      adc_gain => adc_gain,
      adc_gain_mode => adc_gain_mode,
      adc_or => adc_or,
      ck_an_n(5 downto 0) => ck_an_n(5 downto 0),
      ck_an_p(5 downto 0) => ck_an_p(5 downto 0),
      dio_I(3 downto 0) => dio_I(3 downto 0),
      dio_O(3 downto 0) => dio_O(3 downto 0),
      dio_T(3 downto 0) => dio_T(3 downto 0),
      fc2d_clk(0) => fc2d_clk(0),
      fc2d_hs => fc2d_hs,
      fc_io => fc_io,
      fc_prog => fc_prog,
      fc_rst => fc_rst,
      fd2c_hs => fd2c_hs,
      fd_tf => fd_tf,
      fd2c_clk_I => fd2c_clk_I,
      fd2c_clk_O => fd2c_clk_O,
      fd2c_clk_D => fd2c_clk_D,
      gain_3v3(1 downto 0) => gain_3v3(1 downto 0),
      gain_5v(1 downto 0) => gain_5v(1 downto 0),
      gain_var(1 downto 0) => gain_var(1 downto 0),
      glitch => glitch,
      glitch_lp => glitch_lp,
      power_en => power_en,
      power_ok => power_ok,
      pwr_O(5 downto 0) => pwr_O(5 downto 0),
      pwr_T(5 downto 0) => pwr_T(5 downto 0),
      led => led,
      trigger_osc => trigger_osc
    );
    
end STRUCTURE;
