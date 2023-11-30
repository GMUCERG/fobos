--#############################################################################
--#                                                                           #
--#   Copyright 2019-2023 Cryptographic Engineering Research Group (CERG)     #
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
---------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2019 11:03:20 AM
-- Design Name: 
-- Module Name: dutcomm_wrapper - behav
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity half_duplex_dut is
    generic(
        W : integer := 128;
        SW : integer :=128
    );
    port(
       fc2d_clk     : in STD_LOGIC;
       fc_rst       : in STD_LOGIC; --also resets the dut
       ---External bus--half duplex interface 
       fd2c_hs      : out std_logic; 
       fc2d_hs      : in std_logic;
       fc_dio       : inout STD_LOGIC_VECTOR (3 downto 0);
       fc_io        : in std_logic
		 --debug
--		 ;
--		 di_valid_deb : out std_logic;
--		 di_ready_deb  : out std_logic;
--		 do_valid_deb : out std_logic;
--  	 do_ready_deb  : out std_logic
       );
       
end half_duplex_dut;

architecture behav of half_duplex_dut is

signal din_s         :  STD_LOGIC_VECTOR (3 downto 0);
signal di_valid_s    :  STD_LOGIC;
signal di_ready_s    :  STD_LOGIC;        
signal dout_s        :  STD_LOGIC_VECTOR (3 downto 0);
signal do_valid_s    :  STD_LOGIC;
signal do_ready_s    :  STD_LOGIC;

begin
--debug
--		di_valid_deb <= di_valid_s;
--		 di_ready_deb  <= di_ready_s;
--		 do_valid_deb <= do_valid_s;
--		 do_ready_deb  <= do_ready_s;
--end debug
    
    hd_int: entity work.half_duplex_interface(behav)
        generic map(
            MASTER => false
        )
        port map( 
            --external bus
            shared_handshake_out => fd2c_hs,
            shared_handshake_in  => fc2d_hs,
            dbus => fc_dio,
            direction_out => open, 
            --user connection
            ---out/in from the view point of the interface user
            handshake0_out => di_ready_s,
            handshake1_out => do_valid_s,
            handshake0_in =>  di_valid_s,
            handshake1_in =>  do_ready_s,
            --data
            dout => dout_s, -- from the user point of view
            din  => din_s, -- from the user point of view
            ---control
            direction_in => fc_io -- 0 --for phase0 (ctrl -> dut)-- drived by master
                   
        );
        
    dut: entity work.core_wrapper(behav)
        port map(
            clk => fc2d_clk,
            rst => fc_rst,
            di_valid => di_valid_s,
            do_ready => do_ready_s,
            di_ready => di_ready_s, 
            do_valid => do_valid_s,
            din   => din_s,
            dout  => dout_s   
        );

end behav;
