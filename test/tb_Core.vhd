LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

ENTITY tb_Core is
end tb_Core;

architecture behavior of tb_Core is
    constant INSTR_WIDTH : integer := 32;
    constant DATA_WIDTH : integer := 32;
    constant SRAM_ADDR_WIDTH : integer := 19;
    constant SRAM_DATA_WIDTH : integer := 16;
    constant PRIM_WIDTH : integer := 136;
    constant SCENE_MEM_ADDR_WIDTH : integer := 10;

    -- Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal processor_enable : std_logic := '0';
    signal imem_data_in : std_logic_vector(INSTR_WIDTH-1 downto 0);
    signal scene_mem_data_in : std_logic_vector(PRIM_WIDTH-1 downto 0);

    -- Outputs
    signal reset_if : std_logic;
    signal imem_address : std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
    signal scene_mem_we : std_logic;
    signal scene_mem_data_out : std_logic_vector(PRIM_WIDTH-1 downto 0);
    signal scene_mem_addr : std_logic_vector(SCENE_MEM_ADDR_WIDTH-1 downto 0);

    -- if out
    signal sram_addr : std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
    signal sram_data : std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;
begin

    core_inst: entity work.Core
    generic map(
        INSTR_WIDTH => INSTR_WIDTH,
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => SRAM_ADDR_WIDTH,
        PRIM_WIDTH => PRIM_WIDTH,
        SCENE_MEM_ADDR_WIDTH => SCENE_MEM_ADDR_WIDTH
    )
    port map(
        clk => clk,
        reset => reset,
        processor_enable => processor_enable,
        reset_if => reset_if,
        imem_data_in => imem_data_in,
        imem_address => imem_address,
        scene_mem_we => scene_mem_we,
        scene_mem_data_out => scene_mem_data_out,
        scene_mem_data_in => scene_mem_data_in,
        scene_mem_addr => scene_mem_addr
    );

    if_inst: entity work.instruction_fetch
    generic map(
        SRAM_ADDR_WIDTH => SRAM_ADDR_WIDTH,
        SRAM_DATA_WIDTH => SRAM_DATA_WIDTH,
        INSTR_WIDTH => INSTR_WIDTH
    )
    port map(
        clk => clk,
        reset => reset,
        reset_if => reset_if,
        address => imem_address,
        instruction => imem_data_in,
        sram_addr => sram_addr,
        sram_data => sram_data
    );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process

        function memory(
            addr : std_logic_vector
        ) return std_logic_vector is
        begin
            case to_integer(unsigned(addr)) is
                when 0 =>
                    return x"0820";
                when 2 =>
                    return x"0000";
                when 4 =>
                    return x"345F";
                when 6 =>
                    return x"FFFF";
                when 8 =>
                    return x"385F";
                when 10 =>
                    return x"FFFF";
                when 12 =>
                    return x"1401";
                when 14 =>
                    return x"1000";
                when 16 =>
                    return x"2C00";
                when 18 =>
                    return x"0000";
                when 20 =>
                    return x"0400";
                when 22 =>
                    return x"0014";
                when others =>
                    return x"0000";
            end case;
        end memory;

    begin
        reset <= '1';
        wait for clk_period;
        wait for clk_period/2;
        reset <= '0';
        processor_enable <= '1';
        
        for I in 0 to 200 loop
            sram_data <= memory(sram_addr);
            wait for clk_period;
        end loop;
        wait;
    end process;
end behavior;
