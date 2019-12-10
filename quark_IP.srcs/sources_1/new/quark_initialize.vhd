----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2019 03:02:57 PM
-- Design Name: 
-- Module Name: quark_initialize - Behavioral
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

entity quark_initialize is
    Generic(
        rate : integer := 32;
        message_length : integer := 0
    );
    Port(
        message : in std_logic_vector(message_length - 1 downto 0 );
        new_message : out std_logic_vector(message_length + rate -1 downto 0); -- the maximum length of the message is message_length + rate
        new_message_length : out integer 
    );

end quark_initialize;

architecture Behavioral of quark_initialize is
signal cmp : integer:=message_length + 1; -- adding 1 after appending '1' to the message
begin


process(message, cmp)
begin
    if message_length /= 0 then
        new_message(message_length-1 downto 0 ) <= message(message_length-1 downto 0);
    end if;
    
    new_message(message_length) <= '1';
    for I in 0 to rate-1 loop
        if cmp mod rate = 0 then
            exit;
        else
            new_message(cmp) <= '0';
            cmp <= cmp + 1;
        end if;
    end loop;
    new_message_length <= cmp;
end process;

end Behavioral;
