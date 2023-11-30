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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package aes_components is
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
			done : out std_logic 
		 );
end component ;	

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

component aes_non_pipe
	port (	
			clock : in std_logic ;
			start : in std_logic ;
			data_in : in std_logic_vector (0 to 127);
			key_in : in std_logic_vector (0 to 127);
			data_out : out std_logic_vector (0 to 127);
			done : out std_logic
			);
end component ;

component InstROM 
	Port ( InstADDRESS : in  STD_LOGIC_VECTOR (3 downto 0);
	InstOUT : out  STD_LOGIC_VECTOR (0 to 127));
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
         
end package;
