-----------------------------------
-- Description : This is a testbench for the U-Quark
-----------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity tb_u_quark is
end tb_u_quark;

architecture tb of tb_u_quark is
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
            KEY_AXIS_TDATA : in  std_logic_vector(256-1 downto 0);
            PLAIN_AXIS_TVALID : in  std_logic;
            PLAIN_AXIS_TREADY : out  std_logic;
            PLAIN_AXIS_TDATA  : in  std_logic_vector(256-1 downto 0);
            ENCR_AXIS_TVALID  : out  std_logic;
            ENCR_AXIS_TREADY : in  std_logic;
            ENCR_AXIS_TDATA   : out  std_logic_vector(136-1 downto 0)--;
            );
    end component;

    signal clk          : std_logic;
    signal rstn         : std_logic;    
    signal KEY_AXIS_TVALID : std_logic; 
    signal KEY_AXIS_TREADY : std_logic; 
    signal KEY_AXIS_TDATA : std_logic_vector(256-1 downto 0);
    signal PLAIN_AXIS_TVALID : std_logic;
    signal PLAIN_AXIS_TREADY : std_logic;
    signal PLAIN_AXIS_TDATA  : std_logic_vector(256-1 downto 0);
    signal ENCR_AXIS_TVALID  : std_logic;
    signal ENCR_AXIS_TREADY  : std_logic;
    signal ENCR_AXIS_TDATA   : std_logic_vector(136-1 downto 0);
    
    signal expected_hash : std_logic_vector(136 - 1 downto 0);
    
    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    quark_dut : quark_wrapper 
--    generic map (MESSAGE_LENGTH => 256,
--                KEY_LENGTH => 256,
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
        PLAIN_AXIS_TDATA <= reverse_any_vector(x"6D7BE128CD3E79DDA73EA26250CCEE1DE8AA73EA240AC24B8A19D09C2492DA5D");
        KEY_AXIS_TDATA   <= reverse_any_vector(x"20CA51CEE1DE8AA73EA2402BC6D7BE128CD3E79DD718C24B8A19D094590CAD21");
        expected_hash    <= x"53A8B617E5EA9DB1248E1D53AC86D6B13E"; 
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
        
        wait for 5 us;
        ENCR_AXIS_TREADY <= '1';
        assert (ENCR_AXIS_TDATA /= expected_hash) report "Test 1 is correct" severity note;
        wait for 500 ns;
        ENCR_AXIS_TREADY <= '0';
        
        ----------------------------------------- test 2 ------------------------------------------------------------------
        -- reverse vector because the python implementation process data in little endianess and this IP uses Big endianess
        PLAIN_AXIS_TDATA <= (others => '0');
        KEY_AXIS_TDATA   <= (others => '0');
        expected_hash    <= x"FF600981CA06259735A53648EF9F7795F4"; 
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
        
        wait for 5 us;
        ENCR_AXIS_TREADY <= '1';
        assert (ENCR_AXIS_TDATA /= expected_hash) report "Test 2 is correct" severity note;
        wait for 500 ns;
        ENCR_AXIS_TREADY <= '0';
        ----------------------------------------- test 3 ------------------------------------------------------------------
        -- reverse vector because the python implementation process data in little endianess and this IP uses Big endianess
        PLAIN_AXIS_TDATA <= (others => '1');
        KEY_AXIS_TDATA   <= (others => '0');
        expected_hash    <= x"F34133827BE3A77229AD7F60A37D06D15E"; 
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
        
        wait for 5 us;
        ENCR_AXIS_TREADY <= '1';
        assert (ENCR_AXIS_TDATA /= expected_hash) report "Test 3 is correct" severity note;
        wait for 500 ns;
        ENCR_AXIS_TREADY <= '0';
        ----------------------------------------- test 4 ------------------------------------------------------------------
        -- reverse vector because the python implementation process data in little endianess and this IP uses Big endianess
        PLAIN_AXIS_TDATA <= reverse_any_vector(x"EA26250CCEE1DE8AA733EA2625CA5CEE1DE73EA29D79DDA73EA26250CCEE1DE2");
        KEY_AXIS_TDATA   <= reverse_any_vector(x"250C6D7BE128CD3E79DDEA26250C6D7BE128CD3E79DD718C24B8A19D09C2492D");
        expected_hash    <= x"60B69288CE9CD7E5B8B497A730DBECA1B0"; 
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
        
        wait for 5 us;
        ENCR_AXIS_TREADY <= '1';
        assert (ENCR_AXIS_TDATA /= expected_hash) report "Test 4 is correct" severity note;
        wait for 500 ns;
        ENCR_AXIS_TREADY <= '0';
        ----------------------------------------- test 5 ------------------------------------------------------------------
        -- reverse vector because the python implementation process data in little endianess and this IP uses Big endianess
        PLAIN_AXIS_TDATA <= reverse_any_vector(x"3E79DD718C24B8A150C397251CEE1DE8AA73EA2D718C24B8A19D09C24CA32789");
        KEY_AXIS_TDATA   <= reverse_any_vector(x"D09C2492DA5DDE8AA73EA26250C6D7BE128CD3E79DD718C24B8A19D09C2492DA");
        expected_hash    <= x"E7AE8FAB90C3ED8AD14422E430F67B38D2"; 
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
        
        wait for 5 us;
        ENCR_AXIS_TREADY <= '1';
        assert (ENCR_AXIS_TDATA /= expected_hash) report "Test 5 is correct" severity note;
        wait for 500 ns;
        ENCR_AXIS_TREADY <= '0';
        ------------------------------------------------------------------------------------------------------------------------        
                
                
        rstn <= '0';
        wait for 100 ns;
        rstn <= '1';
        -- EDIT Add stimuli here
        wait for 1000 us;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '0';
        wait;
    end process;
end tb;