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
           reset_if : in std_logic;
           processor_enable : in std_logic;
           address : in  STD_LOGIC_VECTOR (SRAM_ADDR_WIDTH-1 downto 0);
           instruction : out  STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
           valid : out STD_LOGIC;
           sram_addr : out std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
           sram_data : in std_logic_vector(SRAM_DATA_WIDTH-1 downto 0)
--           sram_wen : out std_logic;
--           sram_ren : out std_logic
       );
end instruction_fetch;

architecture Behavioral of instruction_fetch is
    type fetch_states is (offline, init, low, high, stall);
    signal state : fetch_states := offline;
    signal addr : STD_LOGIC_VECTOR(SRAM_ADDR_WIDTH-1 downto 0);
    signal temp_instr : std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
begin
    update_state: process(clk, reset, reset_if, processor_enable)
    begin
        if reset = '1' or processor_enable = '0' then
            state <= offline;
            addr <= (others => '1');
            temp_instr <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when offline =>
                    state <= init;
                    addr <= (others => '0');
                    temp_instr <= (others => '0');
                when init =>
                    state <= high;
                    addr <= std_logic_vector(unsigned(addr) + 1);
                when high =>
                    temp_instr(INSTR_WIDTH-1 downto SRAM_DATA_WIDTH) <= sram_data;
                    if reset_if = '1' then
                        state <= high;
                        addr <= address;
                    else
                        state <= low;
                        addr <= std_logic_vector(unsigned(addr) + 1);
                    end if;
                when low =>
                    temp_instr(SRAM_DATA_WIDTH-1 downto 0) <= sram_data;
                    if reset_if = '1' then
                        state <= low;
                        addr <= address;
                    else
                        state <= stall;
                    end if;
                when stall =>
                    if reset_if = '1' then
                        state <= stall;
                        addr <= address;
                    else
                        state <= high;
                        addr <= std_logic_vector(unsigned(addr) + 1);
                    end if;
                    temp_instr(INSTR_WIDTH-1 downto SRAM_DATA_WIDTH) <= sram_data;
            end case;
        end if;
    end process;

--    update_address: process(state)
--    begin
--        case state is
--            when offline =>
--                addr <= (others => '1');
--            when high =>
--                if reset_if = '1' then
--                    addr <= address;
--                else
--                    addr <= std_logic_vector(unsigned(addr) + 1);
--                end if;
--            when low =>
--                if reset_if = '1' then
--                    addr <= address;
--                else
--                    addr <= std_logic_vector(unsigned(addr) + 1);
--                end if;
--            when init =>
--                addr <= (others => '0');
--        end case;
--    end process;

--    process(sram_data)
--    begin
--        case state is
--            when offline =>
--                temp_instr <= (others => '0');
--            when high =>
--                temp_instr(INSTR_WIDTH-1 downto SRAM_DATA_WIDTH) <= sram_data;
--            when low =>
--                temp_instr(SRAM_DATA_WIDTH-1 downto 0) <= sram_data;
--            when init =>
--                temp_instr <= (others => '0');
--            when stall =>
--                temp_instr(INSTR_WIDTH-1 downto SRAM_DATA_WIDTH) <= sram_data;
--        end case;
--    end process;


    instruction <= temp_instr;

    sram_addr <= addr;
--    sram_ren <= '0' when processor_enable = '1' else 'Z';
--    sram_wen <= '1' when processor_enable = '1' else 'Z';

end Behavioral;

