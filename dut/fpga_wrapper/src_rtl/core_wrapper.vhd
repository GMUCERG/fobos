--##############################################################################
--#                                                                            #
--#Copyright 2018-2023 Cryptographic Engineering Research Group (CERG)         #
--#George Mason University                                                     #
--#   http://cryptography.gmu.edu/fobos                                        #                            
--#                                                                            #
--#Licensed under the Apache License, Version 2.0 (the "License");             #
--#you may not use this file except in compliance with the License.            #
--#You may obtain a copy of the License at                                     #
--#                                                                            #
--#    http://www.apache.org/licenses/LICENSE-2.0                              #
--#                                                                            #
--#Unless required by applicable law or agreed to in writing, software         #
--#distributed under the License is distributed on an "AS IS" BASIS,           #
--#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
--#See the License for the specific language governing permissions and         #
--#limitations under the License.                                              #
--#                                                                            #
--##############################################################################

-- v5 is prototype that supports N = 4
-- FOBOS_DUT(din) and FOBOS_DUT(dout) are 4 bit interfaces
-- W and SW are independently any multiple of 4
-- Supports pdi, sdi, rdi
-- Reinit fifo not supported
-- Only interface width (N=4) supported

--! Caution: W = 8, 16, 32, 64, 128 supported in prototype; DO FIFO must be modified for other cases

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;  
use ieee.numeric_std.ALL;

use work.core_wrapper_pkg.all;

entity core_wrapper is
port(
    clk             : in std_logic;
    rst             : in std_logic;
    di_valid        : in std_logic;
    di_ready        : out std_logic;
    din             : in std_logic_vector(3 downto 0);
    do_valid        : out std_logic;
    do_ready        : in std_logic;
    dout            : out std_logic_vector(3 downto 0);
    status          : out std_logic --report error e.g. via LED
);

end core_wrapper;

