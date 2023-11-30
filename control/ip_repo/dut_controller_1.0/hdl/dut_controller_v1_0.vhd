--#############################################################################
--#                                                                           #
--#   Copyright 2017-2023 Cryptographic Engineering Research Group (CERG)     #
--#                                                                           #
--#   Licensed under the Apache License, Version 2.0 (the "License");         #
--#   you may not use this file except in compliance with the License.        #
--#   You may obtain a copy of the License at                                 #
--#                                                                           #
--#       http://www.apache.org/licenses/LICENSE-2.0                          #
--#                                                                           #
--#   Unless required by applicable law or agreed to in writing, software     #
--#   distributed under the License is distributed on an "AS IS" BASIS,       #
--#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.#
--#   See the License for the specific language governing permissions and     #
--#   limitations under the License.                                          #
--#                                                                           #
--#############################################################################

----------------------------------------------------------------------------------
-- Company: Cryptographic Engineering Research Group (CERG)
-- ECE Department, George Mason University
--     Fairfax, VA, U.S.A.
--     URL: http://cryptography.gmu.edu

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dut_controller_v1_0 is
	generic(
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH : integer := 32;
		C_S_AXI_ADDR_WIDTH : integer := 7
	);
	port(
		--debug only
		d_timeout        : out std_logic_vector(31 downto 0);
		d_timeout_ack    : out std_logic;
		d_timeout_status : out std_logic_vector(7 downto 0);
		d_en_module      : out std_logic;
		d_timeout_cnt    : out std_logic_vector(31 downto 0);
		d_glitch_wait    : out std_logic_vector(31 downto 0);
		d_glitch_pattern : out std_logic_vector(63 downto 0);
		d_config_done    : out std_logic;
		-- Users to add ports here
		--trigger module     
		trigger_out      : out std_logic;
		trigger_osc      : out std_logic;
		dut_working      : in  std_logic;
		--timeout module
		snd_start        : in  STD_LOGIC;
		op_done          : in  std_logic;
		--reset module
		dut_rst          : out std_logic;
		ctrl_rst         : out std_logic;
		wait_for_rst     : out std_logic;
		rst_cmd          : out std_logic;
		--glitch module
		glitch_out       : out std_logic;
		--DUT specific ports
		fd2c_clk_O       : out std_logic; -- output value
		fd2c_clk_I       : in  std_logic; -- input clock
		fd2c_clk_D       : out std_logic; -- direction '1' if output, '0' if input
		clk_out          : out std_logic; -- clock from DUT
		en_serial        : out std_logic; -- enable serial communication
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Ports of Axi Slave Bus Interface S_AXI
		s_axi_aclk       : in  std_logic;
		s_axi_aresetn    : in  std_logic;
		s_axi_awaddr     : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_awprot     : in  std_logic_vector(2 downto 0);
		s_axi_awvalid    : in  std_logic;
		s_axi_awready    : out std_logic;
		s_axi_wdata      : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_wstrb      : in  std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
		s_axi_wvalid     : in  std_logic;
		s_axi_wready     : out std_logic;
		s_axi_bresp      : out std_logic_vector(1 downto 0);
		s_axi_bvalid     : out std_logic;
		s_axi_bready     : in  std_logic;
		s_axi_araddr     : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_arprot     : in  std_logic_vector(2 downto 0);
		s_axi_arvalid    : in  std_logic;
		s_axi_arready    : out std_logic;
		s_axi_rdata      : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_rresp      : out std_logic_vector(1 downto 0);
		s_axi_rvalid     : out std_logic;
		s_axi_rready     : in  std_logic
	);
end dut_controller_v1_0;

