--#############################################################################
--#                                                                           #
--#   Copyright 2013-2023 Cryptographic Engineering Research Group (CERG)     #
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
-- Author: Shaunak

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.STD_LOGIC_arith.all;

entity datapath is
	port (
			clock : in std_logic ;
	   		data_in : in std_logic_vector (0 to 127);
			key_in : in std_logic_vector (0 to 127);
			loads : in std_logic ;
			loadk : in std_logic ;	
			li : in std_logic ;
			ei : in std_logic ;
			zi : out std_logic ;  
			lk : in std_logic ;
			ek : in std_logic ;
			--zk : out std_logic ;  
			r_key_sel : in std_logic ;
			load_data : in std_logic_vector (1 downto 0) ;
			load_out : in std_logic	;  
			--trigger : out std_logic	;
			data_out : out std_logic_vector (0 to 127)
		);
end datapath;

architecture datapath_arch of datapath is 	  

signal b_out, dummy_b_out : std_logic_vector	(0 to 127);	  
signal a0, a1, a2, a3, a4, a5 ,a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 : std_logic_vector (7 downto 0);
signal c0, c1, c2, c3, c4, c5 ,c6, c7, c8, c9, c10, c11, c12, c13, c14, c15 : std_logic_vector (7 downto 0);
signal mux_out : std_logic_vector (0 to 127);
signal temp_mix_key_in, temp_mix_key_out : std_logic_vector (0 to 159);
signal r_key_in : std_logic_vector (0 to 127);
signal k0, k1, k2, k3, k4, k5 ,k6, k7, k8, k9, k10, k11, k12, k13, k14, k15 : std_logic_vector (7 downto 0);
signal count_i : std_logic_vector (3 downto 0);	
signal count_k : std_logic_vector (9 downto 0);	
signal b_in, c_in, d_in : std_logic_vector (0 to 127);
signal t_k_in : std_logic_vector (0 to 127);  
signal t_key_gen_s12, t_key_gen_s13, t_key_gen_s14, t_key_gen_s15 : std_logic_vector (7 downto 0);
signal t_key_gen : std_logic_vector	(31 downto 0);
signal t_key_gen_0, t_key_gen_1, t_key_gen_2, t_key_gen_3 : std_logic_vector (31 downto 0);
signal t_s0, t_s1, t_s2, t_s3, t_s4, t_s5 ,t_s6, t_s7, t_s8, t_s9, t_s10, t_s11, t_s12, t_s13, t_s14, t_s15 : std_logic_vector (7 downto 0);
signal t_mix_0, t_mix_1, t_mix_2, t_mix_3, t_mix_4, t_mix_5 ,t_mix_6, t_mix_7, t_mix_8, t_mix_9, t_mix_10, t_mix_11, t_mix_12, t_mix_13, t_mix_14, t_mix_15 : std_logic_vector (7 downto 0);
signal rcon : std_logic_vector (31 downto 0); 
signal t_data_out : std_logic_vector (0 to 127);   
signal final_data_out : std_logic_vector (0 to 127);   
signal temp_data_in : std_logic_vector (0 to 127);


component registern
	 generic (N : integer := 128);
	 port(
		 clock : in STD_LOGIC;
		 la : in STD_LOGIC;
		 data_in : in STD_LOGIC_VECTOR(0 to N-1);
		 q : out STD_LOGIC_VECTOR(0 to N-1)
	     );	

end component ;

component upcount
	generic (N : integer := 4);
	 port(
		 clock : in STD_LOGIC;
		 l : in STD_LOGIC;
		 e : in STD_LOGIC;
		-- data_in : in STD_LOGIC_VECTOR(N downto 1);
		 q : out STD_LOGIC_VECTOR(N-1 downto 0)
	     );
end component ;


component sbox is
port (
		--clock : in std_logic;
		--we : in std_logic;
		a : in std_logic_vector(7 downto 0);
		--di : in std_logic_vector(7 downto 0);
		do : out std_logic_vector(7 downto 0)
	);

