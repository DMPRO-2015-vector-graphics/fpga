library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Defs.all;

entity Control is
    generic (
        INSTR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32
    );
    port (
        clk                 : in std_logic;
        reset               : in std_logic;
        processor_enable    : in std_logic;
        instruction         : in instruction_t;
        control_signals_out : out control_signals_t
    );
end Control;

architecture Behavioral of Control is
    signal state : state_t := S_FETCH;
begin

    state_transitions: process(clk, reset, processor_enable)
    begin
        if reset = '1' or processor_enable = '0' then
            state <= S_FETCH;
        elsif rising_edge(clk) then
            control_signals_out.pc_write <= false;
            if state = S_FETCH then
                control_signals_out.pc_write <= true;
                state <= S_EXECUTE;
            elsif state = S_EXECUTE then
                if get_op(instruction.opcode) = str or get_op(instruction.opcode) = ldr or get_op(instruction.opcode) = ldrp or get_op(instruction.opcode) = strp then
                    state <= S_STALL;
                else
                    state <= S_FETCH;
                end if;
            else
                state <= S_FETCH;
            end if;
        end if;
    end process;

    update: process(state)
    begin
        if state = S_FETCH then
            control_signals_out.reg_write <= false;
            control_signals_out.prim_reg_write <= false;
            control_signals_out.mem_to_reg <= FROM_ALU;
            control_signals_out.prim_mem_to_reg <= FROM_ALU;
            control_signals_out.reg_dest <= REG1;
            control_signals_out.prim_mem_write <= false;
            control_signals_out.mem_write <= false;
            control_signals_out.alu_source_a <= REG1;
            control_signals_out.alu_source_b <= REG1;
            control_signals_out.branch <= false;
            control_signals_out.jump <= false;
        elsif state = S_EXECUTE then
            control_signals_out.op <= get_op(instruction.opcode);
            case get_op(instruction.opcode) is
                when nop => 
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when jmp =>
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= true;
                when add =>
                    control_signals_out.reg_write <= true;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG2;
                    control_signals_out.alu_source_b <= REG3;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when mov =>
                    control_signals_out.reg_write <= true;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= IMM;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when lsl =>
                    control_signals_out.reg_write <= true;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG2;
                    control_signals_out.alu_source_b <= IMM;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when line =>
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= true;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when bezquad =>
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= true;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when bezqube =>
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= true;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when ldr =>
                    control_signals_out.reg_write <= true;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_MEM;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when str =>
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= true;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when ldrp =>
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= true;
                    control_signals_out.mem_to_reg <= FROM_MEM;
                    control_signals_out.prim_mem_to_reg <= FROM_MEM;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when strp =>
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= true;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when beq =>
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG2;
                    control_signals_out.branch <= true;
                    control_signals_out.jump <= false;
                when others =>
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source_a <= REG1;
                    control_signals_out.alu_source_b <= REG1;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
            end case;
        elsif state = S_STALL then
           null; 
        else
            control_signals_out.reg_write <= false;
            control_signals_out.prim_reg_write <= false;
            control_signals_out.mem_to_reg <= FROM_ALU;
            control_signals_out.prim_mem_to_reg <= FROM_ALU;
            control_signals_out.reg_dest <= REG1;
            control_signals_out.prim_mem_write <= false;
            control_signals_out.mem_write <= false;
            control_signals_out.alu_source_a <= REG1;
            control_signals_out.alu_source_b <= REG1;
            control_signals_out.branch <= false;
            control_signals_out.jump <= false;
        end if;
    end process;
end Behavioral;

