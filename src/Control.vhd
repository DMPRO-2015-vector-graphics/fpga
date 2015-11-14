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

    state_transitions: process(clk, reset, processor_enable)
    begin
        if reset = '1' then
            state <= S_FETCH;
        elsif rising_edge(clk) then
            control_signals_out.pc_write <= false;
            if state = S_FETCH then
                control_signals_out.pc_write <= true;
                state <= S_EXECUTE;
            elsif state = S_EXECUTE then
                if get_op(instruction.opcode) = str or get_op(instruction.opcode) = ldr then
                    state <= S_STALL;
                else
                    state <= S_FETCH;
                end if;
            else
                state <= S_FETCH;
            end if;
        end if;
    end process;

    update: process(instruction, state)
    begin
        if state = S_FETCH then
            control_signals_out.reg_write <= false;
            control_signals_out.mem_write <= false;
        elsif state = S_EXECUTE then
            --control_signals_out.op = get_op(instruction.opcode);
            case get_op(instruction.opcode) is
                when nop => -- NOP
                    control_signals_out.branch <= false;
                    control_signals_out.mem_to_reg <= FROM_ALU;
                    control_signals_out.jump <= false;
                    control_signals_out.mem_write <= false;
                    control_signals_out.alu_source <= REG2;
                    control_signals_out.reg_write <= false;
                --when b"000100" => -- beq
                --    control_signals_out.branch <= true;
                --    control_signals_out.jump <= '0';
                --    control_signals_out.op <= "10";
                --    control_signals_out.mem_write <= '0';
                --    control_signals_out.alu_source <= '0';
                --when b"100011" => -- LW
                --    control_signals_out.mem_to_reg <= '1';
                --    control_signals_out.branch <= '0';
                --    control_signals_out.jump <= '0';
                --    control_signals_out.op <= "01";
                --    control_signals_out.mem_write <= '0';
                --    control_signals_out.alu_source <= '1';
                --    control_signals_out.reg_write <= '1';
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
                --when others =>
                --    null;
            end case;
        elsif state = S_STALL then
            null;
        end if;
    end process;
end Behavioral;