end component ;



	----------- dot product with 02 -----------
	
	function dot_2 (signal s: std_logic_vector)
		return std_logic_vector	is
		
		variable result : std_logic_vector (7 downto 0);
		variable temp : std_logic_vector (8 downto 0);
	--	constant poly : integer := 283;
		
	begin
		
		temp := (s & '0');
		
		--result := std_logic_vector(conv_unsigned((conv_integer(unsigned(temp)) mod poly),8));
		if (temp(8) = '1') then
			temp := temp xor "100011011" ;
			result := temp(7 downto 0);
		else
			result := temp(7 downto 0);
		end if;
		
		return result;
		
	end dot_2;
		
	----------- dot product with 03 -----------
	
	function dot_3(signal s: std_logic_vector)
		return std_logic_vector	is
	
		variable result : std_logic_vector (7 downto 0);
		variable temp : std_logic_vector (8 downto 0);
		
	begin
		
		temp := (s & '0');
		temp(7 downto 0) := temp(7 downto 0) xor s;
		--result := temp mod "100011011";
		if (s(7) = '1') then
			temp := temp xor "100011011" ;	
			result := temp(7 downto 0);
		else
			result := temp(7 downto 0);
		end if;
		
		return result;
		
	end dot_3;
								  
							  
							  
begin 
	
		
	----------------------- bytes of state -------------
	
	a0  <= t_data_out(0 to 7);
	a1  <= t_data_out(8 to 15);
	a2  <= t_data_out(16 to 23);
	a3  <= t_data_out(24 to 31);
	a4  <= t_data_out(32 to 39);
	a5  <= t_data_out(40 to 47);
	a6  <= t_data_out(48 to 55);
	a7  <= t_data_out(56 to 63);
	a8  <= t_data_out(64 to 71);
	a9  <= t_data_out(72 to 79);
	a10 <= t_data_out(80 to 87);
	a11 <= t_data_out(88 to 95);
	a12 <= t_data_out(96 to 103);
	a13 <= t_data_out(104 to 111);
	a14 <= t_data_out(112 to 119);
	a15 <= t_data_out(120 to 127);
	
	
	----------------------- bytes of key/Round key ------------
	
	k0  <= r_key_in(0 to 7);
	k1  <= r_key_in(8 to 15);
	k2  <= r_key_in(16 to 23);
	k3  <= r_key_in(24 to 31);
	k4  <= r_key_in(32 to 39);
	k5  <= r_key_in(40 to 47);
	k6  <= r_key_in(48 to 55);
	k7  <= r_key_in(56 to 63);
	k8  <= r_key_in(64 to 71);
	k9  <= r_key_in(72 to 79);
	k10 <= r_key_in(80 to 87);
	k11 <= r_key_in(88 to 95);
	k12 <= r_key_in(96 to 103);
	k13 <= r_key_in(104 to 111);
	k14 <= r_key_in(112 to 119);
	k15 <= r_key_in(120 to 127);
	
	--------------- load initial states and Key --------------------------
	
	u1_state_register : registern					-- register relocated after the sbox and before shift-rows
	port map (clock,loads,b_in,b_out);
	
	u1_dummy_state_register : registern			-- dummy register added to increase the power signal
	port map (clock, loads, b_in, dummy_b_out) ;
	
	u2_key_register : registern					-- register relocated after the sbox and before mixing
	generic map (N => 160)
	port map (clock,loadk,temp_mix_key_in,temp_mix_key_out);
	
	u3_output_register : registern
	port map (clock,load_out,t_data_out,final_data_out);
	
	--------------- counter -------------
	
	u3_counter : upcount
	port map (clock,li,ei,count_i);
	
	zi <= '1' when count_i = "1000" else '0';	-- if counter counts 0 to 8 then 9 rounds are complete
	
	--data_1000_counter : upcount  
	--generic map (N => 10)
	--port map (clock,lk,ek,count_k);
	
	--zk <= '1' when count_k = "1111100111" else '0';	-- if counter counts 0 to 999 then 1000 encryptions are complete
	--zk <= '1' when count_k = "111110011111" else '0';	-- if counter counts 0 to 3999 then 4000 encryptions are complete
	
	--------------------- mux declarations ----------------
		
				 
	mux_out <= d_in when load_data = "10" else	-- input data load mux
			   c_in when load_data = "01" else
			   temp_data_in;
		
			   
	r_key_in <= t_k_in when r_key_sel = '1' else   -- input key load mux
			   	key_in;
			  
	temp_data_in <= data_in ; --when count_k = "0000000000"	else
					--final_data_out;
	
	------------------------- Rcon mux declaration --------------------
	
	rcon <= x"01000000" when count_i = "0000" else
			x"02000000" when count_i = "0001" else
			x"04000000" when count_i = "0010" else
			x"08000000" when count_i = "0011" else
			x"10000000" when count_i = "0100" else
			x"20000000" when count_i = "0101" else
			x"40000000" when count_i = "0110" else
			x"80000000" when count_i = "0111" else
			x"1b000000" when count_i = "1000" else
			x"36000000" ;
				
				
	------------------------- Round Key Generation ---------------------
	
