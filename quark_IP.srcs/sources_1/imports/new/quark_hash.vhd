----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2019 01:29:32 PM
-- Design Name: 
-- Module Name: quark_hash - Behavioral
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
--use ieee.std_logic_arith.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity quark_hash is
    Generic(
        message_length : integer := 0; -- la longueur du message
        key_length : integer := 100; 
        s_Interface : integer := 256; -- la taille de la sortie
        rate : integer := 32; -- le débit
        capacity : integer := 224; --la capacité 
        state_length : integer := 256-- la taille de l'état interne
    );
    Port ( clk : in std_logic;
           rstn : in  std_logic;        
           message_data : in std_logic_vector(message_length-1 downto 0);
           --key_data : in std_logic_vector(key_length-1 downto 0);  
           hashed_value : out std_logic_vector (state_length - 1 downto 0);
           state : out std_logic_vector(state_length-1 downto 0)
    );
end quark_hash;

architecture Behavioral of quark_hash is
--------------- functions ---------------
-- reverse order of std_logic_vector
function reverse_any_vector (a: in std_logic_vector)
return std_logic_vector is
  variable result: std_logic_vector(a'RANGE);
  alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
begin
  for i in aa'RANGE loop
    result(i) := aa(i);
  end loop;
  return result;
end; -- function reverse_any_vector
----- math function
function log2ceil(m : in integer)
return integer is
begin
  for i in 0 to integer'high loop
        if 2 ** i >= m then
            return i;
        end if;
    end loop;
end function log2ceil;
----------- components -------------------
    -- initialization component
    component quark_initialize is
        Generic(
            rate : integer := 32;
            message_length : integer := 0
        );
        Port(
            message : in std_logic_vector(message_length - 1 downto 0 );
            new_message : out std_logic_vector(message_length + rate -1 downto 0); -- the maximum length of the message is message_length + rate
            new_message_length : out integer 
        );
     end component;
     -- absorbing phase component
     component quark_absorb is
     --  Port ( );
         generic(
             rate : integer := 32;
             message_length : integer := 32;
             state_length : integer := 256
         );
         port(
            reset : in std_logic;
            clk : in std_logic;
             message : in std_logic_vector(message_length-1 downto 0);
             state : out std_logic_vector(state_length-1 downto 0)
         );
         
     end component;
-------------------------------------------------------------------------
     --signals
     --- signals of components
     signal new_message_length : integer;
     signal new_message : std_logic_vector(message_length + rate -1 downto 0);
     --- signals for quark
     signal internal_state : std_logic_vector(state_length-1 downto 0) ;
     signal xored_state : std_logic_vector(state_length-1 downto 0);
     signal permuted_state : std_logic_vector(state_length-1 downto 0);
     signal message_block : std_logic_vector(rate-1 downto 0);
     ---- signals for permutation
     signal X, next_X, Y, next_Y : std_logic_vector(state_length/2-1 downto 0);
     signal L, next_L : std_logic_vector(log2ceil( 4*state_length)-1 downto 0);
     signal h, next_h, F, G, P : std_logic;
     ---- compteur des coups d'horloge
     signal compteur : integer := 0;
     signal Initial_phase : std_logic := '1';
     --- constants
     constant IN_STATE : std_logic_vector(state_length-1 downto 0) := x"397251CEE1DE8AA73EA26250C6D7BE128CD3E79DD718C24B8A19D09C2492DA5D";
----------------------------------------------------------------------------
begin

initialization : quark_initialize
    generic map( message_length => 0 )
    port map (
              message => message_data,
              new_message => new_message,
              new_message_length => new_message_length
              );
--------------------------------------------------------
-- get the message block
message_block <= new_message((compteur+1)*rate -1 downto compteur*rate);
-- current state xor message
internal_state <= In_STATE when initial_phase = '1';
xored_state(rate -1 downto 0) <= reverse_any_vector(message_block) xor internal_state(rate-1 downto 0);
----
h <= L(0) xor X(1) xor Y(3) xor X(7) xor Y(18) xor Y(34) xor X(47) xor X(58) xor Y(71) xor Y(80) xor X(90) xor Y(91) xor X(105) xor Y(111) xor (Y(8) and X(100)) xor (X(72) and X(100)) xor (X(100) and Y(111)) xor (Y(8) and X(47) and X(72)) xor (Y(8) and X(72) and X(100)) xor (Y(8) and X(72) and Y(111)) xor (L(0) and X(47) and X(72) and Y(111)) xor (L(0) and X(47));
P <= L(0) xor L(3);
F <= X(0) xor X(16) xor X(26) xor X(39) xor X(52) xor X(61) xor X(69) xor X(84) xor X(94) xor X(97) xor X(103) xor (X(103) and X(111)) xor (X(61) and X(69)) xor (X(16) and X(28)) xor (X(84) and X(97) and X(103)) xor (X(39) and X(52) and X(61)) xor (X(16) and X(52) and X(84) and X(111)) xor (X(61) and X(69) and X(97) and X(103)) xor (X(28) and X(39) and X(103) and X(111)) xor (X(69) and X(84) and X(97) and X(103) and X(111)) xor (X(16) and X(28) and X(39) and X(52) and X(61)) xor (X(39) and X(52) and X(61) and X(69) and X(84) and X(97));
G <= Y(0) xor Y(13) xor Y(30) xor Y(37) xor Y(56) xor Y(65) xor Y(69) xor Y(79) xor Y(92) xor Y(96) xor Y(101) xor (Y(101) and Y(109)) xor (Y(65) and Y(69)) xor (Y(13) and Y(28)) xor (Y(79) and Y(96) and Y(101)) xor (Y(37) and Y(56) and Y(65)) xor (Y(13) and Y(56) and Y(79) and Y(109)) xor (Y(65) and Y(69) and Y(96) and Y(101)) xor (Y(28) and Y(37) and Y(101) and Y(109)) xor (Y(69) and Y(79) and Y(96) and Y(101) and Y(109)) xor (Y(13) and Y(28) and Y(37) and Y(56) and Y(65)) xor (Y(37) and Y(56) and Y(65) and Y(69) and Y(79) and Y(96));
--- update X, Y and L
next_X <= X(state_length/2 - 2 downto 0) & (Y(0) xor F xor h);
next_Y <= Y(state_length/2 -2 downto 0) & (G xor h);
next_L <= L(log2ceil( 4*state_length) -2 downto 0) & P;
--------update state
permuted_state <= X & Y;




-- programe général
process(clk, rstn)
    begin
    if rstn='0' then
        hashed_value <= (others => '0');
    elsif clk'event and clk='1' then
        --incrementer le compteur
        compteur <= compteur + 1;
        if compteur < new_message_length/rate then -- Absorbing phase
            internal_state <= permuted_state;
            X <= next_X;
            Y <= next_Y;
            L <= next_L;
        end if;
    end if;
end process;
state <= permuted_state;     

end Behavioral;
