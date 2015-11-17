library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Defs.all;

entity ProgramCounter is
    generic (
        ADDR_WIDTH : integer := 8
    );
    port (
        clk, reset          : in std_logic;
        pc_write            : in pc_write_t;
        jump                : in jump_t;
        branch              : in branch_t; 
        zero                : in std_logic;
        target              : in target_t;
        immediate           : in immediate_t;
        address_out         : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
    );
end ProgramCounter;

architecture Behavioral of ProgramCounter is
    signal address : std_logic_vector(ADDR_WIDTH - 1 downto 0);
begin
    update: process(clk, reset, pc_write)
    begin
        if reset = '1' then
            address <= (others => '0');
        elsif rising_edge(clk) and pc_write = true then
            if jump = true then
                address <= target;
            else
                if branch = true and zero = '1' then
                    address <= std_logic_vector(unsigned(address) + 4 + unsigned(immediate));
                else
                    address <= std_logic_vector(unsigned(address) + 4);
                end if;
            end if;
        end if;
    end process;

    address_out <= address;

end Behavioral;

