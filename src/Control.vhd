library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Defs.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values                  
--use IEEE.NUMERIC_STD.ALL;


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

    update: process(clk)
    begin
        if reset = '1' or processor_enable = '0' then
            state <= S_FETCH;
        elsif rising_edge(clk) then
            if state = S_FETCH then
                state <= S_EXECUTE;
                control_signals_out.reg_write <= false;
                control_signals_out.mem_write <= false;
            elsif state = S_EXECUTE then
                control_signals_out.op <= get_op(instruction.opcode);
                case get_op(instruction.opcode) is
                    when nop => 
                        control_signals_out.reg_write <= false;
                        control_signals_out.prim_reg_write <= false;
                        control_signals_out.mem_to_reg <= FROM_ALU;
                        control_signals_out.reg_dest <= REG1;
                        control_signals_out.mem_write <= false;
                        control_signals_out.alu_source_a <= REG1;
                        control_signals_out.alu_source_b <= REG1;
                        control_signals_out.branch <= false;
                        control_signals_out.jump <= false;
                        state <= S_FETCH;
                    when jmp =>
                        control_signals_out.reg_write <= false;
                        control_signals_out.prim_reg_write <= false;
                        control_signals_out.mem_to_reg <= FROM_ALU;
                        control_signals_out.reg_dest <= REG1;
                        control_signals_out.mem_write <= false;
                        control_signals_out.alu_source_a <= REG1;
                        control_signals_out.alu_source_b <= REG1;
                        control_signals_out.branch <= false;
                        control_signals_out.jump <= true;
                        state <= S_FETCH;
                    when add =>
                        control_signals_out.reg_write <= true;
                        control_signals_out.prim_reg_write <= false;
                        control_signals_out.mem_to_reg <= FROM_ALU;
                        control_signals_out.reg_dest <= REG1;
                        control_signals_out.mem_write <= false;
                        control_signals_out.alu_source_a <= REG2;
                        control_signals_out.alu_source_b <= REG3;
                        control_signals_out.branch <= false;
                        control_signals_out.jump <= false;
                        state <= S_FETCH;
                    --when b"101011" => --SW
                    --    control_signals_out.branch <= '0';
                    --    control_signals_out.jump <= '0';
                    --    control_signals_out.op <= "01";
                    --    control_signals_out.alu_source <= '1';
                    --    control_signals_out.mem_write <= '1';
                    --    control_signals_out.reg_write <= '0';
                    --when b"000010" => --J
                    --    control_signals_out.jump <= '1';
                    --    control_signals_out.mem_write <= '0';
                    --when b"001111" => --lui
                    --    control_signals_out.op <= "11";
                    --    control_signals_out.reg_write <= '1';
                    --    control_signals_out.alu_source <= '1';
                    --    control_signals_out.mem_to_reg <= '0';
                    --    control_signals_out.mem_write <= '0';
                    when others =>
                        state <= S_FETCH;
                end case;
            elsif state = S_STALL then
                state <= S_FETCH;
            end if;
        end if;
    end process;
end Behavioral;

