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
        PRIM_WIDTH : integer := 136;
        SCENE_MEM_ADDR_WIDTH : integer := 10
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
        fpga_cs                 : in std_logic;
        -- DAC
        dac_clk                 : out std_logic;
        dac_sync                : out std_logic;
        dac0_data               : out std_logic;
        dac1_data               : out std_logic;
        vref_sleep              : out std_logic
        -- TODO
        --
    );
end VECTOR3K;

architecture Behavior of VECTOR3K is
    -- IF out signals
    signal instr_valid : std_logic := '0';
    signal instruction : std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');

    -- Core signals
    signal reset_if : std_logic;
    signal proc_imem_address : std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal proc_scene_mem_write_data : std_logic_vector(PRIM_WIDTH-1 downto 0) := (others => '0');
    signal proc_scene_mem_addr : std_logic_vector(SCENE_MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal proc_scene_mem_read_data : std_logic_vector(PRIM_WIDTH-1 downto 0) := (others => '0');
    signal proc_scene_mem_we : std_logic := '0';

    -- Dac out signals
    signal do_address : std_logic_vector(SCENE_MEM_ADDR_WIDTH-1 downto 0);
    signal do_data_in : std_logic_vector(PRIM_WIDTH-1 downto 0);
    signal primitive_count : std_logic_vector(SCENE_MEM_ADDR_WIDTH-1 downto 0);

    -- Clock out signals
    signal clk_20 : std_logic;
    signal core_clk : std_logic;
begin
    if_inst: entity work.instruction_fetch
        generic map (
            SRAM_ADDR_WIDTH => SRAM_ADDR_WIDTH,
            SRAM_DATA_WIDTH => SRAM_DATA_WIDTH,
            INSTR_WIDTH => INSTR_WIDTH
        )
        port map (
            clk => core_clk,
            reset_if => reset_if,
            reset => reset,
            processor_enable => fpga_cs,
            address => proc_imem_address,
            instruction => instruction,
            valid => instr_valid,
            sram_wen => sram_wen,
            sram_ren => sram_ren,
            sram_addr => sram_addr,
            sram_data => sram_data
        );


    fb_data <= instruction(15 downto 0);

    scene_mem: entity work.SceneMem
    port map (
        clka => core_clk, clkb => clk_20,
        -- port A: processor, read/write
        wea(0) => proc_scene_mem_we,
        dina => proc_scene_mem_write_data,
        addra => proc_scene_mem_addr,
        douta => proc_scene_mem_read_data,
        -- port B: output modules, read
        -- TODO: wire this agains actual output modules
        web(0) => '0',
        dinb => (others => '0'),
        addrb => do_address,
        doutb => do_data_in
    );

    dac_out_inst: entity work.dac_output
    generic map(
        DATA_WIDTH => PRIM_WIDTH,
        ADDR_WIDTH => SCENE_MEM_ADDR_WIDTH
    )
    port map (
        clk => clk_20,
        reset => reset,
        dac_clk => dac_clk,
        dac_sync => dac_sync,
        dac0_data => dac0_data,
        dac1_data => dac1_data,
        address => do_address,
        data => do_data_in,
        enable => fpga_cs,
        primitive_count => primitive_count
    );

    pll_inst: entity work.pll
    port map(-- Clock in ports
        CLK_IN1            => clk,
        -- Clock out ports
        CLK_OUT2           => core_clk,
        CLK_OUT1           => clk_20,
        -- Status and control signals
        RESET              => reset
    );

    core_inst: entity work.Core(MultiCycle) 
        generic map (
            ADDR_WIDTH => SRAM_ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH,
            INSTR_WIDTH => INSTR_WIDTH,
            PRIM_WIDTH => PRIM_WIDTH,
            SCENE_MEM_ADDR_WIDTH => SCENE_MEM_ADDR_WIDTH
        ) 
        port map (
            clk                     => core_clk,
            reset                   => reset,
            processor_enable        => fpga_cs,
            reset_if                => reset_if,
            -- instruction memory connection
            imem_data_in            => instruction,
            imem_address            => proc_imem_address,
            -- scene memory connection
            scene_mem_we            => proc_scene_mem_we,
            scene_mem_data_out      => proc_scene_mem_write_data,
            scene_mem_addr          => proc_scene_mem_addr,
            scene_mem_data_in       => proc_scene_mem_read_data,
            primitive_counter_out   => primitive_count
        );
    
    vref_sleep <= '1';
end Behavior;
