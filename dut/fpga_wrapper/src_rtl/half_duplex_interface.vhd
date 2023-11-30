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
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2019 06:30:09 PM
-- Design Name: 
-- Module Name: half_duplex_interface - behav
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

entity half_duplex_interface is
    generic(
           MASTER : boolean
    );
    Port ( 
           --external bus
           shared_handshake_out : out std_logic; 
           shared_handshake_in  : in std_logic;
           dbus : inout STD_LOGIC_VECTOR (3 downto 0);
           direction_out : out std_logic; 
           --user connection
           ---out/in from the view point of the interface user
           handshake0_out : in STD_LOGIC; 
           handshake1_out : in STD_LOGIC;
           handshake0_in : out STD_LOGIC;
           handshake1_in : out STD_LOGIC;
           --data
           dout : in std_logic_vector(3 downto 0); -- from the user point of view
           din : out std_logic_vector(3 downto 0); -- from the user point of view
           ---control
           direction_in : in STD_LOGIC -- 0 --for phase0 (ctrl -> dut)-- drived by master
           
           );
end half_duplex_interface;

architecture behav of half_duplex_interface is

signal snd : std_logic; --1 send 0 receive. Master will send in phase0 

begin
--
direction_out <= direction_in;
---Handsahke 
--mux phase0 and phase1 outgoing handsahe signals
shared_handshake_out <= handshake0_out when direction_in = '0' else handshake1_out;
---d-mux
handshake0_in <= shared_handshake_in when direction_in = '0' else '0';
handshake1_in <= shared_handshake_in when direction_in = '1' else '0';
---data bus

snd_signal : if MASTER generate
    snd <= not direction_in; --in phase 0 master is a sender
end generate;
snd_signal_slave: if not MASTER generate
    snd <=  direction_in;    -- in phase 0 slave is a receiver 
end generate;


dbus <= dout when  snd = '1' else (others=> 'Z');
din <=  dbus when  snd = '0' else (others=> '0') ;

end behav;
