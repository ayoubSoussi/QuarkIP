library ieee;
use ieee.std_logic_1164.all;

entity tb_top_level is
end tb_top_level;

architecture tb of tb_top_level is

    component quark_hash
        generic (
                message_length : integer := 0; -- la longueur du message
                key_length : integer := 100; 
                s_Interface : integer := 256; -- la taille de la sortie
                rate : integer := 32; -- le débit
                capacity : integer := 224; --la capacité 
                state_length : integer := 256-- la taille de l'état interne
        );
        port (clk          : in std_logic;
              rstn         : in std_logic;
              --key_data     : in std_logic_vector (s_interface-1 downto 0);
              message_data : in std_logic_vector (message_length-1 downto 0);
              hashed_value : out std_logic_vector (state_length-1 downto 0);
              state : out std_logic_vector(state_length-1 downto 0));
    end component;

    signal clk          : std_logic;
    signal rstn         : std_logic;
    --signal key_data     : std_logic_vector (s_interface-1 downto 0);
    signal message_data : std_logic_vector (-1 downto 0);
    signal hashed_value : std_logic_vector (256-1 downto 0);
    signal state : std_logic_vector (255 downto 0);
    
    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : quark_hash
    port map (clk          => clk,
              rstn         => rstn,
              --key_data     => key_data,
              message_data => message_data,
              hashed_value => hashed_value,
              state => state
              );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        --key_data <= (others => '0');
        message_data <= (others => '0');

        -- Reset generation
        -- EDIT: Check that rstn is really your reset signal
        rstn <= '0';
        wait for 100 ns;
        rstn <= '1';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '0';
        wait;
    end process;
end tb;
-- Configuration block below is required by some simulators. Usually no need to edit.
            
configuration cfg_tb_top_level of tb_top_level is
    for tb
    end for;
end cfg_tb_top_level;