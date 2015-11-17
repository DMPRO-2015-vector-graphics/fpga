LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;

ENTITY tb_ALU IS
END tb_ALU;

ARCHITECTURE behavior OF tb_ALU IS 
    constant DATA_WIDTH : integer := 32;
    constant PRIMITIVE_WIDTH : integer := 136;
    --Inputs
    signal clk : std_logic := '0';
    signal read_data_1 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal read_data_2 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal read_data_3 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal read_data_4 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal read_data_5 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal instruction : instruction_t;
    signal op : op_t;
    signal alu_source_a : alu_source_t;
    signal alu_source_b : alu_source_t;


    --Outputs
    signal zero : std_logic;
    signal alu_result_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal prim_result : std_logic_vector(PRIMITIVE_WIDTH-1 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.ALU PORT MAP (
        read_data_1 => read_data_1,
        read_data_2 => read_data_2,
        read_data_3 => read_data_3,
        read_data_4 => read_data_4,
        read_data_5 => read_data_5,
        instruction => instruction,
        op => op,
        zero => zero,
        alu_result_out => alu_result_out,
        prim_result => prim_result,
        alu_source_a => alu_source_a,
        alu_source_b => alu_source_b
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        wait for clk_period/2;	

        -- mov
        report "MOV";
        instruction <= make_instruction(x"08201234");
        op <= mov;
        alu_source_a <= IMM;
        alu_source_b <= REG1;
        wait for clk_period/2;
        assert alu_result_out = x"00001234";
        assert prim_result = (others => '0');
        wait for clk_period/2;
        instruction <= make_instruction(x"14011000");
        read_data_2 <= x"00000000";
        read_data_3 <= x"FFFFFFFF";
        op <= line;
        wait for clk_period/2;
        assert alu_result_out = (others => '0');
        assert prim_result = x"0100000000FFFFFFFF0000000000000000";
        report "ALU test complete";

        wait;
    end process;
END;
