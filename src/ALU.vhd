library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity ALU is
    generic (
        DATA_WIDTH : integer := 32;
        ADDR_WIDTH : integer := 19;
        INSTR_WIDTH : integer := 32;
        PRIM_WIDTH : integer := 136
    );
    port ( 
        read_data_1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        read_data_2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        read_data_3 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        read_data_4 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        read_data_5 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        instruction : in instruction_t;
        op : in op_t;
        zero : out std_logic;
        alu_result_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        prim_result : out std_logic_vector(PRIM_WIDTH-1 downto 0);
        alu_source_a : in alu_source_t;
        alu_source_b : in alu_source_t
    );
end ALU;

architecture Behavioral of ALU is
    type Operation_t is (ALU_ADD, ALU_SUB, ALU_SLT, ALU_AND, ALU_OR, ALU_A, ALU_B, ALU_SL16);
    signal alu_result : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
begin

    alu_perform_op: process(op, read_data_1, read_data_2, read_data_3, read_data_4, read_data_5, instruction, alu_source_a, alu_source_b)
        variable operatorA: std_logic_vector(DATA_WIDTH-1 downto 0);
        variable operatorB: std_logic_vector(DATA_WIDTH-1 downto 0);
    begin

        if alu_source_a = REG1 then
            operatorA := read_data_1;
        elsif alu_source_a = REG2 then
            operatorA := read_data_2;
        elsif alu_source_a = REG3 then
            operatorA := read_data_3;
        elsif alu_source_a = REG4 then
            operatorA := read_data_4;
        elsif alu_source_a = REG5 then
            operatorA := read_data_5;
        elsif alu_source_a = IMM then
            operatorA := std_logic_vector(resize(signed(instruction.immediate), 32));
        else
            operatorA := read_data_1;
        end if;

        if alu_source_b = REG1 then
            operatorB := read_data_1;
        elsif alu_source_b = REG2 then
            operatorB := read_data_2;
        elsif alu_source_b = REG3 then
            operatorB := read_data_3;
        elsif alu_source_b = REG4 then
            operatorB := read_data_4;
        elsif alu_source_b = REG5 then
            operatorB := read_data_5;
        elsif alu_source_b = IMM then
            operatorB := std_logic_vector(resize(signed(instruction.immediate), 32));
        else
            operatorB := read_data_1;
        end if;

        case op is
            when mov =>
                alu_result <= operatorA;
                prim_result <= (others => '0');
            when add =>
                alu_result <= std_logic_vector(signed(operatorA) + signed(operatorB));
                prim_result <= (others => '0');
            when beq =>
                alu_result <= std_logic_vector(signed(operatorA) - signed(operatorB));
                prim_result <= (others => '0');
            when lsl =>
                alu_result <= std_logic_vector(unsigned(operatorA) sll to_integer(signed(operatorB)));
                prim_result <= (others => '0');
            when line =>
                alu_result <= (others => '0');
                prim_result <= x"00" & read_data_2 & read_data_3 & x"0000000000000000";
            when bezquad =>
                alu_result <= (others => '0');
                prim_result <= x"01" & read_data_2 & read_data_3 & read_data_4 & x"00000000";
            when bezqube =>
                alu_result <= (others => '0');
                prim_result <= x"02" & read_data_2 & read_data_3 & read_data_4 & read_data_5;
            when others=>
                alu_result <= (others => '0');
                prim_result <= (others => '0');
        end case;
    end process;

    alu_zero: process(alu_result)
    begin
        if alu_result = x"00000000" then
            Zero <= '1';
        else
            Zero <= '0';
        end if;
    end process;

    alu_result_out <= alu_result;

end Behavioral;

