library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.Defs.all;

entity Control is
    generic (
        INSTR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32;
        SCENE_MEM_ADDR_WIDTH : integer := 10
    );
    port (
        clk                     : in std_logic;
        reset                   : in std_logic;
        processor_enable        : in std_logic;
        opcode                  : in opcode_t;
        control_signals_out     : out control_signals_t;
        reset_if                : out std_logic;
        primitive_counter_out   : out std_logic_vector(SCENE_MEM_ADDR_WIDTH-1 downto 0)
    );
end Control;

architecture Behavioral of Control is
    signal state : state_t := S_OFFLINE;
    signal primitive_counter : std_logic_vector(SCENE_MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
begin

    state_transitions: process(clk, reset, processor_enable)
    begin
        if reset = '1' or processor_enable = '0' then
            state <= S_OFFLINE;
        elsif rising_edge(clk) then
            control_signals_out.pc_write <= false;
            if state = S_OFFLINE then
                state <= S_FETCH;
            elsif state = S_FETCH then
                control_signals_out.pc_write <= true;
                state <= S_EXECUTE;
            elsif state = S_EXECUTE then
                if get_op(opcode) = ldr or get_op(opcode) = ldrp or get_op(opcode) = beq or get_op(opcode) = jmp then
                    state <= S_STALL;
                else
                    if get_op(opcode) = line or get_op(opcode) = bezqube or get_op(opcode) = bezquad then
                        primitive_counter <= std_logic_vector(unsigned(primitive_counter) + 1);
                    end if;
                    state <= S_FETCH;
                end if;
            else
                state <= S_FETCH;
            end if;
        end if;
    end process;

    update: process(state, opcode)
    begin
        if state = S_FETCH then
            reset_if <= '0';
            control_signals_out.reg_write <= false;
            control_signals_out.prim_reg_write <= false;
            control_signals_out.mem_to_reg <= FROM_ALU;
            control_signals_out.prim_mem_to_reg <= FROM_ALU;
            control_signals_out.reg_dest <= REG1;
            control_signals_out.prim_mem_write <= false;
            control_signals_out.mem_write <= false;
            control_signals_out.branch <= false;
            control_signals_out.jump <= false;
        elsif state = S_EXECUTE then
            control_signals_out.op <= get_op(opcode);
            reset_if <= '0';
            case get_op(opcode) is
                when nop => 
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when jmp =>
                    reset_if <= '1';
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
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
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when movu =>
                    control_signals_out.reg_write <= true;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when movl =>
                    control_signals_out.reg_write <= true;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
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
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
                when beq =>
                    reset_if <= '1';
                    control_signals_out.reg_write <= false;
                    control_signals_out.prim_reg_write <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.prim_mem_to_reg <= FROM_ALU;
                    control_signals_out.reg_dest <= REG1;
                    control_signals_out.prim_mem_write <= false;
                    control_signals_out.mem_write <= false;
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
                    control_signals_out.branch <= false;
                    control_signals_out.jump <= false;
            end case;
        elsif state = S_STALL then
            reset_if <= '0';
        else
            reset_if <= '0';
            control_signals_out.reg_write <= false;
            control_signals_out.prim_reg_write <= false;
            control_signals_out.mem_to_reg <= FROM_ALU;
            control_signals_out.prim_mem_to_reg <= FROM_ALU;
            control_signals_out.reg_dest <= REG1;
            control_signals_out.prim_mem_write <= false;
            control_signals_out.mem_write <= false;
            control_signals_out.branch <= false;
            control_signals_out.jump <= false;
        end if;
    end process;
end Behavioral;

