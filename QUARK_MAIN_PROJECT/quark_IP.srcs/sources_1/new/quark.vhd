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


-- entity
entity quark is
    generic(MESSAGE_LENGTH : integer;
                KEY_LENGTH : integer;
                HASH_LENGTH : integer := 136;
                CYCLES_PER_PERMUTATION : integer := 4;
                -- Quark parameters
                RATE : integer := 8;
                STATE_LENGTH : integer := 136;
                CEIL : integer := 10; -- for all quark instances
                SQUEEZZE_STEPS : integer :=  17; -- HASH_LENGTH/RATE
                XY_LENGTH : integer := 68 -- STATE_LENGTH/2
                );
    Port ( clk : in std_logic;
           rstn : in  std_logic;        
           message_data : in std_logic_vector(MESSAGE_LENGTH-1 downto 0);
           key_data : in std_logic_vector(KEY_LENGTH-1 downto 0);  
           hashed_value : out std_logic_vector (HASH_LENGTH - 1 downto 0);
           output_ready : out std_logic
    );
end quark;

architecture Behavioral of quark is
------------ constants----------------
constant APPENDED_MESSAGE_LENGTH : integer := ((MESSAGE_LENGTH + KEY_LENGTH + 1) + RATE - ((MESSAGE_LENGTH + KEY_LENGTH + 1) mod RATE));
constant MESSAGE_BLOCKS : integer := APPENDED_MESSAGE_LENGTH/RATE;
constant PERMUTE_ITERATIONS_PER_CYCLE : integer := 4*STATE_LENGTH/CYCLES_PER_PERMUTATION;
constant XY_TOTAL_LENGTH : integer := (PERMUTE_ITERATIONS_PER_CYCLE+1)*XY_LENGTH;-- (PERMUTE_ITERATIONS_PER_CYCLE+1)*XY_LENGTH
constant L_TOTAL_LENGTH : integer := (PERMUTE_ITERATIONS_PER_CYCLE+1)*CEIL;   -- (PERMUTE_ITERATIONS_PER_CYCLE+1)*CEIL

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
            rate : integer := RATE;
            message_length : integer := MESSAGE_LENGTH;
            key_length : integer := KEY_LENGTH;
            new_message_length : integer
        );
        Port(
            message_data : in std_logic_vector(MESSAGE_LENGTH - 1 downto 0 );
            key_data : in std_logic_vector(KEY_LENGTH - 1 downto 0 );
            new_message : out std_logic_vector(APPENDED_MESSAGE_LENGTH -1 downto 0) -- the maximum length of the message is message_length + rate
            
        );
     end component;
     
     
     -- permutation iteration component
     component permute_iteration is
        generic(
            state_length : integer
            );
         port(  
                X, Y : in std_logic_vector(XY_LENGTH-1 downto 0);
                L : in std_logic_vector(CEIL-1 downto 0);
                next_X, next_Y : out std_logic_vector(XY_LENGTH-1 downto 0);
                next_L : out std_logic_vector(CEIL-1 downto 0)
         );
     end component;
-------------------------------------------------------------------------
     -- types
     type PHASE is (init, absorb, squeeze); 
     --signals
     --- signals of components
     signal new_message : std_logic_vector(APPENDED_MESSAGE_LENGTH -1 downto 0);
     --- signals for quark
     signal internal_state : std_logic_vector(STATE_LENGTH-1 downto 0) ;
     signal xored_state : std_logic_vector(STATE_LENGTH-1 downto 0);
     signal permuted_state : std_logic_vector(STATE_LENGTH-1 downto 0);
     signal message_block : std_logic_vector(RATE-1 downto 0);
     ---- signals for permutation
     signal X, Y : std_logic_vector(XY_TOTAL_LENGTH-1 downto 0);
     signal L : std_logic_vector(L_TOTAL_LENGTH-1 downto 0);
     signal new_X, new_Y : std_logic_vector(XY_LENGTH-1 downto 0);
     signal new_L : std_logic_vector(CEIL-1 downto 0);
     
     ---- compteur des coups d'horloge
     signal compteur : integer ;
     signal compteur_block : integer ;
     signal compteur_permute : integer; -- compteur des cycles d'une seule permutation
     signal compteur_squeeze : integer;
     signal quark_phase : PHASE ; -- the current phase of the quark
     
----------------------------------------------------------------------------
begin

-- generating new message after initialisation
new_message(message_length + key_length - 1 downto 0 ) <= message_data & key_data;
new_message(message_length + key_length) <= '1';
new_message(APPENDED_MESSAGE_LENGTH - 1 downto message_length + key_length + 1) <= (others =>'0');
--initialization : quark_initialize
--    Generic map (
--            rate => RATE,
--            message_length => MESSAGE_LENGTH,
--            key_length => KEY_LENGTH,
--            new_message_length => APPENDED_MESSAGE_LENGTH
--        )
--    port map (
--              message_data => message_data,
--              key_data => key_data,
--              new_message => new_message
--              );
----------------------------------------------------------------------------
-- get the message block
message_block <= new_message((compteur_block+1)*RATE -1 downto (compteur_block)*RATE) when (quark_phase = absorb and compteur_block < MESSAGE_BLOCKS ) else (others => '0');

