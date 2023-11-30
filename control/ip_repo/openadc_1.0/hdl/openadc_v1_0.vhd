--#############################################################################
--#                                                                           #
--#   Copyright 2018-2023 Cryptographic Engineering Research Group (CERG)     #
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
-- Author: Matthew Carter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity openadc_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4;

		-- Parameters of Axi Master Bus Interface M_AXIS
		C_M_AXIS_TDATA_WIDTH	: integer	:= 64;
		C_M_AXIS_START_COUNT	: integer	:= 32;
		TEST_CAPTURE: boolean := false
	);
	port (
		-- Users to add ports here
        adc_clk_in : in STD_LOGIC;
        adc_data_lsb : in STD_LOGIC_VECTOR (5 downto 0) := "000000";
        adc_capture_test : in STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
        capture_en : in STD_LOGIC := '0';
        gain : out STD_LOGIC := '0';
        gain_mode : out STD_LOGIC := '0';
        adc_clk : out STD_LOGIC;
        adc_in : in STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
        adc_or: in std_logic;
        en_cntr : out STD_LOGIC;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S_AXI
		s_axi_aclk	: in std_logic;
		s_axi_aresetn	: in std_logic;
		s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;
		s_axi_wdata	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;
		s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;
		s_axi_rdata	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic;

		-- Ports of Axi Master Bus Interface M_AXIS
		m_axis_aclk	: in std_logic;
		m_axis_aresetn	: in std_logic;
		m_axis_tvalid	: out std_logic;
		m_axis_tdata	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		m_axis_tstrb	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m_axis_tlast	: out std_logic;
		m_axis_tready	: in std_logic
	);
end openadc_v1_0;

