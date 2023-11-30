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

entity aes_non_pipe is
	port (	
			clock : in std_logic ;
			start : in std_logic ;
			data_in : in std_logic_vector (0 to 127);
			key_in : in std_logic_vector (0 to 127);
			data_out : out std_logic_vector (0 to 127);	
			--trigger : out std_logic	;
			done : out std_logic
			);

end aes_non_pipe;			

architecture aes_non_pipe_arch of aes_non_pipe is

------ signals from controller to datapath -------------

signal loads : std_logic ; 
signal loadk : std_logic ;
signal li : std_logic ;
signal ei : std_logic ;	
signal lk : std_logic ;
signal ek : std_logic ;
signal r_key_sel : std_logic ;
signal load_data : std_logic_vector (1 downto 0) ; 
signal load_out : std_logic	;

----- signals from datapath to controller -------------

signal zi : std_logic ;	 
signal zk : std_logic ;	 

component datapath 
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
end component ;

component controller
	port (
			clock : in std_logic ;
			start : in std_logic ;
			loads : out std_logic ;
			loadk : out std_logic ;	
			li : out std_logic ;
			ei : out std_logic ;
			zi : in std_logic ;  
			lk : out std_logic ;
			ek : out std_logic ;
			--zk : in std_logic ;  
			r_key_sel : out std_logic ;
			load_data : out std_logic_vector (1 downto 0) ;	
			load_out : out std_logic ;	
--			trigger : out std_logic	;
			done : out std_logic 
		 );
end component ;

begin
	
	u1 : datapath
	port map (
			   clock => clock,
			   data_in => data_in,
			   key_in => key_in,
			   loads => loads,
			   loadk => loadk,
			   li => li,
			   ei => ei,
			   zi => zi,
			   lk => lk,
			   ek => ek,
			   --zk => zk,
			   r_key_sel => r_key_sel,
			   load_data => load_data,
			   load_out => load_out,   
			   --trigger => trigger,			   
			   data_out => data_out
			 );
			  
	u2 : controller
	port map (
			   clock => clock,
			   start => start,
			   loads => loads,
			   loadk => loadk,
			   li => li,
			   ei => ei,
			   zi => zi,
			   lk => lk,
			   ek => ek,
			   --zk => zk,
			   r_key_sel => r_key_sel,
			   load_data => load_data,
			   load_out => load_out,	
--			   trigger => trigger,
			   done => done
			 );


end aes_non_pipe_arch;
