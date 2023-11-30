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

-- =====================================================================
-- Copyright 2017-2023 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- Author: Farnoud Farahmand
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use work.PRNG_pkg.all;

entity prng_trivium_enhanced is
   generic (
			--RW : integer:= 64;  -- allowable values are 1, 2, ... 64 !-- no longer allowed!
			N : integer:= 4 -- allowable values are 1, 2, 3
			-- When N = 1, rdi_data returns 64 bits of randomness
			-- When N = 2, rdi_data returns 128 bits of randomness
			-- When N = 3, rdi_data returns 192 bits of randomness
			-- When N = 4, rdi_data returns 320 bits of randomness
    );
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
		en_prng     : in  std_logic;
        seed        : in  std_logic_vector(N*128 - 1 downto 0); -- 128 bits of seed required for each instance
		reseed      : in std_logic;
		reseed_ack  : out std_logic;
		rdi_data    : out std_logic_vector(N*64 - 1 downto 0);
		rdi_ready   : in std_logic;
		rdi_valid   : out std_logic
    );
end prng_trivium_enhanced;

architecture structural of prng_trivium_enhanced is
    type state_type     is (S_IDLE, S_RESEED, S_RUN);
    signal state,nstate : state_type;

    constant ZEROES     : std_logic_vector(N*128 - 1 downto 0):=(others => '0');
    signal ctr          : std_logic_vector(64 - 1 downto 0);
    signal key          : std_logic_vector(N*80 - 1 downto 0);
    signal iv           : std_logic_vector(N*80 - 1 downto 0);
    signal key_iv_update    : std_logic;
    signal init_done    : std_logic;
    signal reseed_req   : std_logic;
    signal din_valid    : std_logic;
    signal din_ready    : std_logic;
    signal clr_ctr      : std_logic;
    signal en_ctr       : std_logic;


begin

--! DATAPATH --!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!

	instance1: if (N = 1) generate

    key <= seed(80 -1 downto 0);
    iv  <= seed(128-1 downto 80)&x"00000000";
    
    end generate instance1;
    
	instance2: if (N = 2) generate

    key <= seed(208 -1 downto 128)& seed(80 -1 downto 0);
    iv  <= seed(256-1 downto 208)&x"00000000" & seed(128-1 downto 80)&x"00000000";
    
    end generate instance2;
    
	instance3: if (N = 3) generate

    key <= seed(336-1 downto 256) & seed(208 -1 downto 128)& seed(80 -1 downto 0);
    iv  <= seed(384-1 downto 336)&x"00000000" & seed(256-1 downto 208)&x"00000000" & seed(128-1 downto 80)&x"00000000";
    
    end generate instance3;
    
	instance4: if (N = 4) generate

    key <= seed(464-1 downto 384) & seed(336-1 downto 256) & seed(208 -1 downto 128)& seed(80 -1 downto 0);
    iv  <= seed(512-1 downto 464)&x"00000000" & seed(384-1 downto 336)&x"00000000" & seed(256-1 downto 208)&x"00000000" & seed(128-1 downto 80)&x"00000000";
    
    end generate instance4;
    
    instance5: if (N = 5) generate

    key <= seed(512 + 80 -1 downto 512) &
           seed(464-1 downto 384)       & 
           seed(336-1 downto 256)       & 
           seed(208 -1 downto 128)      & 
           seed(80 -1 downto 0);
    iv  <= seed(512 + 128 -1 downto 512+80) &x"00000000" &
           seed(512-1 downto 464)           &x"00000000" & 
           seed(384-1 downto 336)           &x"00000000" & 
           seed(256-1 downto 208)           &x"00000000" & 
           seed(128-1 downto 80)            &x"00000000";
    
    end generate instance5;
    
     instance6: if (N = 6) generate

    key <= seed(512 + 128 + 80 -1 downto 512 + 128) &
           seed(512 + 80 -1 downto 512) &
           seed(464-1 downto 384)       & 
           seed(336-1 downto 256)       & 
           seed(208 -1 downto 128)      & 
           seed(80 -1 downto 0);
    iv  <= seed(512 +128+ 128 -1 downto 512+128+80) &x"00000000" &
           seed(512 + 128 -1 downto 512+80) &x"00000000" &
           seed(512-1 downto 464)           &x"00000000" & 
           seed(384-1 downto 336)           &x"00000000" & 
           seed(256-1 downto 208)           &x"00000000" & 
           seed(128-1 downto 80)            &x"00000000";
    
    end generate instance6;

trivium_primitive_basic: entity work.trivium(behavioral)
	generic map(
        M_SIZE          => 64
    )
    port map(
        clk         => clk,
        rst         => rst,

        key           => key(80-1 downto 0),
        iv            => iv(80-1 downto 0),
        key_iv_update => key_iv_update,
        init_done     => init_done,

        din         => ctr,
        din_valid   => din_valid,
        din_ready   => din_ready,

        dout        => rdi_data(64-1 downto 0),
        dout_valid  => rdi_valid,
        dout_ready  => rdi_ready,

        done        => reseed_req
    );

    trivgen: for i in 2 to N generate

	trivium_primitive: entity work.trivium(behavioral)
	generic map(
        M_SIZE          => 64
    )
    port map(
        clk         => clk,
        rst         => rst,

        key           => key(i*80-1 downto (i-1)*80),
        iv            => iv(i*80-1 downto (i-1)*80),
        key_iv_update => key_iv_update,
        init_done     => open,

        din         => ctr,
        din_valid   => din_valid,
        din_ready   => open,

        dout        => rdi_data(i*64-1 downto (i-1)*64),
        dout_valid  => open,
        dout_ready  => rdi_ready,

        done        => open
    );

    end generate trivgen;
    --! CONTROLLER --!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!-
	sync_process: process(clk)
	begin
		if (rising_edge(clk)) then
 		   if (rst = '1') then
				state <= S_IDLE;
			else
				state <= nstate;
			end if;
			if (clr_ctr = '1') then
				ctr <= ZEROES(64-1 downto 0);
            elsif (en_ctr = '1') then
				ctr <= std_logic_vector(unsigned(ctr) + 1);
			end if;
		end if;
	end process;

    state_process: process(state, reseed, init_done, reseed_req, en_prng, din_ready)
    begin
        -- defaults
        nstate        <= state;
        key_iv_update <= '0';
        reseed_ack    <= '0';
        en_ctr        <= '0';
        din_valid     <= '0';
        clr_ctr       <= '0';

    	case state is

    		when S_IDLE =>
    			if (reseed = '1') then
                    key_iv_update <= '1';
    				nstate        <= S_RESEED;
    			end if;

    		when S_RESEED =>
                if (init_done = '1') then
                    clr_ctr     <= '1';
                    reseed_ack  <= '1';
                    nstate      <= S_RUN;
    			end if;

    		when S_RUN =>
                if (reseed_req = '1') then
                    if (reseed = '1') then
                        key_iv_update <= '1';
                        nstate        <= S_RESEED;
                    else
                        nstate        <= S_IDLE;
                    end if;
    			elsif (reseed = '1') then
    				key_iv_update <= '1';
                    nstate        <= S_RESEED;
                elsif (en_prng = '1') then
                    din_valid   <= '1';
                    if (din_ready = '1') then
                        en_ctr <= '1';
                    end if;
                end if;

    		when OTHERS =>

    	end case;

    end process;

end structural;