--	t_key_gen_s12 <= sbox(conv_integer(unsigned(k12)));								 --- substitute from sbox 
--	t_key_gen_s13 <= sbox(conv_integer(unsigned(k13)));
--	t_key_gen_s14 <= sbox(conv_integer(unsigned(k14)));
--	t_key_gen_s15 <= sbox(conv_integer(unsigned(k15)));	 
	
	u12_sbox_key : sbox port map (k12, t_key_gen_s12);				--- substitute from sbox 
	u13_sbox_key : sbox port map (k13, t_key_gen_s13);
	u14_sbox_key : sbox port map (k14, t_key_gen_s14);
	u15_sbox_key : sbox port map (k15, t_key_gen_s15);
	
	temp_mix_key_in <= k0 & k1 & k2 & k3 & k4 & k5 & k6 & k7 & k8 & k9 & k10 & k11 & k12 & k13 & k14 & k15 & t_key_gen_s12 & t_key_gen_s13 & t_key_gen_s14 & t_key_gen_s15 ;
	-- above vector is 160 bits long due to an extra 32 bit register requirement
	
	
	t_key_gen <= temp_mix_key_out(136 to 159) & temp_mix_key_out(128 to 135);	  --- rotate in column
	
	t_key_gen_0 <= t_key_gen   xor temp_mix_key_out(0 to 31) xor rcon;	  --- generate new round key
	t_key_gen_1 <= t_key_gen_0 xor temp_mix_key_out(32 to 63);
	t_key_gen_2 <= t_key_gen_1 xor temp_mix_key_out(64 to 95);
	t_key_gen_3 <= t_key_gen_2 xor temp_mix_key_out(96 to 127);
	
	t_k_in <= t_key_gen_0 & t_key_gen_1 & t_key_gen_2 & t_key_gen_3 ;
	
	----------------------- sub_byte ---------------
	
	--byte_sub : for i in 0 to 15 generate
