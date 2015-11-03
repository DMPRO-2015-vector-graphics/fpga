library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity VECTOR3K is
    generic (
        INSTR_WIDTH: integer := 32;
        ADDR_WIDTH : integer := 16;
        DATA_WIDTH : integer := 16
    );
    port (
        clk, reset              : in std_logic;
        imem_address            : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        dmem_address            : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        dmem_data_out           : out std_logic_vector(DATA_WIDTH-1 downto 0);
        dmem_write_enable       : out std_logic
    );
end VECTOR3K;

architecture Behavior of VECTOR3K is
    -- Core out signals
begin
    core_inst: entity work.Core(MultiCycleMIPS) 
        generic map (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH,
            INSTR_WIDTH=> INSTR_WIDTH
        ) 
        port map (
            clk => clk,
            reset => reset,
            processor_enable    => '1',
            -- instruction memory connection
            imem_data_in        => x"FFFFFFFF",        -- instruction data from memory
            imem_address        => imem_address,            -- instruction address to memory
            -- data memory connection
            dmem_data_in        => x"BEEF",        -- read data from memory
            dmem_address        => dmem_address,            -- address to memory
            dmem_data_out       => dmem_data_out,   -- write data to memory
            dmem_write_enable   => dmem_write_enable  -- write enable to memory
        );
end Behavior;
