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
    signal alu_result : std_logic_vector(31 downto 0);

   -- Clock period definitions
    constant clk_period : time := 10 ns;

BEGIN

   -- Instantiate the Unit Under Test (UUT)
    uut: entity work.ALU PORT MAP (
        clk => clk,
        read_data_1 => read_data_1,
        read_data_2 => read_data_2,
        read_data_3 => read_data_3,
        read_data_4 => read_data_4,
        read_data_5 => read_data_5,
        instruction => instruction,
        op => op,
        zero => zero,
        alu_result => alu_result,
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
        wait for 100 ns;	

        wait for clk_period*5;

        -- insert stimulus here 

        report "Testing add";
        read_data_1 <= x"00000002";
        read_data_2 <= x"00000003";

        ALUOp <= "00";
        Instruction <= x"0020";

        wait for clk_period;

        assert Zero = '0';
        assert ALUResult = x"00000005";


        report "Testing sub";		
        read_data_2 <= x"00000010";
        Instruction <= x"0022";

        wait for clk_period;

        assert Zero = '0';
        assert ALUResult = x"FFFFFFF2";


        report "Testing beq";
        ALUOp <= "10";
        read_data_1 <= x"00001234";
        read_data_2 <= x"00001234";

        wait for clk_period;

        assert Zero = '1';

        read_data_1 <= x"00001231";

        wait for clk_period;

        assert Zero = '0';


        report "Testing or";
        ALUOp <= "00";
        instruction <= x"0025";
        read_data_1 <= x"01000010";
        read_data_2 <= x"00011011";	

        wait for clk_period;

        assert ALUResult = x"01011011";		

        report "testing and";
        instruction <= x"0024";
        read_data_1 <= x"01110110";
        read_data_2 <= x"11011011";		

        wait for clk_period;

        assert ALUResult = x"01010010";

        report "Testing slt";
        instruction <= x"002A";
        read_data_1 <= x"00002000";
        read_data_2 <= x"0000A000";

        wait for clk_period;

        assert ALUResult = x"00000001";

        report "Testing LUI";
        ALUOp <= "11";
        ALUSrc <= '1';
        instruction <= x"1234";

        wait for clk_period;

        assert ALUResult = x"12340000";		

        report "Testing BEQ";
        ALUOp <= "10";
        read_data_1 <= x"0000A000";
        ALUSrc <= '0';
        wait for clk_period;

        assert Zero = '1';

        report "Testing LW/SW";
        ALUSrc <= '1';
        ALUOp <= "01";
        read_data_1 <= x"00000002";
        instruction <= x"00A0";

        wait for clk_period;

        assert ALUResult = x"000000A2";

        report "ALU test complete";

        wait;
    end process;

    END;
