library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity Core is
    generic (
        INSTR_WIDTH: integer := 32;
        DATA_WIDTH : integer := 32;
        ADDR_WIDTH : integer := 19;
        PRIMITIVE_WIDTH : integer := 136;
        SCENE_MEM_ADDR_WIDTH : integer := 8
    );
    port (
        clk, reset 			: in std_logic;
        processor_enable		: in std_logic;
        -- IMEM
        imem_data_in			: in std_logic_vector(INSTR_WIDTH-1 downto 0);
        imem_address			: out std_logic_vector(ADDR_WIDTH-1 downto 0);
        -- Scene
        scene_mem_we                    : out std_logic;
        scene_mem_data_out              : out std_logic_vector(PRIMITIVE_WIDTH-1 downto 0);
        scene_mem_data_in               : in std_logic_vector(PRIMITIVE_WIDTH-1 downto 0);
        scene_mem_addr                  : out std_logic_vector(SCENE_MEM_ADDR_WIDTH-1 downto 0)
    );
end Core;

architecture MultiCycle of Core is
    -- PC out signals
    signal program_counter_val : std_logic_vector(ADDR_WIDTH-1 downto 0);
    -- IMEM out signals
    signal instruction : instruction_t;
    -- Register out signals
    signal read_data_1, read_data_2, read_data_3, read_data_4 : std_logic_vector(DATA_WIDTH-1 downto 0);
    -- ALU out signals
    signal Zero : std_logic; 
    signal ALUResult : std_logic_vector(DATA_WIDTH-1 downto 0);
    -- Control out signals
    signal control_signals : control_signals_t;
begin

    control: entity work.Control
    generic map(
        INSTR_WIDTH => INSTR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map(
        clk => clk,
        reset => reset,
        processor_enable => processor_enable,
        instruction => instruction,
        control_signals_out => control_signals
    );

    program_counter: entity work.ProgramCounter
    generic map(
        ADDR_WIDTH => ADDR_WIDTH
    )
    port map(
       reset => reset,
       clk => clk,
       jump => control_signals.jump,
       branch => control_signals.branch,
       zero => Zero,
       instruction => instruction,
       pc_write => control_signals.pc_write,
       address_out => program_counter_val
    );

    registers: entity work.Registers
    generic map(
        DATA_WIDTH => DATA_WIDTH
    )
    port map(
        clk => clk,
        reset => reset,
        read_reg_1 => instruction.regs,
        read_reg_2 => instruction.regt,
        read_reg_3 => instruction.regu,
        read_reg_4 => instruction.regv,
        reg_dest => instruction.regd,
        ALUResult => ALUResult,
        MemToReg => control_signals.MemToReg,
        RegWrite => control_signals.RegWrite,
        read_data_1 => read_data_1,
        read_data_2 => read_data_2,
        read_data_3 => read_data_3,
        read_data_4 => read_data_4
    );

    --alu: entity work.ALU
    --generic map(
    --    DATA_WIDTH => DATA_WIDTH,
    --    ADDR_WIDTH => ADDR_WIDTH,
    --    INSTR_WIDTH => INSTR_WIDTH
    --)
    --port map(
    --    clk => clk,
    --    read_data_1 => read_data_1,
    --    read_data_2 => read_data_2,
    --    read_data_3 => read_data_3,
    --    read_data_4 => read_data_4,
    --    instruction => imem_data_in,
    --    op => control_signals.op,
    --    Zero => Zero,
    --    ALUResult => ALUResult,
    --    ALUSrc => control_signals.ALU_source
    --);

    -- IMEM
    imem_address <= program_counter_val;
    instruction <= make_instruction(imem_data_in);
end MultiCycle;

