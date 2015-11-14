library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;

entity tb_Control is
end tb_Control;

architecture behavior of tb_Control is
    -- Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal processor_enable : std_logic := '0';
    signal instruction : instruction_t;

    -- Outputs
    signal control_signals_out : control_signals_t;
    -- Clock
    constant clk_period : time := 10 ns;
begin

    uut: entity work.Control
    port map(
        clk => clk,
        reset => reset,
        processor_enable => processor_enable,
        instruction => instruction,
        control_signals_out => control_signals_out
    );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        wait for clk_period/2;
        -- Reset
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        processor_enable <= '1';
        wait for clk_period;
        -- R-Type
        instruction <= x"00000000";
        wait for clk_period;
        assert Branch = '0';
        assert mem_to_reg = '0';
        assert Jump = '0';
        assert ALUOp = "00";
        assert mem_write = '0';
        assert alu_source = '0';
        assert reg_write = '1';
        -- beq
        instruction <= x"10000000";
        wait for clk_period;
        assert Branch = '1';
        assert Jump = '0';
        assert ALUOp = "10";
        assert mem_write = '0';
        assert alu_source = '0';
        -- LW
        instruction <= x"8C000000";
        wait for clk_period;
        assert mem_to_reg = '1';
        assert Branch = '0';
        assert Jump = '0';
        assert ALUOp = "01";
        assert mem_write = '0';
        assert alu_source = '1';
        assert reg_write = '1';
        -- SW
        instruction <= x"AC000000";
        wait for clk_period;
        assert Branch = '0';
        assert Jump = '0';
        assert ALUOp = "01";
        assert alu_source = '1';
        assert mem_write = '1';
        assert reg_write = '0';
        wait for clk_period*2;
        -- J
        instruction <= x"08000000";
        wait for clk_period;
        assert Jump = '1';
        assert mem_write = '0';
        -- LUI
        instruction <= x"3C000000";
        wait for clk_period;
        assert ALUOp = "11";
        assert reg_write = '1';
        assert alu_source = '1';
        assert mem_to_reg = '0';
        assert mem_write = '0';
        wait;
    end process;
end;
