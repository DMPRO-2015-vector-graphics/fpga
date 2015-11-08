library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity instruction_fetch is
    generic (
        SRAM_ADDR_WIDTH : integer := 19;
        SRAM_DATA_WIDTH : integer := 16;
        INSTR_WIDTH : integer := 32
    );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           address : in  STD_LOGIC_VECTOR (SRAM_ADDR_WIDTH-1 downto 0);
           instruction : out  STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
           valid : out STD_LOGIC;
           sram_addr : out std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
           sram_data : inout std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
           sram_wen : out std_logic;
           sram_ren : out std_logic
       );
end instruction_fetch;

architecture Behavioral of instruction_fetch is
    type fetch_states is (low, high, rst);
    signal state : fetch_states;
    signal temp : STD_LOGIC_VECTOR(SRAM_DATA_WIDTH-1 downto 0) := (others => '0');
    signal addr : STD_LOGIC_VECTOR(SRAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal instr : STD_LOGIC_VECTOR(INSTR_WIDTH-1 downto 0) := (others => '0');
    signal low_valid : STD_LOGIC := '0';
    signal high_valid : STD_LOGIC := '0';
begin
    sram: entity work.sram
    port map(
                clk => clk,
                -- Facing V3K
                address => addr,
                data_out => temp,
                wr => '0',
                data_in => (others => '0'),
                -- Facing SRAM
                we => sram_wen,
                oe => sram_ren,
                a => sram_addr,
                io => sram_data
            );

    process(clk, address, reset)
    begin
        if(reset = '1') then
            instruction <= (others => '0');
            state <= rst;
        end if;
        if(rising_edge(clk)) then
            case state is
                when rst =>
                    addr <= address;
                    high_valid <= '0';
                    low_valid <= '0';
                    if(reset = '0') then
                        state <= low;
                    end if;
                when low =>
                    instr(SRAM_DATA_WIDTH-1 downto 0) <=  temp;
                    addr <= std_logic_vector(unsigned(addr) + 2);
                    state <= high;
                    low_valid <= '1';
                when high =>
                    instr(INSTR_WIDTH-1 downto SRAM_DATA_WIDTH-1) <= temp;
                    addr <= std_logic_vector(unsigned(addr) + 2);
                    state <= low;
                    high_valid <= '1';
                    instruction <= instr;
            end case;
        end if;	  
        valid <= low_valid and high_valid;
    end process;

end Behavioral;

