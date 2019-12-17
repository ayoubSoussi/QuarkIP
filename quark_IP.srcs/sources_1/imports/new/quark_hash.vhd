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
           hashed_value : out std_logic_vector (s_Interface - 1 downto 0)
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
-------------------------------------------------------------------------
     -- types
     type PHASE is (init, absorb, squeeze); 
     -- constants 
     constant IN_STATE : std_logic_vector(state_length-1 downto 0) := x"397251CEE1DE8AA73EA26250C6D7BE128CD3E79DD718C24B8A19D09C2492DA5D";
     constant CEIL : integer := 10;
     --signals
     --- signals of components
     signal new_message_length : integer;
     signal new_message : std_logic_vector(message_length + rate -1 downto 0);
     --- signals for quark
     signal internal_state : std_logic_vector(state_length-1 downto 0) ;
     signal xored_state : std_logic_vector(state_length-1 downto 0);
     signal permuted_state : std_logic_vector(state_length-1 downto 0);
     --signal next_permuted_state : std_logic_vector(state_length-1 downto 0);
     signal message_block : std_logic_vector(rate-1 downto 0);
     ---- signals for permutation
     signal X, next_X, Y, next_Y : std_logic_vector(state_length/2-1 downto 0);
     signal L, next_L : std_logic_vector(CEIL-1 downto 0);
     signal h, F, G, P : std_logic;
     ---- compteur des coups d'horloge
     signal compteur : integer ;
     signal compteur_block : integer ;
     signal compteur_permute : integer; -- compteur des cycles d'une seule permutation
     signal compteur_squeeze : integer;
     signal quark_phase : PHASE ; -- the current phase of the quark
     
      
     
     
----------------------------------------------------------------------------
begin

initialization : quark_initialize
    generic map( message_length => 0 )
    port map (
              message => message_data,
              new_message => new_message,
              new_message_length => new_message_length
              );
----------------------------------------------------------------------------
-- get the message block
message_block <= new_message((compteur_block+1)*rate -1 downto (compteur_block)*rate) when (quark_phase = absorb ) else (others => '0');


-- current state xor message
xored_state(rate -1 downto 0) <= internal_state(rate-1 downto 0) when (quark_phase = squeeze) else reverse_any_vector(message_block) xor internal_state(rate-1 downto 0) ;
xored_state(state_length-1 downto rate) <= internal_state(state_length-1 downto rate);


----
-- TODO:
-- vérifier les valeurs de X, Y et L et comparer
-- a quoi sert le next_h ????



