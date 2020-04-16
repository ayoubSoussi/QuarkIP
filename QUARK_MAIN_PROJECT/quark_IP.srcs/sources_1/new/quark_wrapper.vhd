----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/22/2019 11:19:41 AM
-- Design Name: 
-- Module Name: aslm - Behavioral
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

entity quark_wrapper is
    generic(MESSAGE_LENGTH : integer := 256;
            KEY_LENGTH : integer := 256;
            HASH_LENGTH : integer := 136;
            CYCLES_PER_PERMUTATION : integer := 1
    );
    Port(
        clk : in  std_logic;
        rstn : in  std_logic;
        KEY_AXIS_TVALID : in  std_logic; 
        KEY_AXIS_TREADY : out  std_logic; 
        KEY_AXIS_TDATA : in  std_logic_vector(KEY_LENGTH-1 downto 0);
        PLAIN_AXIS_TVALID : in  std_logic;
        PLAIN_AXIS_TREADY : out  std_logic;
        PLAIN_AXIS_TDATA  : in  std_logic_vector(MESSAGE_LENGTH-1 downto 0);
        ENCR_AXIS_TVALID  : out  std_logic;
        ENCR_AXIS_TREADY : in  std_logic;
        ENCR_AXIS_TDATA   : out  std_logic_vector(HASH_LENGTH-1 downto 0)--;
        );
    
end quark_wrapper;
architecture Behavioral of quark_wrapper is
    -- types
    type STATE is (idle, isComputing, waitValid); 
   
   -- components
        component quark is
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
        end component;
    
    -- signals
    signal MESSAGE_COPY : std_logic_vector(MESSAGE_LENGTH-1 downto 0);
    signal KEY_COPY : std_logic_vector(KEY_LENGTH-1 downto 0);
    signal ENCR_DATA : std_logic_vector(HASH_LENGTH-1 downto 0);
    signal OUTPUT_READY : std_logic;
    signal start_hash : std_logic;
    signal compteur : integer := 0;
    signal Function_state : STATE := idle;
   -- signal counter_ready : integer := 0;

begin

-- quark component initialisation

U_Quark_comp : if HASH_LENGTH = 136 generate 
                     U_QUARK_C : quark 
                     generic map (MESSAGE_LENGTH => MESSAGE_LENGTH,
                             KEY_LENGTH => KEY_LENGTH,
                             HASH_LENGTH => HASH_LENGTH,
                             CYCLES_PER_PERMUTATION => CYCLES_PER_PERMUTATION,
                             -- Quark parameters
                             RATE => 8,
                             STATE_LENGTH => 136,
                             CEIL => 10, -- for all quark instances
                             SQUEEZZE_STEPS => 17, -- HASH_LENGTH/RATE
                             XY_LENGTH => 68 -- STATE_LENGTH/2
                     )
                     Port map ( clk => clk,
                            rstn => start_hash,       
                            message_data => MESSAGE_COPY,
                            key_data =>   KEY_COPY,
                            hashed_value => ENCR_DATA,
                            output_ready => OUTPUT_READY
                     );
                 end generate;
 D_Quark_comp : if HASH_LENGTH = 176 generate 
                     D_QUARK_C : quark 
                     generic map (MESSAGE_LENGTH => MESSAGE_LENGTH,
                             KEY_LENGTH => KEY_LENGTH,
                             HASH_LENGTH => HASH_LENGTH,
                             CYCLES_PER_PERMUTATION => CYCLES_PER_PERMUTATION,
                             -- Quark parameters
                             RATE => 16,
                             STATE_LENGTH => 176,
                             CEIL => 10, -- for all quark instances
                             SQUEEZZE_STEPS => 11, -- HASH_LENGTH/RATE
                             XY_LENGTH => 88 -- STATE_LENGTH/2
                     )
                     Port map ( clk => clk,
                            rstn => start_hash,       
                            message_data => MESSAGE_COPY,
                            key_data =>   KEY_COPY,
                            hashed_value => ENCR_DATA,
                            output_ready => OUTPUT_READY
                     );
                  end generate;
