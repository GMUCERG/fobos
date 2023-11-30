-- File: adc_interface
-- Purpose : adc interface for OpenADC to be used in FOBOS
-- Author : Abubakr Abdulgadir
-- Date : September 2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- a block is defined as 4 adc samples
-- every 10 bit sample is padded with 6 zeros and 4 of these
-- are combined as one 64-bit block

entity adc_capture is
    port ( 
        clk             : in std_logic;
        rst             : in std_logic;
        -- config signals
        cmd_capture_en  : in std_logic;
        cmd_capture_rst : in std_logic;
        cmd_blk_num     : in std_logic_vector (17 downto 0); 
        cmd_test_en     : in std_logic;
        stat_capture_err: out std_logic;
        cmd_test_cnt_start : in std_logic_vector (9 downto 0);
        --
        trigger         : in std_logic;
        -- data interface
        adc_in          : in std_logic_vector (9 downto 0);
        dout_data       : out std_logic_vector (63 downto 0);
        dout_valid      : out std_logic;
        dout_ready      : in std_logic;
        dout_tlast      : out std_logic
--        ;
--        --DEBUG
--        d_state_r       : out std_logic_vector(2 downto 0);
--        d_blk_cnt_r : out std_logic_vector (17 downto 0)
        
    );
end adc_capture;

architecture behav of adc_capture is

    type state_type is (IDLE, WAIT_TRIG, CAP0,  CAP1,  CAP2,  CAP3, ERR);
    signal state_r, nx_state : state_type;
    signal blk_cnt_r, nx_blk_cnt : unsigned(17 downto 0);
    signal sample0_r, sample1_r, sample2_r : std_logic_vector(9 downto 0);
    signal nx_sample0, nx_sample1, nx_sample2 : std_logic_vector(9 downto 0);
    signal current_sample : std_logic_vector(9 downto 0);
    signal test_cntr_r : unsigned(9 downto 0);
    signal ld_test_cntr : std_logic;

begin
    --DEBUG
    
--    d_blk_cnt_r <= std_logic_vector(blk_cnt_r);
    
    reg: process(clk)
    begin
        if (rising_edge(clk)) then
            if rst = '1' or cmd_capture_rst = '1' then
                state_r <= IDLE;
                blk_cnt_r <= (others=>'0');
            else
                blk_cnt_r <= nx_blk_cnt;
                state_r <= nx_state;
            end if;

            if ld_test_cntr = '1' then
                test_cntr_r <= unsigned(cmd_test_cnt_start);
            else
                if cmd_test_en = '1' then
                    test_cntr_r <= test_cntr_r + 1;
                end if;
            end if;

            sample0_r <= nx_sample0;
            sample1_r <= nx_sample1;
            sample2_r <= nx_sample2;

        end if;
    end process;

    comb : process(all) begin
        --default values
        dout_valid <= '0';
        dout_tlast <= '0';
        ld_test_cntr <= '0';
        stat_capture_err <= '0';
        nx_sample0 <= sample0_r;
        nx_sample1 <= sample1_r;
        nx_sample2 <= sample2_r;
        nx_blk_cnt <= blk_cnt_r;
        nx_state <= state_r;
        --
--        d_state_r <= (others=>'0');

        case (state_r) is
            when IDLE =>
--                d_state_r <= "000";
                nx_blk_cnt <= (others=>'0');
                ld_test_cntr <= '1';
                if cmd_capture_en = '1' then
                    nx_state <= WAIT_TRIG;
                end if;
 
            when WAIT_TRIG =>
--                d_state_r <= "001";
                ld_test_cntr <= '1';
                if cmd_capture_en = '1' and trigger = '1' then
                    nx_state <= CAP0;
                end if;
            
            when CAP0 =>
--                d_state_r <= "010";
                nx_sample0 <= current_sample;
                nx_state <= CAP1;

            when CAP1 =>
--                d_state_r <= "011";
                nx_sample1 <= current_sample;
                nx_state <= CAP2;

            when CAP2 =>
--                d_state_r <= "100";
                nx_sample2 <= current_sample;
                nx_state <= CAP3;

            when CAP3 =>
--                d_state_r <= "101";
                dout_valid <= '1';
                if dout_ready = '1' then
                    if blk_cnt_r = unsigned(cmd_blk_num) - 1 then
                        dout_tlast <= '1';
                        nx_blk_cnt <= (others=>'0');
                        nx_state <= IDLE;
                    else
                        nx_blk_cnt <= blk_cnt_r + 1;
                        nx_state <= CAP0;
                    end if;
                else
                    nx_state <= ERR; --fifo is not ready. Could be full
                end if;

            when ERR =>
--                d_state_r <= "110";
                    -- fifo is not ready report error and wait for user to reset everything
                    stat_capture_err <= '1';
                    nx_state <= ERR;

            when others=>
                nx_state <= IDLE;
        end case;

    end process;

    current_sample <= std_logic_vector(test_cntr_r) when cmd_test_en = '1' else adc_in;
    dout_data <=    "000000" & current_sample &
                    "000000" & sample2_r      &    
                    "000000" & sample1_r      & 
                    "000000" & sample0_r;

end behav;