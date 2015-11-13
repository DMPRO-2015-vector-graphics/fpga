library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity VECTOR3K is
    generic (
        INSTR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32;
        SRAM_ADDR_WIDTH : integer := 19;
        SRAM_DATA_WIDTH : integer := 16;
        PRIMITIVE_WIDTH : integer := 136;
        SCENE_MEM_ADDR_WIDTH : integer := 8

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

    -- Core signals
    signal proc_imem_address : std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal proc_scene_mem_write_data : std_logic_vector(PRIMITIVE_WIDTH-1 downto 0) := (others => '0');
    signal proc_scene_mem_addr : std_logic_vector(SCENE_MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal proc_scene_mem_read_data : std_logic_vector(PRIMITIVE_WIDTH-1 downto 0) := (others = '0');
    signal proc_scene_mem_we : std_logic := '0';
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
            address => proc_imem_address,
            instruction => instruction,
            valid => instr_valid,
            sram_wen => sram_wen,
            sram_ren => sram_ren,
            sram_addr => sram_addr,
            sram_data => sram_data
        );


    fb_data <= instruction(15 downto 0);

    scene_mem: entity work.DualPortMem
    port map (
        clka => clk, clkb => clk,
        -- port A: processor, read/write
        wea(0) => proc_scene_mem_we,
        dina => proc_scene_mem_write_data,
        addra => proc_scene_mem_addr,
        douta => proc_scene_mem_read_data,
        -- port B: output modules, read
        -- TODO: wire this agains actual output modules
        web(0) => '0',
        dinb => (others => '0'),
        addrb => (others => '0')
    )

    core_inst: entity work.Core(MultiCycle) 
        generic map (
            ADDR_WIDTH => SRAM_ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH,
            INSTR_WIDTH => INSTR_WIDTH,
            PRIMITIVE_WIDTH => PRIMITIVE_WIDTH,
            SCENE_MEM_ADDR_WIDTH => SCENE_MEM_ADDR_WIDTH
        ) 
        port map (
            clk => clk,
            reset => reset,
            processor_enable    => fpga_cs,
            -- instruction memory connection
            imem_data_in        => instruction,
            imem_address        => proc_imem_address,
            -- data memory connection
            scene_mem_we        => proc_scene_mem_we,
            scene_mem_data_out  => proc_scene_mem_write_data,
            scene_mem_addr      => proc_scene_mem_addr,
            scene_data_in       => proc_scene_mem_read_data
        );
end Behavior;
