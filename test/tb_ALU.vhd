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
    signal immediate : immediate_t;
    signal op : op_t;


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
        immediate => immediate,
        op => op,
        zero => zero,
        alu_result_out => alu_result_out,
        prim_result => prim_result
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
        immediate <= x"1234";
        op <= mov;
        wait for clk_period/2;
        assert alu_result_out = x"00001234";
        wait for clk_period/2;
        -- movu
        report "MOVU";
        immediate <= x"04D2";
        read_data_1 <= x"0000FFFF";
        op <= movu;
        wait for clk_period/2;
        assert alu_result_out = x"04D2FFFF";
        report "ALU test complete";
        wait;
    end process;
END;
