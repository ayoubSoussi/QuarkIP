----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/19/2019 02:26:41 PM
-- Design Name: 
-- Module Name: permute_iteration - Behavioral
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

entity permute_iteration is
--  Port ( );
    generic( 
            state_length : integer := 256;
            CEIL : integer := 10);
    port(
            X, Y : in std_logic_vector(state_length/2-1 downto 0);
            L : in std_logic_vector(CEIL-1 downto 0);
            next_X, next_Y : out std_logic_vector(state_length/2-1 downto 0);
            next_L : out std_logic_vector(CEIL-1 downto 0)
            );
end permute_iteration;

architecture Behavioral of permute_iteration is
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

-- signals
signal h, F, G, P : std_logic;


begin
-- update h
WITH state_length SELECT
    -- case of S-QUARK
    h <= reverse_any_vector(L)(0) xor reverse_any_vector(X)(1) xor reverse_any_vector(Y)(3) xor reverse_any_vector(X)(7) xor reverse_any_vector(Y)(18) xor reverse_any_vector(Y)(34) xor reverse_any_vector(X)(47) xor reverse_any_vector(X)(58) xor reverse_any_vector(Y)(71) xor reverse_any_vector(Y)(80) xor reverse_any_vector(X)(90) xor reverse_any_vector(Y)(91) xor reverse_any_vector(X)(105) xor reverse_any_vector(Y)(111) xor (reverse_any_vector(Y)(8) and reverse_any_vector(X)(100)) xor (reverse_any_vector(X)(72) and reverse_any_vector(X)(100)) xor (reverse_any_vector(X)(100) and reverse_any_vector(Y)(111)) xor (reverse_any_vector(Y)(8) and reverse_any_vector(X)(47) and reverse_any_vector(X)(72)) xor (reverse_any_vector(Y)(8) and reverse_any_vector(X)(72) and reverse_any_vector(X)(100)) xor (reverse_any_vector(Y)(8) and reverse_any_vector(X)(72) and reverse_any_vector(Y)(111)) xor (reverse_any_vector(L)(0) and reverse_any_vector(X)(47) and reverse_any_vector(X)(72) and reverse_any_vector(Y)(111)) xor (reverse_any_vector(L)(0) and reverse_any_vector(X)(47)) when 256,
    -- case of U-QUARK     
         reverse_any_vector(L)(0) xor reverse_any_vector(X)(1) xor reverse_any_vector(Y)(2) xor reverse_any_vector(X)(4) xor reverse_any_vector(Y)(10) xor reverse_any_vector(X)(25) xor reverse_any_vector(X)(31) xor reverse_any_vector(Y)(43) xor reverse_any_vector(X)(56) xor reverse_any_vector(Y)(59) xor (reverse_any_vector(Y)(3) and reverse_any_vector(X)(55)) xor (reverse_any_vector(X)(46) and reverse_any_vector(X)(55)) xor (reverse_any_vector(X)(55) and reverse_any_vector(Y)(59)) xor (reverse_any_vector(Y)(3) and reverse_any_vector(X)(25) and reverse_any_vector(X)(46)) xor (reverse_any_vector(Y)(3) and reverse_any_vector(X)(46) and reverse_any_vector(X)(55)) xor (reverse_any_vector(Y)(3) and reverse_any_vector(X)(46) and reverse_any_vector(Y)(59)) xor (reverse_any_vector(L)(0) and reverse_any_vector(X)(25) and reverse_any_vector(X)(46) and reverse_any_vector(Y)(59)) xor (reverse_any_vector(L)(0) and reverse_any_vector(X)(25)) when 136,
    -- case of D-QUARK
         reverse_any_vector(L)(0) xor reverse_any_vector(X)(1) xor reverse_any_vector(Y)(2) xor reverse_any_vector(X)(5) xor reverse_any_vector(Y)(12) xor reverse_any_vector(Y)(24) xor reverse_any_vector(X)(35) xor reverse_any_vector(X)(40) xor reverse_any_vector(X)(48) xor reverse_any_vector(Y)(55) xor reverse_any_vector(Y)(61) xor reverse_any_vector(X)(72) xor reverse_any_vector(Y)(79) xor (reverse_any_vector(Y)(4) and reverse_any_vector(X)(68)) xor (reverse_any_vector(X)(57) and reverse_any_vector(X)(68)) xor (reverse_any_vector(X)(68) and reverse_any_vector(Y)(79)) xor (reverse_any_vector(Y)(4) and reverse_any_vector(X)(35) and reverse_any_vector(X)(57)) xor (reverse_any_vector(Y)(4) and reverse_any_vector(X)(57) and reverse_any_vector(X)(68)) xor (reverse_any_vector(Y)(4) and reverse_any_vector(X)(57) and reverse_any_vector(Y)(79)) xor (reverse_any_vector(L)(0) and reverse_any_vector(X)(35) and reverse_any_vector(X)(57) and reverse_any_vector(Y)(79)) xor (reverse_any_vector(L)(0) and reverse_any_vector(X)(35)) when 176,
         '0' when others;