h <= reverse_any_vector(L)(0) xor reverse_any_vector(X)(1) xor reverse_any_vector(Y)(3) xor reverse_any_vector(X)(7) xor reverse_any_vector(Y)(18) xor reverse_any_vector(Y)(34) xor reverse_any_vector(X)(47) xor reverse_any_vector(X)(58) xor reverse_any_vector(Y)(71) xor reverse_any_vector(Y)(80) xor reverse_any_vector(X)(90) xor reverse_any_vector(Y)(91) xor reverse_any_vector(X)(105) xor reverse_any_vector(Y)(111) xor (reverse_any_vector(Y)(8) and reverse_any_vector(X)(100)) xor (reverse_any_vector(X)(72) and reverse_any_vector(X)(100)) xor (reverse_any_vector(X)(100) and reverse_any_vector(Y)(111)) xor (reverse_any_vector(Y)(8) and reverse_any_vector(X)(47) and reverse_any_vector(X)(72)) xor (reverse_any_vector(Y)(8) and reverse_any_vector(X)(72) and reverse_any_vector(X)(100)) xor (reverse_any_vector(Y)(8) and reverse_any_vector(X)(72) and reverse_any_vector(Y)(111)) xor (reverse_any_vector(L)(0) and reverse_any_vector(X)(47) and reverse_any_vector(X)(72) and reverse_any_vector(Y)(111)) xor (reverse_any_vector(L)(0) and reverse_any_vector(X)(47));
P <= reverse_any_vector(L)(0) xor reverse_any_vector(L)(3);
F <= reverse_any_vector(X)(0) xor reverse_any_vector(X)(16) xor reverse_any_vector(X)(26) xor reverse_any_vector(X)(39) xor reverse_any_vector(X)(52) xor reverse_any_vector(X)(61) xor reverse_any_vector(X)(69) xor reverse_any_vector(X)(84) xor reverse_any_vector(X)(94) xor reverse_any_vector(X)(97) xor reverse_any_vector(X)(103) xor (reverse_any_vector(X)(103) and reverse_any_vector(X)(111)) xor (reverse_any_vector(X)(61) and reverse_any_vector(X)(69)) xor (reverse_any_vector(X)(16) and reverse_any_vector(X)(28)) xor (reverse_any_vector(X)(84) and reverse_any_vector(X)(97) and reverse_any_vector(X)(103)) xor (reverse_any_vector(X)(39) and reverse_any_vector(X)(52) and reverse_any_vector(X)(61)) xor (reverse_any_vector(X)(16) and reverse_any_vector(X)(52) and reverse_any_vector(X)(84) and reverse_any_vector(X)(111)) xor (reverse_any_vector(X)(61) and reverse_any_vector(X)(69) and reverse_any_vector(X)(97) and reverse_any_vector(X)(103)) xor (reverse_any_vector(X)(28) and reverse_any_vector(X)(39) and reverse_any_vector(X)(103) and reverse_any_vector(X)(111)) xor (reverse_any_vector(X)(69) and reverse_any_vector(X)(84) and reverse_any_vector(X)(97) and reverse_any_vector(X)(103) and reverse_any_vector(X)(111)) xor (reverse_any_vector(X)(16) and reverse_any_vector(X)(28) and reverse_any_vector(X)(39) and reverse_any_vector(X)(52) and reverse_any_vector(X)(61)) xor (reverse_any_vector(X)(39) and reverse_any_vector(X)(52) and reverse_any_vector(X)(61) and reverse_any_vector(X)(69) and reverse_any_vector(X)(84) and reverse_any_vector(X)(97));
G <= reverse_any_vector(Y)(0) xor reverse_any_vector(Y)(13) xor reverse_any_vector(Y)(30) xor reverse_any_vector(Y)(37) xor reverse_any_vector(Y)(56) xor reverse_any_vector(Y)(65) xor reverse_any_vector(Y)(69) xor reverse_any_vector(Y)(79) xor reverse_any_vector(Y)(92) xor reverse_any_vector(Y)(96) xor reverse_any_vector(Y)(101) xor (reverse_any_vector(Y)(101) and reverse_any_vector(Y)(109)) xor (reverse_any_vector(Y)(65) and reverse_any_vector(Y)(69)) xor (reverse_any_vector(Y)(13) and reverse_any_vector(Y)(28)) xor (reverse_any_vector(Y)(79) and reverse_any_vector(Y)(96) and reverse_any_vector(Y)(101)) xor (reverse_any_vector(Y)(37) and reverse_any_vector(Y)(56) and reverse_any_vector(Y)(65)) xor (reverse_any_vector(Y)(13) and reverse_any_vector(Y)(56) and reverse_any_vector(Y)(79) and reverse_any_vector(Y)(109)) xor (reverse_any_vector(Y)(65) and reverse_any_vector(Y)(69) and reverse_any_vector(Y)(96) and reverse_any_vector(Y)(101)) xor (reverse_any_vector(Y)(28) and reverse_any_vector(Y)(37) and reverse_any_vector(Y)(101) and reverse_any_vector(Y)(109)) xor (reverse_any_vector(Y)(69) and reverse_any_vector(Y)(79) and reverse_any_vector(Y)(96) and reverse_any_vector(Y)(101) and reverse_any_vector(Y)(109)) xor (reverse_any_vector(Y)(13) and reverse_any_vector(Y)(28) and reverse_any_vector(Y)(37) and reverse_any_vector(Y)(56) and reverse_any_vector(Y)(65)) xor (reverse_any_vector(Y)(37) and reverse_any_vector(Y)(56) and reverse_any_vector(Y)(65) and reverse_any_vector(Y)(69) and reverse_any_vector(Y)(79) and reverse_any_vector(Y)(96));
--- update X, Y and L
next_X <= xored_state(state_length-1 downto state_length/2) when (quark_phase /= init and compteur_permute = 0) else X(state_length/2 - 2 downto 0) & (reverse_any_vector(Y)(0) xor F xor h) when quark_phase /= init;
next_Y <= xored_state(state_length/2-1 downto 0) when (quark_phase /= init and compteur_permute = 0) else Y(state_length/2 -2 downto 0) & (G xor h) when quark_phase /= init;
next_L <= (others => '1') when (quark_phase /= init and compteur_permute=0) else L(CEIL -2 downto 0) & P when quark_phase /= init ;
--------update state
permuted_state <= internal_state when (quark_phase = init) else next_X & next_Y ;




-- programe général
process(clk, rstn)
    begin
    if rstn='0' then
        hashed_value <= (others => '0');
        compteur <= 0;
        compteur_block <= 0;
        compteur_permute <= 0;
        compteur_squeeze <= 0;
        
        quark_phase <= init;
        internal_state <= x"397251CEE1DE8AA73EA26250C6D7BE128CD3E79DD718C24B8A19D09C2492DA5D";
        L <= (others=> '1');
 --       permuted_state <= x"397251CEE1DE8AA73EA26250C6D7BE128CD3E79DD718C24B8A19D09C2492DA5D";
    elsif clk'event and clk='1' then
        
        if compteur < (4*s_Interface+1)*new_message_length/rate then
        -- phase d'absorption
            quark_phase <= absorb;
            compteur_block <= compteur/(4*s_Interface+1);
            
        else 
            quark_phase <= squeeze;
        end if;
        -- calculate the iteration of the permute function
        compteur_permute <= compteur mod (4*s_Interface+1);
        -- update the state         
        internal_state <= permuted_state;
        L <= next_L;
        X <= next_X;
        Y <= next_Y;
        
        --incrementer le compteur
        compteur <= compteur + 1;
        
        -- génerer la sortie
        if (quark_phase = squeeze and compteur_permute = 0 and compteur_squeeze < s_Interface/rate) then -- before the permute in squeeze phase
            hashed_value(s_Interface - compteur_squeeze*rate - 1 downto s_Interface - (compteur_squeeze+1)*rate) <= internal_state(rate-1 downto 0);
            compteur_squeeze <= compteur_squeeze + 1;       
        end if;
        
    end if;
end process;     

end Behavioral;