architecture arch_imp of openadc_v1_0 is

	-- component declaration
	component openadc_v1_0_S_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		ENABLE_CAPTURE : out std_logic;
		ADC_LSB_CONF : out std_logic_vector(5 downto 0);
        HI_LO : out std_logic;
        GAIN_DUTY_CYCLE : out std_logic_vector(7 downto 0);
        OVER_RANGE : in std_logic;
        BLOCK_SIZE : out std_logic_vector (9 downto 0);
        CAPTURE_MODE : out std_logic;
        RESET_TRANSMIT : out std_logic;
        CAPTURE_COUNT : out std_logic_vector(C_S_AXI_DATA_WIDTH-2 downto 0);
        CAPTURE_DIVISOR : out std_logic_vector(3 downto 0);
        CAPTURED_COUNT : in std_logic_vector(C_S_AXI_DATA_WIDTH-2 downto 0);
        CAPTURE_COMPLETE : in std_logic;
        CALC_MEAN : out std_logic;
        CAPTURE_DELAY : out std_logic_vector(C_S_AXI_DATA_WIDTH-5 downto 0);
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
	end component openadc_v1_0_S_AXI;

	component openadc_v1_0_M_AXIS is
		generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 64;
		C_M_START_COUNT	: integer	:= 32
		);
		port (
		START_TRANSMIT : in std_logic;
		ADC_DATA : in std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		TRANSMIT_DONE : out std_logic;
		BLOCK_SIZE_CONF : in std_logic_vector(9 downto 0);
		RESET_TRANSMIT : in std_logic;
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component openadc_v1_0_M_AXIS;
	
	-- internal signal for adc data
	signal adc_data : STD_LOGIC_VECTOR (15 downto 0);
	signal stream_data_out : STD_LOGIC_VECTOR (C_M_AXIS_TDATA_WIDTH-1 downto 0);
	signal adc_data_valid : std_logic;
	signal adc_data_ready : std_logic := '0';
	signal adc_data_transmit : std_logic := '0';
	signal adc_bit0 : STD_LOGIC;
    signal adc_bit1 : STD_LOGIC;
    signal adc_bit2 : STD_LOGIC;
    signal adc_bit3 : STD_LOGIC;
    signal adc_bit4 : STD_LOGIC;
    signal adc_bit5 : STD_LOGIC;
    signal adc_bit6 : STD_LOGIC;
    signal adc_bit7 : STD_LOGIC;
    signal adc_bit8 : STD_LOGIC;
    signal adc_bit9 : STD_LOGIC;
    signal adc_clk_out : STD_LOGIC;
    signal m_transmit_done : STD_LOGIC;
    signal stream_data_out_phase_1 : STD_LOGIC_VECTOR (15 downto 0);
    signal stream_data_out_phase_2 : STD_LOGIC_VECTOR (15 downto 0);
    signal stream_data_out_phase_3 : STD_LOGIC_VECTOR (15 downto 0);
    type state is ( PRE_CAPTURE, PRE_CONT_CAPTURE, PHASE_1,        -- This is the initial/idle state                    
                        PHASE_2, PHASE_3, PHASE_4, POST_CAPTURE);  -- In this state the
    signal  tx_state : state;
    signal last_state : state;
    signal enable_capture_conf : STD_LOGIC;
    signal enable_capture_in : STD_LOGIC;
    signal hi_lo_bit : STD_LOGIC;
    signal adc_lsb_conf : STD_LOGIC_VECTOR(5 downto 0);
    signal gain_duty_cycle_out : STD_LOGIC_VECTOR(7 downto 0);
	signal block_size_conf : STD_LOGIC_VECTOR(9 downto 0);
	-- Two supported capture modes, 0 = acquisition (capture count), 1 = o-scope (capture average based on divisor)
	signal capture_mode : STD_LOGIC;
	signal reset_tx : STD_LOGIC;
	signal capture_count : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-2 downto 0);
	signal capture_divisor : STD_LOGIC_VECTOR(3 downto 0);
	signal captured_count : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-2 downto 0);   
	
	constant max_capture_size : integer := (2 ** (C_S_AXI_DATA_WIDTH - 1))-1;
	signal capture_count_int : integer range 0 to max_capture_size;
	signal samples_captured : integer range 0 to 8388608 := 0;
	
	signal simple_counter : integer range 0 to max_capture_size := 0;
	signal block_counter : integer range 0 to max_capture_size := 0;
	signal capture_complete : STD_LOGIC := '0';
	signal acquisition_mode : STD_LOGIC := '0';
    signal continuous_mode : STD_LOGIC := '0';
    signal divisor_rdy : STD_LOGIC := '0';
    signal divisor_count : STD_LOGIC_VECTOR(3 downto 0);
    signal cur_divisor_count : integer range 0 to 32 := 0;
    signal divisor_total_count : integer range 0 to (2 ** (16))-1 := 0;
    signal divisor_total : STD_LOGIC_VECTOR(31 downto 0);
    signal calculate_mean : STD_LOGIC := '0';
    signal stop_shift : STD_LOGIC := '0';
    signal continuous_sample : STD_LOGIC_VECTOR (15 downto 0);
    signal mean_sample : STD_LOGIC_VECTOR (63 downto 0);
    signal previous_adc_data : STD_LOGIC_VECTOR (15 downto 0);
    signal previous_mean_sample : STD_LOGIC_VECTOR (63 downto 0);
    signal stop_shift_mean : STD_LOGIC := '0';
    signal cur_shift_count : integer range 0 to (2 ** (16))-1 := 0;
    signal PWM_Accumulator : std_logic_vector(8 downto 0) := "000000000";
    signal pwm_gain : std_logic_vector(7 downto 0);
    signal alternate_count : std_logic := '0';
    signal count_incremented_flag : std_logic := '0';
    signal capt_delay : std_logic_vector(27 downto 0) := "0000000000000000000000000000";
    signal delay_count : integer range 0 to (2 ** (28))-1 := 0;
    signal complete_capture_delay : std_logic := '0'; 

begin