-- update P         
P <= reverse_any_vector(L)(0) xor reverse_any_vector(L)(3);

-- update F
WITH state_length SELECT
    -- case of S-QUARK
    F <= reverse_any_vector(X)(0) xor reverse_any_vector(X)(16) xor reverse_any_vector(X)(26) xor reverse_any_vector(X)(39) xor reverse_any_vector(X)(52) xor reverse_any_vector(X)(61) xor reverse_any_vector(X)(69) xor reverse_any_vector(X)(84) xor reverse_any_vector(X)(94) xor reverse_any_vector(X)(97) xor reverse_any_vector(X)(103) xor (reverse_any_vector(X)(103) and reverse_any_vector(X)(111)) xor (reverse_any_vector(X)(61) and reverse_any_vector(X)(69)) xor (reverse_any_vector(X)(16) and reverse_any_vector(X)(28)) xor (reverse_any_vector(X)(84) and reverse_any_vector(X)(97) and reverse_any_vector(X)(103)) xor (reverse_any_vector(X)(39) and reverse_any_vector(X)(52) and reverse_any_vector(X)(61)) xor (reverse_any_vector(X)(16) and reverse_any_vector(X)(52) and reverse_any_vector(X)(84) and reverse_any_vector(X)(111)) xor (reverse_any_vector(X)(61) and reverse_any_vector(X)(69) and reverse_any_vector(X)(97) and reverse_any_vector(X)(103)) xor (reverse_any_vector(X)(28) and reverse_any_vector(X)(39) and reverse_any_vector(X)(103) and reverse_any_vector(X)(111)) xor (reverse_any_vector(X)(69) and reverse_any_vector(X)(84) and reverse_any_vector(X)(97) and reverse_any_vector(X)(103) and reverse_any_vector(X)(111)) xor (reverse_any_vector(X)(16) and reverse_any_vector(X)(28) and reverse_any_vector(X)(39) and reverse_any_vector(X)(52) and reverse_any_vector(X)(61)) xor (reverse_any_vector(X)(39) and reverse_any_vector(X)(52) and reverse_any_vector(X)(61) and reverse_any_vector(X)(69) and reverse_any_vector(X)(84) and reverse_any_vector(X)(97)) when 256,
    -- case of U-QUARK
         reverse_any_vector(X)(0) xor reverse_any_vector(X)(9) xor reverse_any_vector(X)(14) xor reverse_any_vector(X)(21) xor reverse_any_vector(X)(28) xor reverse_any_vector(X)(33) xor reverse_any_vector(X)(37) xor reverse_any_vector(X)(45) xor reverse_any_vector(X)(50) xor reverse_any_vector(X)(52) xor reverse_any_vector(X)(55) xor (reverse_any_vector(X)(55) and reverse_any_vector(X)(59)) xor (reverse_any_vector(X)(33) and reverse_any_vector(X)(37)) xor (reverse_any_vector(X)(9) and reverse_any_vector(X)(15)) xor (reverse_any_vector(X)(45) and reverse_any_vector(X)(52) and reverse_any_vector(X)(55)) xor (reverse_any_vector(X)(21) and reverse_any_vector(X)(28) and reverse_any_vector(X)(33)) xor (reverse_any_vector(X)(9) and reverse_any_vector(X)(28) and reverse_any_vector(X)(45) and reverse_any_vector(X)(59)) xor (reverse_any_vector(X)(33) and reverse_any_vector(X)(37) and reverse_any_vector(X)(52) and reverse_any_vector(X)(55)) xor (reverse_any_vector(X)(15) and reverse_any_vector(X)(21) and reverse_any_vector(X)(55) and reverse_any_vector(X)(59)) xor (reverse_any_vector(X)(37) and reverse_any_vector(X)(45) and reverse_any_vector(X)(52) and reverse_any_vector(X)(55) and reverse_any_vector(X)(59)) xor (reverse_any_vector(X)(9) and reverse_any_vector(X)(15) and reverse_any_vector(X)(21) and reverse_any_vector(X)(28) and reverse_any_vector(X)(33)) xor (reverse_any_vector(X)(21) and reverse_any_vector(X)(28) and reverse_any_vector(X)(33) and reverse_any_vector(X)(37) and reverse_any_vector(X)(45) and reverse_any_vector(X)(52)) when 136,
    -- case of D-QUARK
         reverse_any_vector(X)(0) xor reverse_any_vector(X)(11) xor reverse_any_vector(X)(18) xor reverse_any_vector(X)(27) xor reverse_any_vector(X)(36) xor reverse_any_vector(X)(42) xor reverse_any_vector(X)(47) xor reverse_any_vector(X)(58) xor reverse_any_vector(X)(64) xor reverse_any_vector(X)(67) xor reverse_any_vector(X)(71) xor (reverse_any_vector(X)(71) and reverse_any_vector(X)(79)) xor (reverse_any_vector(X)(42) and reverse_any_vector(X)(47)) xor (reverse_any_vector(X)(11) and reverse_any_vector(X)(19)) xor (reverse_any_vector(X)(58) and reverse_any_vector(X)(67) and reverse_any_vector(X)(71)) xor (reverse_any_vector(X)(27) and reverse_any_vector(X)(36) and reverse_any_vector(X)(42)) xor (reverse_any_vector(X)(11) and reverse_any_vector(X)(36) and reverse_any_vector(X)(58) and reverse_any_vector(X)(79)) xor (reverse_any_vector(X)(42) and reverse_any_vector(X)(47) and reverse_any_vector(X)(67) and reverse_any_vector(X)(71)) xor (reverse_any_vector(X)(19) and reverse_any_vector(X)(27) and reverse_any_vector(X)(71) and reverse_any_vector(X)(79)) xor (reverse_any_vector(X)(47) and reverse_any_vector(X)(58) and reverse_any_vector(X)(67) and reverse_any_vector(X)(71) and reverse_any_vector(X)(79)) xor (reverse_any_vector(X)(11) and reverse_any_vector(X)(19) and reverse_any_vector(X)(27) and reverse_any_vector(X)(36) and reverse_any_vector(X)(42)) xor (reverse_any_vector(X)(27) and reverse_any_vector(X)(36) and reverse_any_vector(X)(42) and reverse_any_vector(X)(47) and reverse_any_vector(X)(58) and reverse_any_vector(X)(67)) when 176,
         '0' when others;
