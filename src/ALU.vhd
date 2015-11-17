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
        immediate : in immediate_t;
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

    alu_perform_op: process(op, read_data_1, read_data_2, read_data_3, read_data_4, read_data_5, immediate, alu_source_a, alu_source_b)
    begin
        case op is
            when mov =>
                alu_result <= read_data_1(31 downto 16) & immediate;
                prim_result <= (others => '0');
            when add =>
                alu_result <= std_logic_vector(signed(read_data_2) + signed(read_data_3));
                prim_result <= (others => '0');
            when beq =>
                alu_result <= std_logic_vector(signed(read_data_1) - signed(read_data_2));
                prim_result <= (others => '0');
            when lsl =>
                alu_result <= std_logic_vector(unsigned(read_data_2) sll to_integer(signed(immediate)));
                prim_result <= (others => '0');
            when line =>
                alu_result <= (others => '0');
                prim_result <= x"01" & read_data_2 & read_data_3 & x"0000000000000000";
            when bezquad =>
                alu_result <= (others => '0');
                prim_result <= x"02" & read_data_2 & read_data_3 & read_data_4 & x"00000000";
            when bezqube =>
                alu_result <= (others => '0');
                prim_result <= x"03" & read_data_2 & read_data_3 & read_data_4 & read_data_5;
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

