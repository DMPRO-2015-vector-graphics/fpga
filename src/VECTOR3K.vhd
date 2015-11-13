library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity VECTOR3K is
    generic (
        INSTR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32;
        SRAM_ADDR_WIDTH : integer := 19;
        SRAM_DATA_WIDTH : integer := 16
    );
    port (
        clk, reset              : in std_logic;
        -- SRAM
        sram_addr               : out std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
        sram_data               : inout std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
        sram_wen                : out std_logic;
        sram_ren                : out std_logic;
        -- FB
        fb_addr                 : out std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
        fb_data                 : inout std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
        fb_wen                  : out std_logic;
        fb_ren                  : out std_logic;
        fb_cs                   : out std_logic;
        -- EBI
        fpga_cs                 : in std_logic
        -- DAC
        -- TODO
        --
    );
end VECTOR3K;

architecture Behavior of VECTOR3K is
    -- IF out signals
    signal instr_valid : std_logic := '0';
    signal instruction : std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');

    -- Core out signals
    signal imem_address : std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0) := (others => '0');
begin
    if_inst: entity work.instruction_fetch
        generic map (
            SRAM_ADDR_WIDTH => SRAM_ADDR_WIDTH,
            SRAM_DATA_WIDTH => SRAM_DATA_WIDTH,
            INSTR_WIDTH => INSTR_WIDTH
        )
        port map (
            clk => clk,
            reset => reset,
            address => imem_address,
            instruction => instruction,
            valid => instr_valid,
            sram_wen => sram_wen,
            sram_ren => sram_ren,
            sram_addr => sram_addr,
            sram_data => sram_data
        );


    fb_data <= instruction(15 downto 0);

--    core_inst: entity work.Core(MultiCycle) 
--        generic map (
--            ADDR_WIDTH => ADDR_WIDTH,
--            DATA_WIDTH => DATA_WIDTH,
--            INSTR_WIDTH => INSTR_WIDTH
--        ) 
--        port map (
--            clk => clk,
--            reset => reset,
--            processor_enable    => fpga_cs,
--            -- instruction memory connection
--            imem_data_in        => instruction,        -- instruction data from memory
--            imem_address        => imem_address,            -- instruction address to memory
--            -- data memory connection
--            dmem_data_in        => x"BEEF",        -- read data from memory
--            dmem_address        => dmem_address,            -- address to memory
--            dmem_data_out       => dmem_data_out,   -- write data to memory
--            dmem_write_enable   => dmem_write_enable  -- write enable to memory
--        );
end Behavior;
