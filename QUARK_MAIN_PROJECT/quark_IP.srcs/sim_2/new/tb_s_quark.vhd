-----------------------------------
-- Description : This is a testbench for the S-Quark
-----------------------------------



library ieee;
use ieee.std_logic_1164.all;

entity tb_s_quark is
end tb_s_quark;

architecture tb of tb_s_quark is
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
            ENCR_AXIS_TDATA   : out  std_logic_vector(256-1 downto 0)--;
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
    signal ENCR_AXIS_TDATA   : std_logic_vector(256-1 downto 0);
    
    signal expected_hash : std_logic_vector(256 - 1 downto 0);
    
    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    quark_dut : quark_wrapper 
    generic map (MESSAGE_LENGTH => 256,
                KEY_LENGTH => 256,
                HASH_LENGTH => 256,
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
        expected_hash    <= x"BA5AE81B35A011BBD3C9791D4C10819D83EE218AC46B7606033533CD8289152A"; 
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
        expected_hash    <= x"7D8376B69DB82BAF5CF75526E8C39D6FABF54C0D527551D237FE102BF19D155A"; 
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
        ENCR_AXIS_TREADY <= '0';
        ----------------------------------------- test 3 ------------------------------------------------------------------
        -- reverse vector because the python implementation process data in little endianess and this IP uses Big endianess
        PLAIN_AXIS_TDATA <= (others => '1');
        KEY_AXIS_TDATA   <= (others => '0');
        expected_hash    <= x"0B5200B440049BC942DF9BAAFED977807AB53517D9E4401DE794194BD64970F9"; 
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
        assert (ENCR_AXIS_TDATA /= expected_hash) report "Test 3 is correct" severity note;
        wait for 100 ns;
        ENCR_AXIS_TREADY <= '0';
        ----------------------------------------- test 4 ------------------------------------------------------------------
        -- reverse vector because the python implementation process data in little endianess and this IP uses Big endianess
        PLAIN_AXIS_TDATA <= reverse_any_vector(x"EA26250CCEE1DE8AA733EA2625CA5CEE1DE73EA29D79DDA73EA26250CCEE1DE2");
        KEY_AXIS_TDATA   <= reverse_any_vector(x"250C6D7BE128CD3E79DDEA26250C6D7BE128CD3E79DD718C24B8A19D09C2492D");
        expected_hash    <= x"73C31E90D57A56A0635B9BF262E687847CAF88B13B0AA9CB8CDB6ABAA17967FE"; 
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
        assert (ENCR_AXIS_TDATA /= expected_hash) report "Test 4 is correct" severity note;
        wait for 100 ns;
        ENCR_AXIS_TREADY <= '0';
        ----------------------------------------- test 5 ------------------------------------------------------------------
        -- reverse vector because the python implementation process data in little endianess and this IP uses Big endianess
        PLAIN_AXIS_TDATA <= reverse_any_vector(x"3E79DD718C24B8A150C397251CEE1DE8AA73EA2D718C24B8A19D09C24CA32789");
        KEY_AXIS_TDATA   <= reverse_any_vector(x"D09C2492DA5DDE8AA73EA26250C6D7BE128CD3E79DD718C24B8A19D09C2492DA");
        expected_hash    <= x"E20C337856D5CBBF461EA61488EDA270B707722CEBC574E11E34122D8792A181"; 
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
        assert (ENCR_AXIS_TDATA /= expected_hash) report "Test 5 is correct" severity note;
        wait for 100 ns;
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
