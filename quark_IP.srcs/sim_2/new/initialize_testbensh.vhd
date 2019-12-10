library ieee;
use ieee.std_logic_1164.all;

entity initialize_testbench is
end initialize_testbench;

architecture tb of initialize_testbench is

    component quark_initialize
        Generic(
            rate : integer := 32;
            message_length : integer := 256
        );
        Port(
            message : in std_logic_vector(message_length - 1 downto 0 );
            new_message : out std_logic_vector(message_length + rate -1 downto 0); -- the maximum length of the message is message_length + rate
            new_message_length : out integer 
        );
    end component;

    signal message : std_logic_vector (255 downto 0);
    signal new_message : std_logic_vector (256+32-1 downto 0);
    signal new_message_length : integer;
    

begin

    dut : quark_initialize
    port map (
              message => message,
              new_message => new_message,
              new_message_length => new_message_length
              );

    stimuli : process
    begin
        
        message <= (others => '0');
        
        
        wait;
    end process;
end tb;
-- Configuration block below is required by some simulators. Usually no need to edit.
            
configuration cfg_tb_quark_initialize of initialize_testbench is
    for tb
    end for;
end tb_quark_initialize;