-- update G
WITH state_length SELECT
    -- case of S-QUARK
    G <= reverse_any_vector(Y)(0) xor reverse_any_vector(Y)(13) xor reverse_any_vector(Y)(30) xor reverse_any_vector(Y)(37) xor reverse_any_vector(Y)(56) xor reverse_any_vector(Y)(65) xor reverse_any_vector(Y)(69) xor reverse_any_vector(Y)(79) xor reverse_any_vector(Y)(92) xor reverse_any_vector(Y)(96) xor reverse_any_vector(Y)(101) xor (reverse_any_vector(Y)(101) and reverse_any_vector(Y)(109)) xor (reverse_any_vector(Y)(65) and reverse_any_vector(Y)(69)) xor (reverse_any_vector(Y)(13) and reverse_any_vector(Y)(28)) xor (reverse_any_vector(Y)(79) and reverse_any_vector(Y)(96) and reverse_any_vector(Y)(101)) xor (reverse_any_vector(Y)(37) and reverse_any_vector(Y)(56) and reverse_any_vector(Y)(65)) xor (reverse_any_vector(Y)(13) and reverse_any_vector(Y)(56) and reverse_any_vector(Y)(79) and reverse_any_vector(Y)(109)) xor (reverse_any_vector(Y)(65) and reverse_any_vector(Y)(69) and reverse_any_vector(Y)(96) and reverse_any_vector(Y)(101)) xor (reverse_any_vector(Y)(28) and reverse_any_vector(Y)(37) and reverse_any_vector(Y)(101) and reverse_any_vector(Y)(109)) xor (reverse_any_vector(Y)(69) and reverse_any_vector(Y)(79) and reverse_any_vector(Y)(96) and reverse_any_vector(Y)(101) and reverse_any_vector(Y)(109)) xor (reverse_any_vector(Y)(13) and reverse_any_vector(Y)(28) and reverse_any_vector(Y)(37) and reverse_any_vector(Y)(56) and reverse_any_vector(Y)(65)) xor (reverse_any_vector(Y)(37) and reverse_any_vector(Y)(56) and reverse_any_vector(Y)(65) and reverse_any_vector(Y)(69) and reverse_any_vector(Y)(79) and reverse_any_vector(Y)(96)) when 256,
    -- case of U-QUARK     
         reverse_any_vector(Y)(0) xor reverse_any_vector(Y)(7) xor reverse_any_vector(Y)(16) xor reverse_any_vector(Y)(20) xor reverse_any_vector(Y)(30) xor reverse_any_vector(Y)(35) xor reverse_any_vector(Y)(37) xor reverse_any_vector(Y)(42) xor reverse_any_vector(Y)(49) xor reverse_any_vector(Y)(51) xor reverse_any_vector(Y)(54) xor (reverse_any_vector(Y)(54) and reverse_any_vector(Y)(58)) xor (reverse_any_vector(Y)(35) and reverse_any_vector(Y)(37)) xor (reverse_any_vector(Y)(7) and reverse_any_vector(Y)(15)) xor (reverse_any_vector(Y)(42) and reverse_any_vector(Y)(51) and reverse_any_vector(Y)(54)) xor (reverse_any_vector(Y)(20) and reverse_any_vector(Y)(30) and reverse_any_vector(Y)(35)) xor (reverse_any_vector(Y)(7) and reverse_any_vector(Y)(30) and reverse_any_vector(Y)(42) and reverse_any_vector(Y)(58)) xor (reverse_any_vector(Y)(35) and reverse_any_vector(Y)(37) and reverse_any_vector(Y)(51) and reverse_any_vector(Y)(54)) xor (reverse_any_vector(Y)(15) and reverse_any_vector(Y)(20) and reverse_any_vector(Y)(54) and reverse_any_vector(Y)(58)) xor (reverse_any_vector(Y)(37) and reverse_any_vector(Y)(42) and reverse_any_vector(Y)(51) and reverse_any_vector(Y)(54) and reverse_any_vector(Y)(58)) xor (reverse_any_vector(Y)(7) and reverse_any_vector(Y)(15) and reverse_any_vector(Y)(20) and reverse_any_vector(Y)(30) and reverse_any_vector(Y)(35)) xor (reverse_any_vector(Y)(20) and reverse_any_vector(Y)(30) and reverse_any_vector(Y)(35) and reverse_any_vector(Y)(37) and reverse_any_vector(Y)(42) and reverse_any_vector(Y)(51)) when 136,
    -- case of D-QUARK
         reverse_any_vector(Y)(0) xor reverse_any_vector(Y)(9) xor reverse_any_vector(Y)(20) xor reverse_any_vector(Y)(25) xor reverse_any_vector(Y)(38) xor reverse_any_vector(Y)(44) xor reverse_any_vector(Y)(47) xor reverse_any_vector(Y)(54) xor reverse_any_vector(Y)(63) xor reverse_any_vector(Y)(67) xor reverse_any_vector(Y)(69) xor (reverse_any_vector(Y)(69) and reverse_any_vector(Y)(78)) xor (reverse_any_vector(Y)(44) and reverse_any_vector(Y)(47)) xor (reverse_any_vector(Y)(9) and reverse_any_vector(Y)(19)) xor (reverse_any_vector(Y)(54) and reverse_any_vector(Y)(67) and reverse_any_vector(Y)(69)) xor (reverse_any_vector(Y)(25) and reverse_any_vector(Y)(38) and reverse_any_vector(Y)(44)) xor (reverse_any_vector(Y)(9) and reverse_any_vector(Y)(38) and reverse_any_vector(Y)(54) and reverse_any_vector(Y)(78)) xor (reverse_any_vector(Y)(44) and reverse_any_vector(Y)(47) and reverse_any_vector(Y)(67) and reverse_any_vector(Y)(69)) xor (reverse_any_vector(Y)(19) and reverse_any_vector(Y)(25) and reverse_any_vector(Y)(69) and reverse_any_vector(Y)(78)) xor (reverse_any_vector(Y)(47) and reverse_any_vector(Y)(54) and reverse_any_vector(Y)(67) and reverse_any_vector(Y)(69) and reverse_any_vector(Y)(78)) xor (reverse_any_vector(Y)(9) and reverse_any_vector(Y)(19) and reverse_any_vector(Y)(25) and reverse_any_vector(Y)(38) and reverse_any_vector(Y)(44)) xor (reverse_any_vector(Y)(25) and reverse_any_vector(Y)(38) and reverse_any_vector(Y)(44) and reverse_any_vector(Y)(47) and reverse_any_vector(Y)(54) and reverse_any_vector(Y)(67)) when 176,
         '0' when others;
         
--- update X, Y and L
next_X <= X(state_length/2 - 2 downto 0) & (reverse_any_vector(Y)(0) xor F xor h);
next_Y <= Y(state_length/2 -2 downto 0) & (G xor h);
next_L <= L(CEIL - 2 downto 0) & P  ;


end Behavioral;
