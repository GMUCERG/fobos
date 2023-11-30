library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity openadc_interface_light_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_CFG_AXI
		C_S_CFG_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_CFG_AXI_ADDR_WIDTH	: integer	:= 4;

		-- Parameters of Axi Master Bus Interface M_BLKS_AXIS
		C_M_BLKS_AXIS_TDATA_WIDTH	: integer	:= 64;
		C_M_BLKS_AXIS_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
		gain            : out std_logic;
        gain_mode       : out std_logic;
        adc_clk         : out std_logic;
        trigger         : in std_logic;
        adc_in          : in std_logic_vector (9 downto 0);
        over_range      : in std_logic;
--        -- DEBUG
--        d_cmd_capture_en  : out std_logic;
--        d_cmd_capture_rst : out std_logic;
--        d_cmd_blk_num     : out std_logic_vector (17 downto 0);
--        d_cmd_test_en     : out std_logic;
--        d_stat_capture_err: out  std_logic;
--        d_adc_capture_dout_tlast : out std_logic;
--        d_state_r       : out std_logic_vector(2 downto 0);
--        d_blk_cnt_r : out std_logic_vector (17 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S_CFG_AXI
		s_cfg_axi_aclk	: in std_logic;
		s_cfg_axi_aresetn	: in std_logic;
		s_cfg_axi_awaddr	: in std_logic_vector(C_S_CFG_AXI_ADDR_WIDTH-1 downto 0);
		s_cfg_axi_awprot	: in std_logic_vector(2 downto 0);
		s_cfg_axi_awvalid	: in std_logic;
		s_cfg_axi_awready	: out std_logic;
		s_cfg_axi_wdata	: in std_logic_vector(C_S_CFG_AXI_DATA_WIDTH-1 downto 0);
		s_cfg_axi_wstrb	: in std_logic_vector((C_S_CFG_AXI_DATA_WIDTH/8)-1 downto 0);
		s_cfg_axi_wvalid	: in std_logic;
		s_cfg_axi_wready	: out std_logic;
		s_cfg_axi_bresp	: out std_logic_vector(1 downto 0);
		s_cfg_axi_bvalid	: out std_logic;
		s_cfg_axi_bready	: in std_logic;
		s_cfg_axi_araddr	: in std_logic_vector(C_S_CFG_AXI_ADDR_WIDTH-1 downto 0);
		s_cfg_axi_arprot	: in std_logic_vector(2 downto 0);
		s_cfg_axi_arvalid	: in std_logic;
		s_cfg_axi_arready	: out std_logic;
		s_cfg_axi_rdata	: out std_logic_vector(C_S_CFG_AXI_DATA_WIDTH-1 downto 0);
		s_cfg_axi_rresp	: out std_logic_vector(1 downto 0);
		s_cfg_axi_rvalid	: out std_logic;
		s_cfg_axi_rready	: in std_logic;

		-- Ports of Axi Master Bus Interface M_BLKS_AXIS
		m_blks_axis_aclk	: in std_logic;
		m_blks_axis_aresetn	: in std_logic;
		m_blks_axis_tvalid	: out std_logic;
		m_blks_axis_tdata	: out std_logic_vector(C_M_BLKS_AXIS_TDATA_WIDTH-1 downto 0);
		m_blks_axis_tstrb	: out std_logic_vector((C_M_BLKS_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m_blks_axis_tlast	: out std_logic;
		m_blks_axis_tready	: in std_logic
	);
end openadc_interface_light_v1_0;

architecture arch_imp of openadc_interface_light_v1_0 is

	-- component declaration
	component openadc_interface_light_v1_0_S_CFG_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		-- Users to add ports here
        cmd_capture_en  : out std_logic;
        cmd_capture_rst : out std_logic;
        cmd_blk_num     : out std_logic_vector (17 downto 0); 
        cmd_test_en     : out std_logic;
        stat_capture_err: in std_logic;
        capture_done    : in std_logic;
        cmd_adc_gain    : out std_logic_vector (7 downto 0); 
        cmd_adc_hi_lo   : out std_logic;
        cmd_test_cnt_start : out std_logic_vector (9 downto 0);
        -- end user ports
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component openadc_interface_light_v1_0_S_CFG_AXI;

--	component openadc_interface_light_v1_0_M_BLKS_AXIS is
--		generic (
--		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
--		C_M_START_COUNT	: integer	:= 32
--		);
--		port (
--		M_AXIS_ACLK	: in std_logic;
--		M_AXIS_ARESETN	: in std_logic;
--		M_AXIS_TVALID	: out std_logic;
--		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
--		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
--		M_AXIS_TLAST	: out std_logic;
--		M_AXIS_TREADY	: in std_logic
--		);
--	end component openadc_interface_light_v1_0_M_BLKS_AXIS;
	
	signal adc_clk_in : std_logic;
	signal adc_rst : std_logic;
	
	-- configuration interface
	signal cmd_capture_en  : std_logic;
    signal cmd_capture_rst : std_logic;
    signal cmd_blk_num     : std_logic_vector (17 downto 0);
    signal cmd_test_en     : std_logic;
    signal stat_capture_err:  std_logic;
    signal adc_capture_dout_tlast : std_logic;
    signal cmd_test_cnt_start : std_logic_vector (9 downto 0);
    --
    signal PWM_Accumulator : std_logic_vector(8 downto 0);
    signal pwm_gain : std_logic_vector(7 downto 0);
    signal adc_hi_lo : std_logic;
    signal alternate_count : std_logic;

begin
    --DEBUG
--    d_cmd_capture_en         <= cmd_capture_en;
--    d_cmd_capture_rst        <= cmd_capture_rst;
--    d_cmd_blk_num            <= cmd_blk_num;
--    d_cmd_test_en            <= cmd_test_en;
--    d_stat_capture_err       <= stat_capture_err;
--    d_adc_capture_dout_tlast <= adc_capture_dout_tlast;

-- Instantiation of Axi Bus Interface S_CFG_AXI
    openadc_interface_light_v1_0_S_CFG_AXI_inst : openadc_interface_light_v1_0_S_CFG_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_CFG_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_CFG_AXI_ADDR_WIDTH
	)
	port map (
		-- Users to add ports here
        cmd_capture_en  => cmd_capture_en,
        cmd_capture_rst => cmd_capture_rst,
        cmd_blk_num     => cmd_blk_num, 
        cmd_test_en     => cmd_test_en,
        stat_capture_err=> stat_capture_err,
        capture_done    => adc_capture_dout_tlast,
        cmd_adc_gain    => pwm_gain, 
        cmd_adc_hi_lo   => adc_hi_lo,
        cmd_test_cnt_start => cmd_test_cnt_start,
        -- end user ports
		S_AXI_ACLK	=> s_cfg_axi_aclk,
		S_AXI_ARESETN	=> s_cfg_axi_aresetn,
		S_AXI_AWADDR	=> s_cfg_axi_awaddr,
		S_AXI_AWPROT	=> s_cfg_axi_awprot,
		S_AXI_AWVALID	=> s_cfg_axi_awvalid,
		S_AXI_AWREADY	=> s_cfg_axi_awready,
		S_AXI_WDATA	=> s_cfg_axi_wdata,
		S_AXI_WSTRB	=> s_cfg_axi_wstrb,
		S_AXI_WVALID	=> s_cfg_axi_wvalid,
		S_AXI_WREADY	=> s_cfg_axi_wready,
		S_AXI_BRESP	=> s_cfg_axi_bresp,
		S_AXI_BVALID	=> s_cfg_axi_bvalid,
		S_AXI_BREADY	=> s_cfg_axi_bready,
		S_AXI_ARADDR	=> s_cfg_axi_araddr,
		S_AXI_ARPROT	=> s_cfg_axi_arprot,
		S_AXI_ARVALID	=> s_cfg_axi_arvalid,
		S_AXI_ARREADY	=> s_cfg_axi_arready,
		S_AXI_RDATA	=> s_cfg_axi_rdata,
		S_AXI_RRESP	=> s_cfg_axi_rresp,
		S_AXI_RVALID	=> s_cfg_axi_rvalid,
		S_AXI_RREADY	=> s_cfg_axi_rready
	);

---- Instantiation of Axi Bus Interface M_BLKS_AXIS
--openadc_interface_light_v1_0_M_BLKS_AXIS_inst : openadc_interface_light_v1_0_M_BLKS_AXIS
--	generic map (
--		C_M_AXIS_TDATA_WIDTH	=> C_M_BLKS_AXIS_TDATA_WIDTH,
--		C_M_START_COUNT	=> C_M_BLKS_AXIS_START_COUNT
--	)
--	port map (
--		M_AXIS_ACLK	=> m_blks_axis_aclk,
--		M_AXIS_ARESETN	=> m_blks_axis_aresetn,
--		M_AXIS_TVALID	=> m_blks_axis_tvalid,
--		M_AXIS_TDATA	=> m_blks_axis_tdata,
--		M_AXIS_TSTRB	=> m_blks_axis_tstrb,
--		M_AXIS_TLAST	=> m_blks_axis_tlast,
--		M_AXIS_TREADY	=> m_blks_axis_tready
--	);

	-- Add user logic here
	adc_clk_in <= m_blks_axis_aclk;
	adc_rst <= not m_blks_axis_aresetn;
	m_blks_axis_tlast <= adc_capture_dout_tlast;
	adc_clk <= adc_clk_in;
	
	adc_capture_inst : entity work.adc_capture(behav)
    port map ( 
        clk             => adc_clk_in,
        rst             => adc_rst,
        -- config signals
        cmd_capture_en  => cmd_capture_en ,
        cmd_capture_rst => cmd_capture_rst,
        cmd_blk_num     => cmd_blk_num,
        cmd_test_en     => cmd_test_en,
        cmd_test_cnt_start => cmd_test_cnt_start,
        stat_capture_err=> stat_capture_err,
        --
        trigger         => trigger,
        -- data interface
        adc_in          => adc_in,      
        dout_data       => m_blks_axis_tdata,
        dout_valid      => m_blks_axis_tvalid,
        dout_ready      => m_blks_axis_tready,
        dout_tlast      => adc_capture_dout_tlast
--        ,
        --DEBUG
--        d_state_r       => d_state_r,
--        d_blk_cnt_r     => d_blk_cnt_r
    );
    
    -- gain logic
     process (s_cfg_axi_aclk)
     begin
         if rising_edge(s_cfg_axi_aclk) then
           if (alternate_count = '1') then
             PWM_Accumulator <=  std_logic_vector(unsigned('0' & (PWM_Accumulator(7 downto 0)))
                                      + unsigned('0' & pwm_gain));
             alternate_count <= '0';
           else
             alternate_count <= '1';
           end if;
         end if;
     end process;
     
     gain <= PWM_Accumulator(8); -- PWM Signal    
     gain_mode <= adc_hi_lo; 

	-- User logic ends

end arch_imp;