--		t_s0 <= sbox(conv_integer(unsigned(a0)));
--		t_s1 <= sbox(conv_integer(unsigned(a1)));
--		t_s2 <= sbox(conv_integer(unsigned(a2)));
--		t_s3 <= sbox(conv_integer(unsigned(a3)));
--		t_s4 <= sbox(conv_integer(unsigned(a4)));
--		t_s5 <= sbox(conv_integer(unsigned(a5)));
--		t_s6 <= sbox(conv_integer(unsigned(a6)));
--		t_s7 <= sbox(conv_integer(unsigned(a7)));
--		t_s8 <= sbox(conv_integer(unsigned(a8)));
--		t_s9 <= sbox(conv_integer(unsigned(a9)));
--		t_s10 <= sbox(conv_integer(unsigned(a10)));
--		t_s11 <= sbox(conv_integer(unsigned(a11)));
--		t_s12 <= sbox(conv_integer(unsigned(a12)));
--		t_s13 <= sbox(conv_integer(unsigned(a13)));
--		t_s14 <= sbox(conv_integer(unsigned(a14)));
--		t_s15 <= sbox(conv_integer(unsigned(a15)));	 
		
		u0_sbox : sbox port map (a0,t_s0);
		u1_sbox : sbox port map (a1,t_s1);
		u2_sbox : sbox port map (a2,t_s2);
		u3_sbox : sbox port map (a3,t_s3);
		u4_sbox : sbox port map (a4,t_s4);
		u5_sbox : sbox port map (a5,t_s5);
		u6_sbox : sbox port map (a6,t_s6);
		u7_sbox : sbox port map (a7,t_s7);
		u8_sbox : sbox port map (a8,t_s8);
		u9_sbox : sbox port map (a9,t_s9);
		u10_sbox : sbox port map (a10,t_s10);
		u11_sbox : sbox port map (a11,t_s11);
		u12_sbox : sbox port map (a12,t_s12);
		u13_sbox : sbox port map (a13,t_s13);
		u14_sbox : sbox port map (a14,t_s14);
		u15_sbox : sbox port map (a15,t_s15);
		
	--end generate;
	
	b_in <= t_s0 & t_s1 & t_s2 & t_s3 & t_s4 & t_s5 & t_s6 & t_s7 & t_s8 & t_s9 & t_s10 & t_s11 & t_s12 & t_s13 & t_s14 & t_s15 ;
	
	----------------- shift rows --------------
	
	c_in <= b_out(0 to 7) & b_out(40 to 47) & b_out(80 to 87) & b_out(120 to 127) & b_out(32 to 39) & b_out(72 to 79) & b_out(112 to 119) & b_out(24 to 31) & b_out(64 to 71) & b_out(104 to 111) & b_out(16 to 23) & b_out(56 to 63) & b_out(96 to 103) & b_out(8 to 15) & b_out(48 to 55) & b_out(88 to 95) ;
	
	c0 <= c_in(0 to 7);
	c1 <= c_in(8 to 15);
	c2 <= c_in(16 to 23);
	c3 <= c_in(24 to 31);
	c4 <= c_in(32 to 39);
	c5 <= c_in(40 to 47);
	c6 <= c_in(48 to 55);
	c7 <= c_in(56 to 63);
	c8 <= c_in(64 to 71);
	c9 <= c_in(72 to 79);
	c10 <= c_in(80 to 87);
	c11 <= c_in(88 to 95);
	c12 <= c_in(96 to 103);
	c13 <= c_in(104 to 111);
	c14 <= c_in(112 to 119);
	c15 <= c_in(120 to 127);
	
	------------------ mix columns ---------
	
	t_mix_0 <= dot_2(c0) xor dot_3(c1) xor c2 xor c3;
	t_mix_1 <= c0 xor dot_2(c1) xor dot_3(c2) xor c3;
	t_mix_2 <= c0 xor c1 xor dot_2(c2) xor dot_3(c3);
	t_mix_3 <= dot_3(c0) xor c1 xor c2 xor dot_2(c3);
	
	t_mix_4 <= dot_2(c4) xor dot_3(c5) xor c6 xor c7;
	t_mix_5 <= c4 xor dot_2(c5) xor dot_3(c6) xor c7;
	t_mix_6 <= c4 xor c5 xor dot_2(c6) xor dot_3(c7);
	t_mix_7 <= dot_3(c4) xor c5 xor c6 xor dot_2(c7);
	
	t_mix_8 <= dot_2(c8) xor dot_3(c9) xor c10 xor c11;
	t_mix_9 <= c8 xor dot_2(c9) xor dot_3(c10) xor c11;
	t_mix_10 <= c8 xor c9 xor dot_2(c10) xor dot_3(c11);
	t_mix_11 <= dot_3(c8) xor c9 xor c10 xor dot_2(c11);
	
	t_mix_12 <= dot_2(c12) xor dot_3(c13) xor c14 xor c15;
	t_mix_13 <= c12 xor dot_2(c13) xor dot_3(c14) xor c15;
	t_mix_14 <= c12 xor c13 xor dot_2(c14) xor dot_3(c15);
	t_mix_15 <= dot_3(c12) xor c13 xor c14 xor dot_2(c15);	 
	
	d_in <= t_mix_0 & t_mix_1 & t_mix_2 & t_mix_3 & t_mix_4 & t_mix_5 & t_mix_6 & t_mix_7 & t_mix_8 & t_mix_9 & t_mix_10 & t_mix_11 & t_mix_12 & t_mix_13 & t_mix_14 & t_mix_15 ;
	
	
	---------------- add round key ---------
	
		--t_data_out <= dummy_b_out when (count_i = "1111") else (mux_out xor r_key_in);	-- just to make sure that the dummy register is not thrown off during optimization
		  t_data_out <= mux_out xor r_key_in;
	----------------- data out -----------
	
	--data_out <= t_data_out;	   	
	data_out <= final_data_out;	   	
	
	--trigger <= '1' when (count_i = "1000") else '0';
	
end datapath_arch;
