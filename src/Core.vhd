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
    signal instruction : std_logic_vector(DATA_WIDTH-1 downto 0);
    -- Register out signals
    signal read_data_1, read_data_2 : std_logic_vector(DATA_WIDTH-1 downto 0);
    -- ALU out signals
    signal Zero : std_logic; 
    signal ALUResult : std_logic_vector(DATA_WIDTH-1 downto 0);
    -- Control out signals
    signal RegDst : std_logic := '0';
    signal Branch : std_logic := '0';
    signal Jump : std_logic := '0';
    signal MemRead : std_logic := '0';
    signal MemToReg : std_logic := '0';
    signal ALUOp : std_logic_vector(1 downto 0) := "00";
    signal MemWrite : std_logic := '0';
    signal ALUSrc : std_logic := '0';
    signal RegWrite : std_logic := '0';
    signal PCWrite : std_logic := '0';
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
        instruction => imem_data_in,
        RegDst => RegDst,
        Branch => Branch,
        Jump => Jump,
        MemToReg => MemToReg,
        ALUOp => ALUOp,
        MemWrite => MemWrite,
        ALUSrc => ALUSrc,
        RegWrite => RegWrite,
        PCWrite => PCWrite
    );

    program_counter: entity work.ProgramCounter
    generic map(
        ADDR_WIDTH => ADDR_WIDTH
    )
    port map(
       reset => reset,
       clk => clk,
       jump => Jump,
       branch => Branch,
       zero => Zero,
       instruction => imem_data_in(25 downto 0),
       pc_write => PCWrite,
       address_out => program_counter_val
    );

    registers: entity work.Registers
    generic map(
        DATA_WIDTH => DATA_WIDTH
    )
    port map(
        clk => clk,
        reset => reset,
        read_reg_1 => imem_data_in(25 downto 21),
        read_reg_2 => imem_data_in(20 downto 16),
        read_reg_3 => imem_data_in(15 downto 11),
        ALUResult => ALUResult,
        MemToReg => MemToReg,
        RegWrite => RegWrite,
        RegDst => RegDst,
        read_data_1 => read_data_1,
        read_data_2 => read_data_2
    );

    alu: entity work.ALU
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH,
        INSTR_WIDTH => INSTR_WIDTH
    )
    port map(
        clk => clk,
        read_data_1 => read_data_1,
        read_data_2 => read_data_2,
        instruction => imem_data_in,
        ALUOp => ALUOp,
        Zero => Zero,
        ALUResult => ALUResult,
        ALUSrc => ALUSrc
    );

    -- IMEM
    imem_address <= program_counter_val;
end MultiCycle;

