library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity PrimReg is
    generic (
        PRIM_WIDTH : integer := 136
    );
    port (
        clk, reset          : in std_logic;
        write_enable        : in reg_write_t;
        data_source         : in mem_to_reg_t;
        prim_result_in      : in std_logic_vector(PRIM_WIDTH-1 downto 0);
        prim_mem_in         : in std_logic_vector(PRIM_WIDTH-1 downto 0);
        prim_out            : out std_logic_vector(PRIM_WIDTH-1 downto 0)
    );
end PrimReg;

architecture Behavioral of PrimReg is
    signal current_prim : std_logic_vector(PRIM_WIDTH-1 downto 0) := (others => '0');
begin
    
    update: process (clk, reset)
    begin
        if reset = '1' then
            current_prim <= (others => '0');
        elsif rising_edge(clk) then
            if write_enable = true then
                if data_source = FROM_ALU then
                    current_prim <= prim_result_in;
                else
                    current_prim <= prim_mem_in;
                end if;
            end if;
        end if;
    end process;

    prim_out <= current_prim;
end Behavioral;