architecture behav of core_wrapper is

    type state_type is (CLR, INST0, INST1, INST2, INST3, PARAM0, PARAM1, 
                        PARAM2, PARAM3, LOAD_FIFO, RUN, UNLOAD, 
                        GEN_RAND, CONF_PRNG, SND_ACK, DELAY, INVALID_INST);
    signal state_r, nx_state : state_type;
    signal cnt_r, nx_cnt : unsigned(15 downto 0);

    signal ins_reg0_en, ins_reg1_en, ins_reg2_en, ins_reg3_en : std_logic;
    signal param_reg0_en, param_reg1_en, param_reg2_en, param_reg3_en : std_logic;

    signal ins_reg0_r, ins_reg1_r, ins_reg2_r, ins_reg3_r : std_logic_vector(3 downto 0);
    signal param_reg0_r, param_reg1_r, param_reg2_r, param_reg3_r : std_logic_vector(3 downto 0);

    signal write_fifo : std_logic;
    signal write_reg : std_logic;
    signal fifo_rst : std_logic;
    signal reg_rst : std_logic;
    -- sipo signals
    signal sipo0_di_valid, sipo1_di_valid : std_logic;
    signal sipo0_di_ready, sipo1_di_ready : std_logic;

    signal sipo0_do_valid, sipo1_do_valid : std_logic;
    signal sipo0_do_ready, sipo1_do_ready : std_logic;

    signal sipo0_dout : std_logic_vector(FIFO_0_WIDTH-1 downto 0);
    signal sipo1_dout : std_logic_vector(FIFO_1_WIDTH-1 downto 0);

    -- fifo signals
    signal fifo0_do_valid, fifo1_do_valid : std_logic;
    signal fifo0_do_ready, fifo1_do_ready : std_logic;
    signal out_fifo_do_valid, out_fifo_do_ready : std_logic;
    
    signal fifo0_dout : std_logic_vector(FIFO_0_WIDTH-1 downto 0);
    signal fifo1_dout : std_logic_vector(FIFO_1_WIDTH-1 downto 0);
    signal out_fifo_dout : std_logic_vector(FIFO_OUT_WIDTH-1 downto 0);

    -- piso signals
    signal out_piso_do_valid : std_logic;
    signal out_piso_do_ready : std_logic;
    signal out_piso_dout : std_logic_vector(4-1 downto 0);

    -- configuration registers
    signal conf_reg0_r, conf_reg1_r, conf_reg2_r, conf_reg3_r, conf_reg4_r, 
           conf_reg5_r, conf_reg6_r, conf_reg7_r : std_logic_vector(15 downto 0);

    -- crypto signals
    signal crypto_di0_valid, crypto_di1_valid : std_logic;
    signal crypto_di0_ready, crypto_di1_ready : std_logic;
    signal crypto_di0_data : std_logic_vector(FIFO_0_WIDTH-1 downto 0);
    signal crypto_di1_data : std_logic_vector(FIFO_1_WIDTH-1 downto 0);

    signal crypto_do_valid, crypto_do_ready : std_logic;
    signal crypto_do_data : std_logic_vector(FIFO_OUT_WIDTH-1 downto 0);

    -- crypto rdi signals
    signal crypto_rdi_data : std_logic_vector(FIFO_RDI_WIDTH-1 downto 0);
    signal crypto_rdi_valid, crypto_rdi_ready : std_logic;

    -- cmd
    signal opcode : std_logic_vector(3 downto 0);
    signal dest_sel : std_logic_vector(3 downto 0);
    signal word_cnt : std_logic_vector(16 downto 0); -- in 4-bit words
    signal cmd : std_logic_vector(4-1 downto 0);

    signal param : std_logic_vector(15 downto 0);
    signal clr_cmd_reg : std_logic;
    signal crypto_input_en : std_logic;
    signal outlen : std_logic_vector(16-1 downto 0); -- expected outlen in bytes
    
    -- randomness generation
    signal rand_requested_r, nx_rand_requested : std_logic;
    signal rand_generated_r, nx_rand_generated : std_logic;
    signal prng_seeded_r, nx_prng_seeded : std_logic;
    signal rand_words_r, nx_rand_words : std_logic_vector(16-1 downto 0);
    signal rand_cnt_r, nx_rand_cnt : std_logic_vector(16-1 downto 0);
    
    signal prng_en : std_logic;
    signal prng_reseed : std_logic;
    signal prng_seed : std_logic_vector(128-1 downto 0);
    signal prng_rdi_data : std_logic_vector(64-1 downto 0);
    signal prng_rdi_valid, prng_rdi_ready : std_logic;
    -- 
    signal rnd_piso_do_valid, rnd_piso_do_ready : std_logic;
    signal rnd_piso_do_data : std_logic_vector(31 downto 0);

    signal rnd_sipo_do_valid, rnd_sipo_do_ready : std_logic;
    signal rnd_sipo_do_data : std_logic_vector(FIFO_RDI_WIDTH-1 downto 0);

    signal rdi_fifo_do_valid, rdi_fifo_do_ready : std_logic;
    signal rdi_fifo_dout : std_logic_vector(FIFO_RDI_WIDTH-1 downto 0);
    --
    signal sel_out : std_logic;
    signal ctrl_status : std_logic_vector(4-1 downto 0);
    -- contsants
    constant CMD_START      : std_logic_vector(3 downto 0) := x"1";
    constant CMD_GEN_RAND   : std_logic_vector(3 downto 0) := x"2";
    
    --
    COMPONENT ila_0
    PORT (
	   clk : IN STD_LOGIC;
	   probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	   probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	   probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	   probe3 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
	   probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	   probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	   probe6 : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
    END COMPONENT  ;
    
    attribute mark_debug : string;
    attribute mark_debug of di_valid : signal is "true";
    attribute mark_debug of di_ready : signal is "true";
    attribute mark_debug of din : signal is "true";
    attribute mark_debug of do_valid : signal is "true";
    attribute mark_debug of do_ready : signal is "true";
    attribute mark_debug of dout : signal is "true";
    attribute mark_debug of rst: signal is "true";

begin
    -- BEGING USER CRYPTO  =============================================================================
    -- Instantiate your core here
    crypto_core : entity work.aes_axi(behav)
    port map(
    	clk         => clk,
    	rst         => not crypto_input_en,
        -- data signals
    	pdi_data    => crypto_di0_data,
    	pdi_valid   => crypto_di0_valid,
    	pdi_ready   => crypto_di0_ready,

        sdi_data    => crypto_di1_data,
    	sdi_valid   => crypto_di1_valid,
    	sdi_ready   => crypto_di1_ready,

    	do_data     => crypto_do_data,
    	do_ready    => crypto_do_ready,
    	do_valid    => crypto_do_valid

        --! if rdi_interface for side-channel protected versions is required, uncomment the rdi interface
        -- ,rdi_data => crypto_rdi_data,
        -- rdi_ready => crypto_rdi_ready,
        -- rdi_valid => crypto_rdi_valid
    );
    -- END USER CRYPTO
    --=============================================
    -- allow data into crypto core only when crypto_input_en is asserted
    crypto_di0_valid <= fifo0_do_valid and crypto_input_en;
    crypto_di1_valid <= fifo1_do_valid and crypto_input_en;

    fifo0_do_ready <= crypto_di0_ready and crypto_input_en;
    fifo1_do_ready <= crypto_di1_ready and crypto_input_en;

    crypto_di0_data <= fifo0_dout;
    crypto_di1_data <= fifo1_dout;

    crypto_rdi_valid <= rdi_fifo_do_valid and crypto_input_en;
    rdi_fifo_do_ready <= crypto_rdi_ready and crypto_input_en;
    crypto_rdi_data <= rdi_fifo_dout;
      
    --=========================================================================================
    opcode          <= ins_reg2_r;
    dest_sel        <= ins_reg3_r;
    word_cnt        <= param_reg0_r & param_reg1_r & param_reg2_r & param_reg3_r & "0";
    param           <= param_reg0_r & param_reg1_r & param_reg2_r & din;
    outlen          <= conf_reg1_r;
    cmd             <= conf_reg0_r(3 downto 0);

    prng_seed       <= 0x"01234567_01234567_01234567_01234567";
    --==========================================================================================
    
    -- in fifo0 and sipo ==============================
    sipo0 : entity work.dut_sipo(behav)
    generic map(
        WI => 4,
        WO => FIFO_0_WIDTH
    )
    port map(
        clk       => clk,
        rst       => fifo_rst,
        di_valid  => sipo0_di_valid,
        di_ready  => sipo0_di_ready,
        din	      => din,
        do_valid  => sipo0_do_valid,
        do_ready  => sipo0_do_ready,
        dout      => sipo0_dout
    );

    fifo0 : entity work.dut_fwft_fifo(behav)
    generic map(
        G_W => FIFO_0_WIDTH,
        G_LOG2DEPTH => FIFO_0_LOG2DEPTH
    )
    port map(
        clk         => clk,
        rst         => fifo_rst,
        din_valid   => sipo0_do_valid,
        din_ready   => sipo0_do_ready,
        din	        => sipo0_dout,
        dout_valid  => fifo0_do_valid,
        dout_ready  => fifo0_do_ready,
        dout        => fifo0_dout
    );
    
    -- in fifo1 and sipo ==============================
    sipo1 : entity work.dut_sipo(behav)
    generic map(
        WI => 4,
        WO => FIFO_1_WIDTH
    )
    port map(
        clk       => clk,
        rst       => fifo_rst,
        di_valid  => sipo1_di_valid,
        di_ready  => sipo1_di_ready,
        din	      => din,
        do_valid  => sipo1_do_valid,
        do_ready  => sipo1_do_ready,
        dout      => sipo1_dout
    );
   
    fifo1 : entity work.dut_fwft_fifo(behav)
    generic map(
        G_W => FIFO_1_WIDTH,
        G_LOG2DEPTH => FIFO_1_LOG2DEPTH
    )
    port map(
        clk         => clk,
        rst         => fifo_rst,
        din_valid   => sipo1_do_valid,
        din_ready   => sipo1_do_ready,
        din	        => sipo1_dout,
        dout_valid  => fifo1_do_valid,
        dout_ready  => fifo1_do_ready,
        dout        => fifo1_dout
    );

    --==============================================
    out_fifo : entity work.dut_fwft_fifo(behav)
    generic map(
        G_W => FIFO_OUT_WIDTH,
        G_LOG2DEPTH => FIFO_OUT_LOG2DEPTH
    )
    port map(
        clk         => clk,
        rst         => fifo_rst,
        din_valid   => crypto_do_valid,
        din_ready   => crypto_do_ready,
        din	        => crypto_do_data,
        dout_valid  => out_fifo_do_valid,
        dout_ready  => out_fifo_do_ready,
        dout        => out_fifo_dout
    );

    out_piso : entity work.dut_piso(behav) --WANING is output stage leaking when we get data into 4 bits? Block input to piso untill done
    generic map(
        WI => FIFO_OUT_WIDTH,
        WO => 4
    )
    port map(
        clk       => clk,
        rst       => fifo_rst,
        di_valid  => out_fifo_do_valid,
        di_ready  => out_fifo_do_ready,
        din	      => out_fifo_dout,
        do_valid  => out_piso_do_valid,
        do_ready  => out_piso_do_ready,
        dout      => out_piso_dout
    );

    dout <= ctrl_status when sel_out = '1' else out_piso_dout;
    --==============================================
    comb : process(all) begin
        --default values
        di_ready <= '0';
        do_valid <= '0';
        --
        ins_reg0_en <= '0';
        ins_reg1_en <= '0';
        ins_reg2_en <= '0';
        ins_reg3_en <= '0';
        param_reg0_en <= '0';
        param_reg1_en <= '0';
        param_reg2_en <= '0';
        param_reg3_en <= '0';
        write_fifo <= '0';
        write_reg <= '0';
        fifo_rst <= '0';
        reg_rst <= '0';
        clr_cmd_reg <= '0';
        crypto_input_en <= '0';
        out_piso_do_ready <= '0';
        --
        sel_out <= '0'; --select output from ctrl (to send status)
        ctrl_status <= (others=>'0');
        status <= '0';
        --prng
        prng_en <= '0';
        prng_reseed <= '0';

        --
        nx_state <= state_r;
        nx_cnt <= cnt_r;
        nx_rand_requested <= rand_requested_r;
        nx_prng_seeded <= prng_seeded_r;
        nx_rand_generated <= rand_generated_r;
        nx_rand_words <= rand_words_r;
        nx_rand_cnt <= rand_cnt_r;

        case (state_r) is
            when CONF_PRNG =>
                prng_en <= '1';
                prng_reseed <= '1';
                nx_prng_seeded <= '1';
                nx_state <= CLR;
            when CLR =>
                fifo_rst <= '1';
                clr_cmd_reg <= '1';
                nx_cnt <= (others=>'0');
                if RAND_WORDS = 0 then
                    nx_state <= INST0;
                else
                    nx_state <= GEN_RAND;
                end if;

            when INST0 =>
                if  cmd = CMD_GEN_RAND then
                    clr_cmd_reg <= '1';
                    nx_rand_requested <= '1';
                    nx_rand_words <= conf_reg2_r;
                    nx_state <= DELAY;
                elsif cmd = CMD_START then -- start cmd
                    clr_cmd_reg <= '1';
                    nx_state <= RUN;
                else
                    di_ready <= '1';
                    if di_valid = '1' then
                        ins_reg0_en <= '1';
                        nx_state <= INST1;
                    end if;
                    nx_cnt <= (others=>'0');
                end if;

            when INST1 =>
                di_ready <= '1';
                if di_valid = '1' then
                    ins_reg1_en <= '1';
                    nx_state <= INST2;
                end if;

            when INST2 =>
                di_ready <= '1';
                if di_valid = '1' then
                    ins_reg2_en <= '1';
                    nx_state <= INST3;
                end if;

            when INST3 =>
                di_ready <= '1';
                if di_valid = '1' then
                    ins_reg3_en <= '1';
                    nx_state <= PARAM0;
                end if;

            when PARAM0 =>
                di_ready <= '1';
                if di_valid = '1' then
                    param_reg0_en <= '1';
                    nx_state <= PARAM1;
                end if;

            when PARAM1 =>
                di_ready <= '1';
                if di_valid = '1' then
                    param_reg1_en <= '1';
                    nx_state <= PARAM2;
                end if;

            when PARAM2 =>
                di_ready <= '1';
                if di_valid = '1' then
                    param_reg2_en <= '1';
                    nx_state <= PARAM3;
                end if;

            when PARAM3 =>
                di_ready <= '1';
                if di_valid = '1' then
                    param_reg3_en <= '1';
                    case (opcode) is
                        when x"C" =>
                            nx_state <= LOAD_FIFO;
                        when x"8" =>
                            write_reg <= '1';
                            nx_state <= INST0;
                        when x"0" =>
                            nx_state <= INST0; -- NOOP
                        when others =>
                            nx_state <= INVALID_INST;
                    
                    end case;
                end if;

            when LOAD_FIFO =>
                di_ready <= '1';
                if di_valid = '1' then
                    if cnt_r = unsigned(word_cnt) then
                        nx_cnt <= (others=>'0');
                        ins_reg0_en <= '1';
                        nx_state <= INST1;
                    else
                        write_fifo <= '1';
                        nx_cnt <= cnt_r + 1;
                        nx_state <= LOAD_FIFO;
                    end if;
                end if;
            
            when RUN =>
                crypto_input_en <= '1';
                if crypto_do_valid = '1' and crypto_do_ready = '1' then
                    if cnt_r * (FIFO_OUT_WIDTH/8)  =  unsigned(outlen) - FIFO_OUT_WIDTH/8 then
                        nx_cnt <= (others=>'0');
                        nx_state <= UNLOAD;
                    else
                        nx_cnt <= cnt_r + 1;
                        nx_state <= RUN;
                    end if;
                end if;

            when UNLOAD =>
                do_valid <= out_piso_do_valid;
                if do_ready = '1' and out_piso_do_valid = '1' then
                    out_piso_do_ready <= '1';
                    if cnt_r = unsigned(outlen & "0") - 1  then --count nibbles
                        nx_cnt <= (others=>'0');
                        nx_state <= CLR;
                    else
                        nx_cnt <= cnt_r + 1;
                        nx_state <= UNLOAD;
                    end if;
                end if;

            when DELAY =>
                if cnt_r = 16-1 then -- 32-bit status
                    nx_cnt <= (others=>'0');
                    nx_state <= SND_ACK;
                else
                    nx_cnt <= cnt_r + 1;
                    nx_state <= DELAY;
                end if;
            
            when SND_ACK =>
                sel_out <= '1';
                do_valid <= '1';
                ctrl_status <= x"A";
                if do_ready = '1' then
                    if cnt_r = 8-1 then -- 32-bit status
                        nx_cnt <= (others=>'0');
                        nx_state <= GEN_RAND;
                    else
                        nx_cnt <= cnt_r + 1;
                        nx_state <= SND_ACK;
                    end if;
                end if;
                
            when GEN_RAND =>
                prng_en <= '1';
                if rnd_sipo_do_valid = '1' and rnd_sipo_do_ready = '1' then
                    if rand_cnt_r = RAND_WORDS -1 then
                        nx_rand_cnt <= (others=>'0');
                        nx_rand_generated <= '1';
                        nx_state <= INST0;
                    else    
                        nx_rand_cnt <= rand_cnt_r + 1;
                    end if;
                end if;           
                
            when INVALID_INST => 
                    status <= '1';
                    nx_state <= INVALID_INST; --hang wait for user reset

            when others=>
                nx_state <= INST0;
        end case;

    end process;

    reg : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_r <= CONF_PRNG;
                cnt_r <= (others=>'0');
                rand_requested_r <= '0';
                rand_generated_r <= '0';
                prng_seeded_r <= '0';
                rand_words_r <= (others=>'0');
                rand_cnt_r <= (others=>'0');
            else
                state_r <= nx_state;
                cnt_r <= nx_cnt;
                rand_requested_r <= nx_rand_requested;
                rand_generated_r <= nx_rand_generated;
                prng_seeded_r <= nx_prng_seeded;
                rand_words_r <= nx_rand_words;
                rand_cnt_r <= nx_rand_cnt;
            end if;
            
            if ins_reg0_en = '1' then
                ins_reg0_r <= din;
            end if;

            if ins_reg1_en = '1' then
                ins_reg1_r <= din;
            end if;

            if ins_reg2_en = '1' then
                ins_reg2_r <= din;
            end if;

            if ins_reg3_en = '1' then
                ins_reg3_r <= din;
            end if;

            if param_reg0_en = '1' then
                param_reg0_r <= din;
            end if;

            if param_reg1_en = '1' then
                param_reg1_r <= din;
            end if;

            if param_reg2_en = '1' then
                param_reg2_r <= din;
            end if;

            if param_reg3_en = '1' then
                param_reg3_r <= din;
            end if;

        end if;
    end process;

    decoder : process (all)
    begin
        sipo0_di_valid <= '0';
        sipo1_di_valid <= '0';
        if write_fifo = '1' then
            case (dest_sel) is
                when x"0" =>
                    sipo0_di_valid <= '1';
                when x"1" =>
                    sipo1_di_valid <= '1';
                when others =>
                    null;
            end case;
        end if;
        
    end process;

    -- registers
    cmd_reg : process (clk)
    begin
        if rising_edge(clk) then
            if clr_cmd_reg = '1' then
                conf_reg0_r <= (others=>'0');
            else
                if  write_reg = '1' and dest_sel = x"0" then
                    conf_reg0_r <= param;
                end if;
            end if;
        end if;
    end process;

    conf_regs : process (clk)
    begin
        if rising_edge(clk)  then
            if rst = '1' then
                conf_reg1_r <= (others=>'0'); conf_reg2_r <= (others=>'0');
                conf_reg3_r <= (others=>'0'); conf_reg4_r <= (others=>'0');
                conf_reg5_r <= (others=>'0'); conf_reg6_r <= (others=>'0');
                conf_reg7_r <= (others=>'0');
            elsif write_reg = '1' then
                case (dest_sel) is                    
                    when x"1" =>
                        conf_reg1_r <= param;

                    when x"2" =>
                        conf_reg2_r <= param;

                    when x"3" =>
                        conf_reg3_r <= param;

                    when x"4" =>
                        conf_reg4_r <= param;

                    when x"5" =>
                        conf_reg5_r <= param;

                    when x"6" =>
                        conf_reg6_r <= param;

                    when x"7" =>
                        conf_reg7_r <= param;

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    -- PRNG =======================================================
    prng_gen : if RAND_WORDS /= 0 generate
   
    --Trivium PRNG
    trivium_inst : entity work.prng_trivium_enhanced(structural)
    generic map (N => 1)
    port map(
        clk         => clk,
        rst         => rst,
        en_prng     => prng_en,
        seed        => prng_seed,
        reseed      => prng_reseed,
        reseed_ack  => open,
        rdi_data    => prng_rdi_data,
        rdi_ready   => prng_rdi_ready,
        rdi_valid   => prng_rdi_valid
    );

    rnd_piso : entity work.dut_piso(behav)
    generic map(
        WI => 64,
        WO => 32
    )
    port map(
        clk       => clk,
        rst       => fifo_rst,
        di_valid  => prng_rdi_valid,
        di_ready  => prng_rdi_ready,
        din	      => prng_rdi_data,
        do_valid  => rnd_piso_do_valid,
        do_ready  => rnd_piso_do_ready,
        dout      => rnd_piso_do_data
    );

    rnd_sipo : entity work.dut_sipo(behav)
    generic map(
          WI => 32,
          WO => FIFO_RDI_WIDTH
    )
      port map(
          clk       => clk,
          rst       => fifo_rst,
          di_valid  => rnd_piso_do_valid,
          di_ready  => rnd_piso_do_ready,
          din	    => rnd_piso_do_data,
          do_valid  => rnd_sipo_do_valid,
          do_ready  => rnd_sipo_do_ready,
          dout      => rnd_sipo_do_data
    );
    
    rdi_fifo : entity work.dut_fwft_fifo(behav)
    generic map(
        G_W => FIFO_RDI_WIDTH,
        G_LOG2DEPTH => FIFO_RDI_LOG2DEPTH
    )
    port map(
        clk         => clk,
        rst         => fifo_rst,
        din_valid   => rnd_sipo_do_valid,
        din_ready   => rnd_sipo_do_ready,
        din	        => rnd_sipo_do_data,
        dout_valid  => rdi_fifo_do_valid,
        dout_ready  => rdi_fifo_do_ready,
        dout        => rdi_fifo_dout
    );
    
    end generate prng_gen;
    --! DEBUG
--    U_ILA : ila_0
--    port map(
--        clk => clk,
--        Probe0 => (others=>rst),
--        Probe1 => (others=>di_valid),
--        Probe2 => (others=>di_ready),
--        Probe3 => din,
--        Probe4 => (others=>do_valid),
--        Probe5 => (others=>do_ready),
--        Probe6 => dout
--    );
end behav;