S_Quark_comp : if HASH_LENGTH = 256 generate 
                     S_QUARK_C : quark 
                     generic map (MESSAGE_LENGTH => MESSAGE_LENGTH,
                             KEY_LENGTH => KEY_LENGTH,
                             HASH_LENGTH => HASH_LENGTH,
                             CYCLES_PER_PERMUTATION => CYCLES_PER_PERMUTATION,
                             -- Quark parameters
                             RATE => 32,
                             STATE_LENGTH => 256,
                             CEIL => 10, -- for all quark instances
                             SQUEEZZE_STEPS => 8, -- HASH_LENGTH/RATE
                             XY_LENGTH => 128 -- STATE_LENGTH/2
                     )
                     Port map ( clk => clk,
                            rstn => start_hash,       
                            message_data => MESSAGE_COPY,
                            key_data =>   KEY_COPY,
                            hashed_value => ENCR_DATA,
                            output_ready => OUTPUT_READY
                     );
                   end generate;
-- state machine
process(clk, rstn)
    begin
    if rstn = '0' then
        Function_state <= idle;
        PLAIN_AXIS_TREADY <= '0';
        KEY_AXIS_TREADY   <= '0';
        ENCR_AXIS_TVALID  <= '0';
        start_hash <= '0';
        --counter_ready <= 0;
        
    elsif clk'event and clk='1' then
         case Function_state is
            when idle => 
                ENCR_AXIS_TVALID  <= '0';
                if ( (PLAIN_AXIS_TVALID and KEY_AXIS_TVALID) = '1') then
                    -- save a copy of data
                    MESSAGE_COPY <= PLAIN_AXIS_TDATA;
                    KEY_COPY <= KEY_AXIS_TDATA;
                    -- start hash function
                    start_hash <= '1';
                    Function_state <= isComputing;
                    -- data and key ready
                    PLAIN_AXIS_TREADY <= '1';
                    KEY_AXIS_TREADY   <= '1';
               else
                    PLAIN_AXIS_TREADY <= '0';
                    KEY_AXIS_TREADY   <= '0';
                    start_hash <= '0';
               end if;
             when isComputing =>
                 PLAIN_AXIS_TREADY <= '0';
                 KEY_AXIS_TREADY   <= '0';
                 start_hash <= '1';
                 if (OUTPUT_READY = '1')  then
                     -- send output data
                     ENCR_AXIS_TDATA <= ENCR_DATA;
                     ENCR_AXIS_TVALID  <= '1';
                     if ( ENCR_AXIS_TREADY = '1') then 
                        Function_state <= idle;
                     else 
                        Function_state <= waitValid;
                     end if;
                 end if;
              when waitValid => 
                   -- send output data
                   ENCR_AXIS_TDATA <= ENCR_DATA;
                   ENCR_AXIS_TVALID  <= '1'; 
                   if ( ENCR_AXIS_TREADY = '1') then 
                       Function_state <= idle;
                    end if;
         end case;
         
--         if (Function_state = idle) then
--               PLAIN_AXIS_TREADY <= '0';
--               KEY_AXIS_TREADY   <= '0';
--               ENCR_AXIS_TVALID  <= '0';
--               start_hash <= '0';
--               counter_ready <= 0;
--           end if;
--        if ( (PLAIN_AXIS_TVALID and KEY_AXIS_TVALID) = '1') then
--            -- save a copy of data
--            MESSAGE_COPY <= PLAIN_AXIS_TDATA;
--            KEY_COPY <= KEY_AXIS_TDATA;
--            -- start hash function
--            start_hash <= '1';
--            Function_state <= isComputing;
--        end if;
--        if (Function_state = isComputing) then
--            -- data and key ready
--            counter_ready <= counter_ready + 1;
--            if ( counter_ready < 2) then
--                PLAIN_AXIS_TREADY <= '1';
--                KEY_AXIS_TREADY   <= '1';
--            else 
--                PLAIN_AXIS_TREADY <= '0';
--                KEY_AXIS_TREADY   <= '0';
--                counter_ready <= 2;
--            end if;
--            if ((OUTPUT_READY and ENCR_AXIS_TREADY) = '1') then
--                -- send output data
--                ENCR_AXIS_TDATA <= ENCR_DATA;
--                ENCR_AXIS_TVALID  <= '1';
--                Function_state <= idle;
--            end if;
--        end if;
       
    end if;
end process;    


end Behavioral;