architecture arch_imp of dut_controller_v1_0 is

	-- component declaration
	component dut_controller_v1_0_S_AXI is
		generic(
			C_S_AXI_DATA_WIDTH : integer := 32;
			C_S_AXI_ADDR_WIDTH : integer := 7
		);
		port(
			S_AXI_ACLK     : in  std_logic;
			S_AXI_ARESETN  : in  std_logic;
			S_AXI_AWADDR   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
			S_AXI_AWPROT   : in  std_logic_vector(2 downto 0);
			S_AXI_AWVALID  : in  std_logic;
			S_AXI_AWREADY  : out std_logic;
			S_AXI_WDATA    : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
			S_AXI_WSTRB    : in  std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
			S_AXI_WVALID   : in  std_logic;
			S_AXI_WREADY   : out std_logic;
			S_AXI_BRESP    : out std_logic_vector(1 downto 0);
			S_AXI_BVALID   : out std_logic;
			S_AXI_BREADY   : in  std_logic;
			S_AXI_ARADDR   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
			S_AXI_ARPROT   : in  std_logic_vector(2 downto 0);
			S_AXI_ARVALID  : in  std_logic;
			S_AXI_ARREADY  : out std_logic;
			S_AXI_RDATA    : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
			S_AXI_RRESP    : out std_logic_vector(1 downto 0);
			S_AXI_RVALID   : out std_logic;
			S_AXI_RREADY   : in  std_logic;
			--user defined
			--trigger module
			trigger_length : out std_logic_vector(31 downto 0);
			trigger_wait   : out std_logic_vector(31 downto 0);
			trigger_mode   : out std_logic_vector(7 downto 0);
			--timeout module
			ack            : out std_logic; --ack from pc that it know timeout happend
			timeout        : out STD_LOGIC_VECTOR(31 downto 0);
			timeout_status : in  STD_LOGIC_VECTOR(7 downto 0);
			--reset module
			time_to_rst    : out std_logic_vector(31 downto 0);
			force_rst      : out std_logic;
			-- power glitch module
			glitch_pattern : out std_logic_vector(63 downto 0);
		    glitch_wait    : out std_logic_vector(31 downto 0);
		    config_done    : out std_logic;
		    --DUT specific ports
            dut_select     : out std_logic_vector(31 downto 0);
            working_count  : in  std_logic_vector(31 downto 0)
		);
	end component dut_controller_v1_0_S_AXI;
	---user defined 
	component trigger_module is
		port(
			clk            : in  std_logic;
			rst            : in  std_logic;
			dut_working    : in  std_logic;
			trigger_length : in  std_logic_vector(31 downto 0);
			trigger_wait   : in  std_logic_vector(31 downto 0);
			trigger_mode   : in  std_logic_vector(7 downto 0);
			trigger_out    : out std_logic;
			trigger_osc    : out std_logic
		);
	end component;

	component timeout_mod is
		port(clk           : in  STD_LOGIC;
		     rst           : in  STD_LOGIC;
		     snd_start     : in  STD_LOGIC;
		     op_done       : in  std_logic;
		     ack           : in  std_logic; --ack from pc that it know timeout happend
		     timeout       : in  STD_LOGIC_VECTOR(31 downto 0);
		     status        : out STD_LOGIC_VECTOR(7 downto 0);
		     d_en_module   : out std_logic;
		     d_timeout_cnt : out std_logic_vector(31 downto 0)
		    );
	end component;

	component rst_mod is
		port(clk          : in  STD_LOGIC;
		     rst          : in  STD_LOGIC;
		     dut_working  : in  STD_LOGIC;
		     time_to_rst  : in  std_logic_vector(31 downto 0);
		     dut_rst_cmd  : out STD_LOGIC;
		     wait_for_rst : out std_logic
		    );
	end component;
	
	component power_glitcher is
    port ( clk : in std_logic;
           rst : in std_logic;
           config_done : in std_logic;
           dut_working : in std_logic;
           glitch_pattern : in std_logic_vector(63 downto 0);
           glitch_wait : in std_logic_vector(31 downto 0); --wait befor sending glitch by this num of cycles
           glitch_out : out std_logic
         );
    end component;
    
    component dut_switch is 
    port (  fd2c_clk_O: out std_logic;
            fd2c_clk_I: in  std_logic;
            fd2c_clk_D: out std_logic;
            clk_out:    out std_logic;
            en_serial:  out std_logic;
            dut_rst:    in  std_logic;
            dut_select: in std_logic_vector(31 downto 0)
         );
    end component;

    component dut_working_counter is 
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           dut_working : in STD_LOGIC;
           working_count : out STD_LOGIC_VECTOR (31 downto 0)
           );
    end component;

	--signals for trigger module
	signal rst            : std_logic;
	signal trigger_length : std_logic_vector(31 downto 0);
	signal trigger_wait   : std_logic_vector(31 downto 0);
	signal trigger_mode   : std_logic_vector(7 downto 0);
	--timeout module
	signal ack            : std_logic;  --ack from pc that it know timeout happend
	signal timeout        : STD_LOGIC_VECTOR(31 downto 0);
	signal timeout_status : STD_LOGIC_VECTOR(7 downto 0);
	--reset module
	signal time_to_rst    : std_logic_vector(31 downto 0);
	signal force_rst      : std_logic;
	signal dut_rst_cmd    : std_logic;
	signal dut_reset      : std_logic;
	
	--power glitch module
	signal glitch_pattern : std_logic_vector(63 downto 0);
    signal glitch_wait    : std_logic_vector(31 downto 0);
	signal config_done    : std_logic;
	
    --DUT specific ports
    signal dut_select     :std_logic_vector(31 downto 0); 
    
    -- signals for DUT working counter
    signal working_count : std_logic_vector(31 downto 0);
    signal trigger       : std_logic;
    signal trigger_clk   : std_logic;

	---end user defined 

