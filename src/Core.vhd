library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity Core is
    generic (
        INSTR_WIDTH: integer := 32;
        DATA_WIDTH : integer := 32;
        ADDR_WIDTH : integer := 19;
        PRIM_WIDTH : integer := 136;
        SCENE_MEM_ADDR_WIDTH : integer := 10
    );
    port (
        clk, reset 			: in std_logic;
        processor_enable		: in std_logic;
        reset_if                        : out std_logic;
        -- IMEM
        imem_data_in			: in std_logic_vector(INSTR_WIDTH-1 downto 0);
        imem_address			: out std_logic_vector(ADDR_WIDTH-1 downto 0);
        -- Scene
        scene_mem_we                    : out std_logic;
        scene_mem_data_out              : out std_logic_vector(PRIM_WIDTH-1 downto 0);
        scene_mem_data_in               : in std_logic_vector(PRIM_WIDTH-1 downto 0);
        scene_mem_addr                  : out std_logic_vector(SCENE_MEM_ADDR_WIDTH-1 downto 0);
        primitive_counter_out           : out std_logic_vector(SCENE_MEM_ADDR_WIDTH-1 downto 0)
    );
end Core;

architecture MultiCycle of Core is
    -- PC out signals
    signal program_counter_val : std_logic_vector(ADDR_WIDTH-1 downto 0);
    -- IMEM out signals
    signal instruction : instruction_t;
    -- Register out signals
    signal read_data_1,
           read_data_2,
           read_data_3,
           read_data_4,
           read_data_5 : std_logic_vector(DATA_WIDTH-1 downto 0);
    -- Prim reg
    signal active_primitive : std_logic_vector(PRIM_WIDTH-1 downto 0);
    -- ALU out signals
    signal Zero : std_logic; 
    signal alu_result : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal prim_result : std_logic_vector(PRIM_WIDTH-1 downto 0);
    -- Control out signals
    signal control_signals : control_signals_t;
    signal reset_if_tmp : std_logic;
begin 
    control: entity work.Control
    generic map(
        INSTR_WIDTH => INSTR_WIDTH,
        DATA_WIDTH => DATA_WIDTH,
        SCENE_MEM_ADDR_WIDTH => SCENE_MEM_ADDR_WIDTH
    )
    port map(
        clk => clk,
        reset => reset,
        processor_enable => processor_enable,
        opcode => instruction.opcode,
        zero => zero,
        control_signals_out => control_signals,
        primitive_counter_out => primitive_counter_out,
        reset_if => reset_if_tmp
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
       zero => zero,
       target => instruction.target,
       immediate => instruction.immediate,
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
        reg_1 => instruction.reg1,
        reg_2 => instruction.reg2,
        reg_3 => instruction.reg3,
        reg_4 => instruction.reg4,
        reg_5 => instruction.reg5,
        reg_dest => control_signals.reg_dest,
        alu_result => alu_result,
        mem_to_reg => control_signals.mem_to_reg,
        reg_write => control_signals.reg_write,
        read_data_1 => read_data_1,
        read_data_2 => read_data_2,
        read_data_3 => read_data_3,
        read_data_4 => read_data_4,
        read_data_5 => read_data_5
    );

    alu: entity work.ALU
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH,
        INSTR_WIDTH => INSTR_WIDTH,
        PRIM_WIDTH => PRIM_WIDTH
    )
    port map(
        read_data_1 => read_data_1,
        read_data_2 => read_data_2,
        read_data_3 => read_data_3,
        read_data_4 => read_data_4,
        read_data_5 => read_data_5,
        immediate => instruction.immediate,
        op => control_signals.op,
        Zero => Zero,
        alu_result_out => alu_result,
        prim_result => prim_result
    );

    prim_reg: entity work.PrimReg
    generic map (
        PRIM_WIDTH => PRIM_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        write_enable => control_signals.prim_reg_write,
        data_source => control_signals.prim_mem_to_reg,
        prim_out => active_primitive,
        prim_result_in => prim_result,
        prim_mem_in => scene_mem_data_in
    );

    reset_if <= reset_if_tmp and zero when control_signals.op = beq else
                reset_if_tmp;
    -- IMEM
    imem_address <= program_counter_val;
    instruction <= make_instruction(imem_data_in);
    scene_mem_addr <= instruction.target(9 downto 0);
    scene_mem_we <= to_std_logic(control_signals.prim_mem_write);
    scene_mem_data_out <= active_primitive;
end MultiCycle;