-- Instantiation of Axi Bus Interface S_AXI
openadc_v1_0_S_AXI_inst : openadc_v1_0_S_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_AXI_ADDR_WIDTH
	)
	port map (
	    ENABLE_CAPTURE => enable_capture_conf,
	    ADC_LSB_CONF => adc_lsb_conf,
	    HI_LO => hi_lo_bit,
	    GAIN_DUTY_CYCLE => gain_duty_cycle_out,
	    OVER_RANGE => adc_or,
	    BLOCK_SIZE => block_size_conf,
	    CAPTURE_MODE => capture_mode,
	    RESET_TRANSMIT => reset_tx,
	    CAPTURE_COUNT => capture_count,
	    CAPTURE_DIVISOR => capture_divisor,
	    CAPTURED_COUNT => captured_count,
	    CAPTURE_COMPLETE => capture_complete,
	    CALC_MEAN => calculate_mean,
	    CAPTURE_DELAY => capt_delay,
		S_AXI_ACLK	=> s_axi_aclk,
		S_AXI_ARESETN	=> s_axi_aresetn,
		S_AXI_AWADDR	=> s_axi_awaddr,
		S_AXI_AWPROT	=> s_axi_awprot,
		S_AXI_AWVALID	=> s_axi_awvalid,
		S_AXI_AWREADY	=> s_axi_awready,
		S_AXI_WDATA	=> s_axi_wdata,
		S_AXI_WSTRB	=> s_axi_wstrb,
		S_AXI_WVALID	=> s_axi_wvalid,
		S_AXI_WREADY	=> s_axi_wready,
		S_AXI_BRESP	=> s_axi_bresp,
		S_AXI_BVALID	=> s_axi_bvalid,
		S_AXI_BREADY	=> s_axi_bready,
		S_AXI_ARADDR	=> s_axi_araddr,
		S_AXI_ARPROT	=> s_axi_arprot,
		S_AXI_ARVALID	=> s_axi_arvalid,
		S_AXI_ARREADY	=> s_axi_arready,
		S_AXI_RDATA	=> s_axi_rdata,
		S_AXI_RRESP	=> s_axi_rresp,
		S_AXI_RVALID	=> s_axi_rvalid,
		S_AXI_RREADY	=> s_axi_rready
	);

