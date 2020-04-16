------------------------------------------
-- Description : This is a testbench to test that Quark supports different message and key lengths
              -- this testbech uses U-QUARK with MESSAGE_LENGTH = 16 and HASH_LENGTH = 4

-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity top_level_tb is
end top_level_tb;

architecture tb of top_level_tb is
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
-- components
    component quark_wrapper
--        generic(MESSAGE_LENGTH : integer := 256;
--                KEY_LENGTH : integer := 256;
--                HASH_LENGTH : integer := 136;
--                CYCLES_PER_PERMUTATION : integer := 4
--        );
        Port(
            clk : in  std_logic;
            rstn : in  std_logic;
            KEY_AXIS_TVALID : in  std_logic; 
            KEY_AXIS_TREADY : out  std_logic; 
            KEY_AXIS_TDATA : in  std_logic_vector(4-1 downto 0);
            PLAIN_AXIS_TVALID : in  std_logic;
            PLAIN_AXIS_TREADY : out  std_logic;
            PLAIN_AXIS_TDATA  : in  std_logic_vector(16-1 downto 0);
            ENCR_AXIS_TVALID  : out  std_logic;
            ENCR_AXIS_TREADY : in  std_logic;
            ENCR_AXIS_TDATA   : out  std_logic_vector(136-1 downto 0)--;
            );
    end component;

    signal clk          : std_logic;
    signal rstn         : std_logic;    
    signal KEY_AXIS_TVALID : std_logic; 
    signal KEY_AXIS_TREADY : std_logic; 
    signal KEY_AXIS_TDATA : std_logic_vector(4-1 downto 0);
    signal PLAIN_AXIS_TVALID : std_logic;
    signal PLAIN_AXIS_TREADY : std_logic;
    signal PLAIN_AXIS_TDATA  : std_logic_vector(16-1 downto 0);
    signal ENCR_AXIS_TVALID  : std_logic;
    signal ENCR_AXIS_TREADY  : std_logic;
    signal ENCR_AXIS_TDATA   : std_logic_vector(136-1 downto 0);
    
    signal expected_hash : std_logic_vector(136 - 1 downto 0);
    
    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    quark_dut : quark_wrapper 
--    generic map (MESSAGE_LENGTH => 16,
--                KEY_LENGTH => 4,
--                HASH_LENGTH => 136,
--                CYCLES_PER_PERMUTATION => 4
--        )
    Port map (
            clk => clk,
            rstn => rstn,
            KEY_AXIS_TVALID   => KEY_AXIS_TVALID,
            KEY_AXIS_TREADY   => KEY_AXIS_TREADY, 
            KEY_AXIS_TDATA    => KEY_AXIS_TDATA,
            PLAIN_AXIS_TVALID => PLAIN_AXIS_TVALID,
            PLAIN_AXIS_TREADY => PLAIN_AXIS_TREADY,
            PLAIN_AXIS_TDATA  => PLAIN_AXIS_TDATA,
            ENCR_AXIS_TVALID  => ENCR_AXIS_TVALID,
            ENCR_AXIS_TREADY  => ENCR_AXIS_TREADY,
            ENCR_AXIS_TDATA   => ENCR_AXIS_TDATA
            );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        ----------------------------------------- test 1 ------------------------------------------------------------------
        -- reverse vector because the python implementation process data in little endianess and this IP uses Big endianess
        PLAIN_AXIS_TDATA <= reverse_any_vector(x"6D7B");
        KEY_AXIS_TDATA   <= reverse_any_vector(x"2");
        expected_hash    <= x"D972EE36465FCEA9E9A170848911209ACD"; 
        ---------
        rstn <= '0';
        PLAIN_AXIS_TVALID <= '0';
        KEY_AXIS_TVALID <= '0';
        ENCR_AXIS_TREADY <= '0';
        
        wait for 100 ns;
        rstn <= '1';
        wait for 100 ns;
        PLAIN_AXIS_TVALID <= '1';
        wait for 100 ns;
        KEY_AXIS_TVALID <= '1';
        wait for 100 ns;
        PLAIN_AXIS_TVALID <= '0';
        wait for 100 ns;
        KEY_AXIS_TVALID <= '0';
        
        wait for 1500 ns;
        ENCR_AXIS_TREADY <= '1';
        assert (ENCR_AXIS_TDATA /= expected_hash) report "Test 1 is correct" severity note;
        wait for 100 ns;
        ENCR_AXIS_TREADY <= '0';
        
        ----------------------------------------- test 2 ------------------------------------------------------------------
        -- reverse vector because the python implementation process data in little endianess and this IP uses Big endianess
        PLAIN_AXIS_TDATA <= (others => '0');
        KEY_AXIS_TDATA   <= (others => '0');
        expected_hash    <= x"2e5bdd40e91a2fbbb2123ceed5c3844674"; 
        ---------
        rstn <= '0';
        PLAIN_AXIS_TVALID <= '0';
        KEY_AXIS_TVALID <= '0';
        ENCR_AXIS_TREADY <= '0';
        
        wait for 100 ns;
        rstn <= '1';
        wait for 100 ns;
        PLAIN_AXIS_TVALID <= '1';
        wait for 100 ns;
        KEY_AXIS_TVALID <= '1';
        wait for 100 ns;
        PLAIN_AXIS_TVALID <= '0';
        wait for 100 ns;
        KEY_AXIS_TVALID <= '0';
        
        wait for 1500 ns;
        ENCR_AXIS_TREADY <= '1';
        assert (ENCR_AXIS_TDATA /= expected_hash) report "Test 2 is correct" severity note;
        wait for 100 ns;


        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '0';
        wait;
    end process;
end tb;
