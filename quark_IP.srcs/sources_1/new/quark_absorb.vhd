----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2019 05:11:56 PM
-- Design Name: 
-- Module Name: quark_absorb - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity quark_absorb is
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
        state :out std_logic_vector(state_length-1 downto 0)
        --xored_state : out std_logic_vector(state_length-1 downto 0)
    );
    
end quark_absorb;

architecture Behavioral of quark_absorb is

------- math functions -------
function log2ceil(m : in integer)
return integer is
begin
  for i in 0 to integer'high loop
        if 2 ** i >= m then
            return i;
        end if;
    end loop;
end function log2ceil;

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

-- define functions used in the permute function
function p( L: in  std_logic_vector)
return std_logic is
begin
    return L(0) xor L(3);
end;
-----
function f(X: in std_logic_vector)
return std_logic is
begin
    return X(0) xor X(16) xor X(26) xor X(39) xor X(52) xor X(61) xor X(69) xor X(84) xor X(94) xor X(97) xor X(103) xor (X(103) and X(111)) xor (X(61) and X(69)) xor (X(16) and X(28)) xor (X(84) and X(97) and X(103)) xor (X(39) and X(52) and X(61)) xor (X(16) and X(52) and X(84) and X(111)) xor (X(61) and X(69) and X(97) and X(103)) xor (X(28) and X(39) and X(103) and X(111)) xor (X(69) and X(84) and X(97) and X(103) and X(111)) xor (X(16) and X(28) and X(39) and X(52) and X(61)) xor (X(39) and X(52) and X(61) and X(69) and X(84) and X(97));
end;
-----
function g(Y: in std_logic_vector)
return std_logic is
begin
    return Y(0) xor Y(13) xor Y(30) xor Y(37) xor Y(56) xor Y(65) xor Y(69) xor Y(79) xor Y(92) xor Y(96) xor Y(101) xor (Y(101) and Y(109)) xor (Y(65) and Y(69)) xor (Y(13) and Y(28)) xor (Y(79) and Y(96) and Y(101)) xor (Y(37) and Y(56) and Y(65)) xor (Y(13) and Y(56) and Y(79) and Y(109)) xor (Y(65) and Y(69) and Y(96) and Y(101)) xor (Y(28) and Y(37) and Y(101) and Y(109)) xor (Y(69) and Y(79) and Y(96) and Y(101) and Y(109)) xor (Y(13) and Y(28) and Y(37) and Y(56) and Y(65)) xor (Y(37) and Y(56) and Y(65) and Y(69) and Y(79) and Y(96));
end;
-----
function h(X, Y, L : in std_logic_vector)
return std_logic is
begin
    return L(0) xor X(1) xor Y(3) xor X(7) xor Y(18) xor Y(34) xor X(47) xor X(58) xor Y(71) xor Y(80) xor X(90) xor Y(91) xor X(105) xor Y(111) xor (Y(8) and X(100)) xor (X(72) and X(100)) xor (X(100) and Y(111)) xor (Y(8) and X(47) and X(72)) xor (Y(8) and X(72) and X(100)) xor (Y(8) and X(72) and Y(111)) xor (L(0) and X(47) and X(72) and Y(111)) xor (L(0) and X(47));
end;
-------------------------------
-- permute function : 
function permute(state : in std_logic_vector)
return std_logic_vector is
variable Xt, Yt : std_logic_vector(state_length/2-1 downto 0);
variable Lt : std_logic_vector(log2ceil( 4*state_length)-1 downto 0);
variable ht : std_logic;
begin
    Xt := state(state_length-1 downto state_length/2);
    yt := state(state_length/2-1 downto 0);
    Lt := (others => '1');
    for I in 0 to 4*state_length-1 loop
        ht := h(reverse_any_vector(Xt), reverse_any_vector(Yt), reverse_any_vector(Lt));
        Xt := (Yt(0) xor f(reverse_any_vector(Xt)) xor ht) & Xt(state_length/2-2 downto 0); 
        Yt := (g(reverse_any_vector(Yt)) xor ht) & Xt(state_length/2-2 downto 0);
        Lt := p(reverse_any_vector(Lt)) & Lt(log2ceil( 4*state_length)-2 downto 0);
    end loop;
    return Yt&Xt;
end;
-- signals --
signal internal_state : std_logic_vector(state_length-1 downto 0);
signal xored_state : std_logic_vector(state_length-1 downto 0);
signal pemuted_state : std_logic_vector(state_length-1 downto 0);
signal message_block : std_logic_vector(rate-1 downto 0);
-- begin the architecture
begin
    xored_state <= reverse_any_vector(message) xor internal_state(rate-1 downto 0);
    
process(clk, reset)
    variable last_r_bits : std_logic_vector(rate-1 downto 0) := (others=>'0');
    begin
    if reset='0' then
        internal_state <= x"397251CEE1DE8AA73EA26250C6D7BE128CD3E79DD718C24B8A19D09C2492DA5D";
    elsif clk'event and clk='1' then
        -- update the state
    end if;
end process;

end Behavioral;