-- Instantiation of Axi Bus Interface M_AXIS
openadc_v1_0_M_AXIS_inst : openadc_v1_0_M_AXIS
	generic map (
		C_M_AXIS_TDATA_WIDTH	=> C_M_AXIS_TDATA_WIDTH,
		C_M_START_COUNT	=> C_M_AXIS_START_COUNT
	)
	port map (
        START_TRANSMIT => adc_data_valid,
        ADC_DATA => stream_data_out,
        TRANSMIT_DONE => m_transmit_done,
        BLOCK_SIZE_CONF => block_size_conf,
        RESET_TRANSMIT => reset_tx,
		M_AXIS_ACLK	=> m_axis_aclk,
		M_AXIS_ARESETN	=> m_axis_aresetn,
		M_AXIS_TVALID	=> m_axis_tvalid,
		M_AXIS_TDATA	=> m_axis_tdata,
		M_AXIS_TSTRB	=> m_axis_tstrb,
		M_AXIS_TLAST	=> m_axis_tlast,
		M_AXIS_TREADY	=> m_axis_tready
	);

	-- Add user logic here
	
	adc_test_capture: if TEST_CAPTURE generate
        adc_data <= adc_capture_test & "000000";
    end generate;
    
    adc_operational: if not TEST_CAPTURE generate
        --adc_data <= adc_in & (adc_data_lsb OR adc_lsb_conf);
        adc_data <= "000000" & adc_in; --changed to avoid masking in software
    end generate;
    
    --enable_capture_in <= enable_capture_conf OR capture_en;
    enable_capture_in <= enable_capture_conf AND capture_en;
    
    capture_count_int <= to_integer(unsigned(capture_count));
    divisor_count <= capture_divisor;
    pwm_gain <= gain_duty_cycle_out;
	
	-- Assign adc clock
	adc_clk_out <= adc_clk_in;
	adc_clk <= adc_clk_out;
	adc_data_valid <= '1' when ((adc_data_ready = '1') and (adc_data_transmit = '1')) else '0';
	
	en_cntr <= enable_capture_in;
	complete_capture_delay <= '1' when (to_integer(unsigned(capt_delay)) = delay_count) else '0';
	
	process(adc_clk_in)
	begin
        if (falling_edge (adc_clk_in)) then
         if (reset_tx = '1') then
           delay_count <= 0;
         end if;
         if (enable_capture_in = '1' and to_integer(unsigned(capt_delay)) > delay_count) then
           delay_count <= delay_count + 1; 
         end if;
        end if;
	end process;
     
     -- State machine for sending to Master AXI-Stream Module   
     process(adc_clk_in)                                                          
         begin                                                                         
           if (falling_edge (adc_clk_in)) then
             if (reset_tx = '1') then
               samples_captured <= 0;
               tx_state <= PRE_CAPTURE;
             end if;
             -- Handles send when in acqusition mode
             if (acquisition_mode = '1') then                                     
               case (tx_state) is
                 when PRE_CAPTURE        =>
                   if (enable_capture_in = '1' and capture_complete = '0') then
                     stream_data_out_phase_1 <= adc_data;                                                      
                     tx_state <= PHASE_2;
                     adc_data_ready <= '0';
                   end if;
                 when PHASE_1     =>                                                                    
                   stream_data_out_phase_1 <= adc_data;                                                      
                   tx_state <= PHASE_2;
                   adc_data_ready <= '0';                                                                                                                                                                                                              
                 when PHASE_2  =>                                                                                                                         
                   stream_data_out_phase_2 <= adc_data;                                                      
                   tx_state <= PHASE_3;
                 when PHASE_3  =>
                   stream_data_out_phase_3 <= adc_data;
                   tx_state <= PHASE_4;
                 when PHASE_4 =>
                    --Changed to avoid reordring in software
                   --stream_data_out(63 downto 48) <= stream_data_out_phase_1;
                   --stream_data_out(47 downto 32) <= stream_data_out_phase_2; 
                   --stream_data_out(31 downto 16) <= stream_data_out_phase_3;                 
                   --stream_data_out(15 downto 0) <= adc_data;
                    stream_data_out(63 downto 48) <= adc_data;
                    stream_data_out(47 downto 32) <= stream_data_out_phase_3; 
                    stream_data_out(31 downto 16) <= stream_data_out_phase_2;                 
                    stream_data_out(15 downto 0)  <= stream_data_out_phase_1;
                   samples_captured <= samples_captured + 1;
                   adc_data_ready <= '1';
                   if (capture_complete = '1') then
                     tx_state <= PRE_CAPTURE;
                   else
                     tx_state <= PHASE_1;
                   end if;                                                                       
                 when others    => 
                   tx_state <= PHASE_1;
               end case;
             -- handles send when in continuous mode   
             elsif (continuous_mode = '1') then
               case (tx_state) is
                 when PRE_CAPTURE        =>
                   if (enable_capture_in = '1' and capture_complete = '0') then
                     if (divisor_rdy = '1') then                                                       
                       tx_state <= PHASE_1;
                     end if;
                     adc_data_ready <= '0';
                   end if;
                 when PRE_CONT_CAPTURE     =>
                   if (divisor_rdy = '1') then
                     --stream_data_out_phase_1 <= continuous_sample; 
                     tx_state <= PHASE_1;
                   end if;
                 when PHASE_1     => 
                   if (divisor_rdy = '1') then                                                                 
                     stream_data_out_phase_1 <= continuous_sample;                                                      
                     tx_state <= PHASE_2;
                   end if;
                   adc_data_ready <= '0';                                                                                                                                                                                                              
                 when PHASE_2  =>
                   if (divisor_rdy = '1') then                                                                                                                           
                     stream_data_out_phase_2 <= continuous_sample;                                                      
                     tx_state <= PHASE_3;
                   end if;
                 when PHASE_3  =>
                   if (divisor_rdy = '1') then
                     stream_data_out_phase_3 <= continuous_sample;
                     tx_state <= PHASE_4;
                   end if;
                 when PHASE_4 =>
                   if (divisor_rdy = '1') then
                     stream_data_out(63 downto 48) <= stream_data_out_phase_1;
                     stream_data_out(47 downto 32) <= stream_data_out_phase_2; 
                     stream_data_out(31 downto 16) <= stream_data_out_phase_3;                 
                     stream_data_out(15 downto 0) <= continuous_sample;
                     samples_captured <= samples_captured + 1;
                     adc_data_ready <= '1';
                     if (capture_complete = '1') then
                       tx_state <= PRE_CAPTURE;
                     else
                       tx_state <= PHASE_1;
                     end if;
                   end if;                                                                       
                 when others    => 
                   tx_state <= PHASE_1;
               end case;
             end if;                                                                 
            end if;                                                                    
          end process;
          
          -- Handles number of blocks to capture
          process(adc_clk_in, reset_tx)
          begin
          if (rising_edge (adc_clk_in)) then
            if (reset_tx = '1') then
               capture_complete <= '0';
               simple_counter <= 0;
               block_counter <= 0;
               count_incremented_flag <= '0';
               --captured_count <= (others => '0');
            end if;
            -- Track samples prior to PHASE_4 to avoid race condition          
            if (tx_state = PHASE_2 and count_incremented_flag = '0') then
              count_incremented_flag <= '1';
              simple_counter <= simple_counter + 1;
              if (simple_counter = to_integer(unsigned(block_size_conf))) then
                simple_counter <= 0;
                block_counter <= block_counter + 1;
              end if;
            elsif (tx_state = PHASE_3) then
              count_incremented_flag <= '0';
            end if;
            captured_count <= std_logic_vector(to_unsigned(block_counter, captured_count'length) );
            
            if (block_counter >= capture_count_int) then
              capture_complete <= '1';
            end if;
          end if;
          end process;
          
          -- Handles divisor value when in continuous mode
          process(adc_clk_in, reset_tx, tx_state)
          begin
          --if (tx_state /= last_state) then
          --  divisor_rdy <= '0';
          --end if;
          --last_state <= tx_state;
          if (rising_edge (adc_clk_in)) then
            if (reset_tx = '1') then
              divisor_rdy <= '0';
              stop_shift <= '0';
              divisor_total <= "00000000000000000000000000000001";
              divisor_total_count <= 1;
              cur_divisor_count <= 0;
              stop_shift_mean <= '0';
              cur_shift_count <= 0;
              mean_sample <= (others => '0');
            end if;
              
              if (enable_capture_in = '1') then             
                -- Should happen once per reset
                if (stop_shift = '0') then      
                  if (cur_divisor_count = to_integer(unsigned(divisor_count))) then
                    stop_shift <= '1';
                  else
                    cur_divisor_count <= cur_divisor_count + 1;
                    divisor_total <= divisor_total(30 downto 0) & '0';
                  end if;
                end if;
                
                -- Shift 
                if (stop_shift_mean = '0') then      
                  if (cur_shift_count = to_integer(unsigned(divisor_count))) then
                    stop_shift_mean <= '1';
                  else
                    cur_shift_count <= cur_shift_count + 1;
                     previous_mean_sample <= '0' & previous_mean_sample(63 downto 1);
                  end if;
                end if;
                if (stop_shift = '1' and to_integer(unsigned(divisor_total)) = divisor_total_count) then
                  if (calculate_mean = '0') then
                    continuous_sample <= previous_adc_data;
                  else 
                    continuous_sample <= previous_mean_sample(15 downto 0);
                  end if;
                  previous_adc_data <= adc_data;
                  previous_mean_sample <= std_logic_vector(unsigned(mean_sample) + unsigned("000000000000000000000000000000000000000000000000" & adc_data));
                  stop_shift_mean <= '0';
                  cur_shift_count <= 0;
                  divisor_rdy <= '1';
                  divisor_total_count <= 1;
                  mean_sample <= (others => '0');
                else
                  divisor_rdy <= '0';
                  divisor_total_count <= divisor_total_count + 1;
                  -- Accumulate all values from the adc
                  mean_sample <= std_logic_vector(unsigned(mean_sample) + unsigned("000000000000000000000000000000000000000000000000" & adc_data));                          
                end if;
              end if;
          end if;
          end process;
          
          
     
     -- If Master AXIS has begun sending ADC value, then stop signalling to send again     
     process(m_transmit_done, adc_data_ready)                                                          
     begin                                                                         
       if (m_transmit_done = '1') then                                         
         adc_data_transmit <= '0';
       elsif (rising_edge(adc_data_ready)) then
         adc_data_transmit <= '1';                                                                
       end if;                                                                    
     end process;
           
     process(adc_clk_in, reset_tx)
     begin
       if (rising_edge (adc_clk_in)) then
         if (reset_tx = '1') then
           acquisition_mode <= '0';
           continuous_mode <= '0';
         end if;
           
         if (capture_mode = '0') then
           acquisition_mode <= '1';
           continuous_mode <= '0';
         elsif (capture_mode = '1') then
           continuous_mode <= '1';
           acquisition_mode <= '0';
         end if;   
       end if;
     end process; 
     
     
     process (s_axi_aclk)
     begin
         if rising_edge(s_axi_aclk) then
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
     gain_mode <= hi_lo_bit;

end arch_imp;
