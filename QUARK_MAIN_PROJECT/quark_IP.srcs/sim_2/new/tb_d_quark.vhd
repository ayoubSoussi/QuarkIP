-----------------------------------
-- Description : This is a testbench for the D-Quark
-----------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_d_quark is
end tb_d_quark;

architecture tb of tb_d_quark is
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
        generic(MESSAGE_LENGTH : integer := 256;
                KEY_LENGTH : integer := 256;
                HASH_LENGTH : integer := 136;
                CYCLES_PER_PERMUTATION : integer := 4
        );
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
            ENCR_AXIS_TDATA   : out  std_logic_vector(176-1 downto 0)--;
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
    signal ENCR_AXIS_TDATA   : std_logic_vector(176-1 downto 0);
    
    signal expected_hash : std_logic_vector(176 - 1 downto 0);
    
    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    quark_dut : quark_wrapper 
    generic map (MESSAGE_LENGTH => 256,
                KEY_LENGTH => 256,
                HASH_LENGTH => 176,
                CYCLES_PER_PERMUTATION => 4
        )
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
        expected_hash    <= x"B54C6429E82CD051E383569DEC4DE40BE4DF2AA60AEE"; 
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
        expected_hash    <= x"03902078D16C0423332915C43500EC74232CD1E62575"; 
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
        expected_hash    <= x"3F62EBA9D00987CFFE4CEAB93C72313B8EA9FBBB5CFC"; 
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
        expected_hash    <= x"AF1E451CB9667781A8DBF2888FBE258E9D52107CA123"; 
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
        expected_hash    <= x"CF926BAD03A30758C258F1E6F5C1803A501E3597965F"; 
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