begin

	-- Instantiation of Axi Bus Interface S_AXI
	dut_controller_v1_0_S_AXI_inst : dut_controller_v1_0_S_AXI
		generic map(
			C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
		)
		port map(
			S_AXI_ACLK     => s_axi_aclk,
			S_AXI_ARESETN  => s_axi_aresetn,
			S_AXI_AWADDR   => s_axi_awaddr,
			S_AXI_AWPROT   => s_axi_awprot,
			S_AXI_AWVALID  => s_axi_awvalid,
			S_AXI_AWREADY  => s_axi_awready,
			S_AXI_WDATA    => s_axi_wdata,
			S_AXI_WSTRB    => s_axi_wstrb,
			S_AXI_WVALID   => s_axi_wvalid,
			S_AXI_WREADY   => s_axi_wready,
			S_AXI_BRESP    => s_axi_bresp,
			S_AXI_BVALID   => s_axi_bvalid,
			S_AXI_BREADY   => s_axi_bready,
			S_AXI_ARADDR   => s_axi_araddr,
			S_AXI_ARPROT   => s_axi_arprot,
			S_AXI_ARVALID  => s_axi_arvalid,
			S_AXI_ARREADY  => s_axi_arready,
			S_AXI_RDATA    => s_axi_rdata,
			S_AXI_RRESP    => s_axi_rresp,
			S_AXI_RVALID   => s_axi_rvalid,
			S_AXI_RREADY   => s_axi_rready,
			--user defined
			--trigger module
			trigger_length => trigger_length,
			trigger_wait   => trigger_wait,
			trigger_mode   => trigger_mode,
			---timeout module
			ack            => ack,
			timeout        => timeout,
			timeout_status => timeout_status,
			--reset module
			time_to_rst    => time_to_rst,
			force_rst      => force_rst,
			--glitch module
			glitch_pattern => glitch_pattern,
			glitch_wait    => glitch_wait,
			config_done    => config_done,
		    --DUT specific ports
            dut_select     => dut_select,
			working_count  => working_count
		);

	-- Add user logic here
	rst <= not s_axi_aresetn;
	trigmod : trigger_module
		port map(
			clk            => s_axi_aclk,
			rst            => rst,
			dut_working    => dut_working,
			trigger_length => trigger_length,
			trigger_wait   => trigger_wait,
			trigger_mode   => trigger_mode,
			trigger_out    => trigger,
			trigger_osc    => trigger_clk
		);
		
	trigger_out <= trigger;
	trigger_osc <= trigger_clk;
	
	timeoutmod : timeout_mod
		port map(
			clk           => s_axi_aclk,
			rst           => rst,
			snd_start     => snd_start,
			op_done       => op_done,
			ack           => ack,       --ack from pc that it know timeout happend
			timeout       => timeout,
			status        => timeout_status,
			d_en_module   => d_en_module,
			d_timeout_cnt => d_timeout_cnt
		);

	rstmod : rst_mod
		port map(
			clk          => s_axi_aclk,
			rst          => rst,
			dut_working  => dut_working,
			time_to_rst  => time_to_rst,
			dut_rst_cmd  => dut_rst_cmd,
			wait_for_rst => wait_for_rst
		);
	rst_cmd  <= dut_rst_cmd;
	dut_reset  <= dut_rst_cmd or force_rst;
	dut_rst <= dut_reset;
	ctrl_rst <= force_rst;

    power_glitch: power_glitcher
        port map ( 
            clk => s_axi_aclk,
            rst => rst,
            config_done => config_done,
            dut_working => dut_working,
            glitch_pattern => glitch_pattern,
            glitch_wait => glitch_wait,
            glitch_out => glitch_out
         );

	--debug only
	d_timeout        <= timeout;
	d_timeout_status <= timeout_status;
	d_timeout_ack    <= ack;
	d_glitch_wait <= glitch_wait;
	d_glitch_pattern <= glitch_pattern;
	d_config_done <= config_done;
	
	dutswitch: dut_switch
	    port map(
	       fd2c_clk_O => fd2c_clk_O,
	       fd2c_clk_I => fd2c_clk_I,
	       fd2c_clk_D => fd2c_clk_D,
	       clk_out    => clk_out,
	       en_serial  => en_serial,
	       dut_rst    => dut_reset,
	       dut_select => dut_select	       
	       );

	dutctr: dut_working_counter
	    port map(
	       clk => s_axi_aclk,
	       rst => rst,
	       dut_working    => dut_working,
	       working_count  => working_count      
	       );

	-- User logic ends

end arch_imp;