-- Update X, Y and L
X(XY_TOTAL_LENGTH - 1 downto XY_TOTAL_LENGTH - XY_LENGTH) <= xored_state(STATE_LENGTH-1 downto XY_LENGTH) when ( quark_phase /= init and compteur_permute = 0) else new_X;
Y(XY_TOTAL_LENGTH - 1 downto XY_TOTAL_LENGTH - XY_LENGTH) <= xored_state(XY_LENGTH-1 downto 0) when (quark_phase /= init and compteur_permute = 0) else new_Y;
L(L_TOTAL_LENGTH - 1 downto L_TOTAL_LENGTH - CEIL) <= (others => '1') when (quark_phase /= init and compteur_permute=0) else new_L;
            
            
            
-- current state xor message
xored_state(RATE -1 downto 0) <= internal_state(RATE-1 downto 0) when (quark_phase = squeeze) else reverse_any_vector(message_block) xor internal_state(RATE-1 downto 0) ;
xored_state(STATE_LENGTH-1 downto RATE) <= internal_state(STATE_LENGTH-1 downto RATE);


PERMUTATION : 
    for I in 0 to PERMUTE_ITERATIONS_PER_CYCLE - 1 generate
       PERMUT_ITER : permute_iteration
                    generic map(state_length => STATE_LENGTH) 
                    port map
                   (X => X(XY_TOTAL_LENGTH - I*XY_LENGTH - 1 downto XY_TOTAL_LENGTH - (I+1)*XY_LENGTH),
                    Y => Y(XY_TOTAL_LENGTH - I*XY_LENGTH - 1 downto XY_TOTAL_LENGTH - (I+1)*XY_LENGTH),
                    L => L(L_TOTAL_LENGTH - I*CEIL - 1 downto L_TOTAL_LENGTH - (I+1)*CEIL),
                    next_X => X(XY_TOTAL_LENGTH - (I+1)*XY_LENGTH - 1 downto XY_TOTAL_LENGTH - (I+2)*XY_LENGTH),
                    next_Y => Y(XY_TOTAL_LENGTH - (I+1)*XY_LENGTH - 1 downto XY_TOTAL_LENGTH - (I+2)*XY_LENGTH),
                    next_L => L(L_TOTAL_LENGTH - (I+1)*CEIL - 1 downto L_TOTAL_LENGTH - (I+2)*CEIL)
                    );
    end generate;



--------update state
permuted_state <= internal_state when (quark_phase = init) else X(XY_LENGTH - 1 downto 0) & Y(XY_LENGTH - 1 downto 0) ;


-- Main program
process(clk, rstn)
    begin
    if rstn = '0' then
        --  reinitialize all signals
        hashed_value <= (others => '0');
        output_ready <= '0';
        compteur <= 0;
        compteur_block <= 0;
        compteur_permute <= 0;
        compteur_squeeze <= 0;
        -- initialize the internal state
        if ( HASH_LENGTH = 136) then
            internal_state <= x"D8DACA44414A099719C80AA3AF065644DB"; -- u-quark case
        elsif (HASH_LENGTH = 176) then
            internal_state <= x"CC6C4AB7D11FA9BDF6EEDE03D87B68F91BAA706C20E9"; -- d-quark case
        elsif ( HASH_LENGTH = 256 ) then
            internal_state <= x"397251CEE1DE8AA73EA26250C6D7BE128CD3E79DD718C24B8A19D09C2492DA5D"; -- s-quark case        
        end if;
 
        
    elsif clk'event and clk='1' then
        
        -- calculate the iteration of the permute function
        compteur_permute <= compteur mod CYCLES_PER_PERMUTATION; 
        compteur_block <= compteur/CYCLES_PER_PERMUTATION;
         
        
        -- update the state
        if (compteur >= 1 ) then         
            internal_state <= permuted_state;
        end if;
        new_X <= X(XY_LENGTH - 1 downto 0);
        new_Y <= Y(XY_LENGTH - 1 downto 0);
        new_L <= L(CEIL - 1 downto 0);
       
        --incrementer le compteur
        compteur <= compteur + 1;
        
        -- génerer la sortie
        if (quark_phase = squeeze and compteur_permute = 0 and compteur_squeeze < SQUEEZZE_STEPS) then -- before the permute in squeeze phase
            hashed_value(HASH_LENGTH - compteur_squeeze*RATE - 1 downto HASH_LENGTH - (compteur_squeeze+1)*RATE) <= internal_state(RATE-1 downto 0);
            compteur_squeeze <= compteur_squeeze + 1;   
        end if;
        
        -- notify that the output is ready
        if ( compteur_squeeze*RATE = HASH_LENGTH ) then
            output_ready <= '1';
        end if;    
        
    end if;
end process;    

-- State machine
process(compteur_block, rstn)
begin 
    if rstn='0' then
        quark_phase <= init;
    else
        if compteur_block < MESSAGE_BLOCKS  then   
            quark_phase <= absorb;
        else
            quark_phase <= squeeze;
        end if;
   end if;
end process;



end Behavioral;