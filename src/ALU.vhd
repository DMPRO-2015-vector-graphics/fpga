library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    generic (
        DATA_WIDTH : integer := 16;
        ADDR_WIDTH : integer := 16;
        INSTR_WIDTH: integer := 32
    );
    Port ( clk: in STD_LOGIC;
           read_data_1 : in  std_logic_vector (DATA_WIDTH-1 downto 0);
           read_data_2 : in  std_logic_vector (DATA_WIDTH-1 downto 0);
           instruction : in  std_logic_vector (INSTR_WIDTH-1 downto 0);
           ALUOp : in  std_logic_vector (1 downto 0);
           Zero : out  std_logic;
           ALUResult : inout  std_logic_vector (DATA_WIDTH-1 downto 0);
           ALUSrc : in  std_logic);
end ALU;

architecture Behavioral of ALU is
    type Operation_t is (ALU_ADD, ALU_SUB, ALU_SLT, ALU_AND, ALU_OR, ALU_A, ALU_B, ALU_SL16);
    signal operation: Operation_t := ALU_ADD;

--signal func: std_logic_vector ( 5 downto 0);
--signal immediate: std_logic_vector (15 downto 0);
begin

    alu_control: process(read_data_1, read_data_2, ALUOp, instruction)	
    begin

        case ALUOp is
            when "00"=> --R-type
                case instruction(7 downto 0) is -- assume sh bits is never usedS
                    when x"20"=>
                        operation <= ALU_ADD;
                    when x"24"=>
                        operation <= ALU_AND;
                    when x"25"=>
                        operation <= ALU_OR;
                    when x"2A"=>
                        operation <= ALU_SLT;
                    when x"22"=>
                        operation <= ALU_SUB;
                    when others=>
                        null;
                end case;
            when "01"=> --I-Type (LDI, SW, LW)
                operation <= ALU_ADD;
            when "10"=> --BEQ
                operation <= ALU_SUB;
            when others=>
                null;
        end case;
    end process;

    alu_perform_op: process(operation, read_data_1, read_data_2, instruction, ALUSrc)
        variable operatorA: std_logic_vector (DATA_WIDTH-1 downto 0);
        variable operatorB: std_logic_vector (DATA_WIDTH-1 downto 0);
    begin
        operatorA := read_data_1;
        if ALUSrc = '0' then
            operatorB := read_data_2;

        else
            operatorB := instruction(DATA_WIDTH-1 downto 0);
        end if;

        case operation is
            when ALU_ADD=>
                ALUResult <= std_logic_vector(signed(operatorA) + signed(operatorB));
            when ALU_SUB=>
                ALUResult <= std_logic_vector(signed(operatorA) - signed(operatorB));
            when ALU_SLT=>
                if signed(read_data_1) < signed(read_data_2) then
                    ALUResult <= x"0001"; -- TODO: Fix magic number
                else
                    ALUResult <= x"0000"; -- TODO: Fix magic number
                end if;
            when ALU_AND=>
                ALUResult <= operatorA and operatorB;
            when ALU_OR=>
                ALUResult <= operatorA or operatorB;
            when ALU_A=>
                ALUResult <= operatorA;
            when ALU_B=>
                ALUResult <= operatorB;
            when others=>
                null;
        end case;

    end process;

    alu_zero: process(ALUResult)
    begin
        if ALUResult = x"00000000" then
            Zero <= '1';
        else
            Zero <= '0';
        end if;
    end process;

end Behavioral;

