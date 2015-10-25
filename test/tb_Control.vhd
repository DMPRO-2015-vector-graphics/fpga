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
    signal instruction : std_logic_vector(31 downto 0) := x"00000000";

    -- Outputs
    signal RegDst : std_logic;
    signal Branch : std_logic;
    signal Jump : std_logic;
    signal MemToReg : std_logic;
    signal ALUOp : std_logic_vector(1 downto 0);
    signal MemWrite : std_logic;
    signal ALUSrc : std_logic;
    signal RegWrite : std_logic;
    signal PCWrite : std_logic;

    -- Clock
    constant clk_period : time := 10 ns;
begin

    uut: entity work.Control
    port map(
        clk => clk,
        reset => reset,
        processor_enable => processor_enable,
        instruction => instruction,
        RegDst => RegDst,
        Branch => Branch,
        Jump => Jump,
        MemToReg => MemToReg,
        ALUOp => ALUOp,
        MemWrite => MemWrite,
        ALUSrc => ALUSrc,
        RegWrite => RegWrite,
        PCWrite => PCWrite
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
        assert RegDst = '1';
        assert Branch = '0';
        assert MemToReg = '0';
        assert Jump = '0';
        assert ALUOp = "00";
        assert MemWrite = '0';
        assert ALUSrc = '0';
        assert RegWrite = '1';
        -- beq
        instruction <= x"10000000";
        wait for clk_period;
        assert Branch = '1';
        assert Jump = '0';
        assert ALUOp = "10";
        assert MemWrite = '0';
        assert ALUSrc = '0';
        -- LW
        instruction <= x"8C000000";
        wait for clk_period;
        assert MemToReg = '1';
        assert Branch = '0';
        assert Jump = '0';
        assert ALUOp = "01";
        assert MemWrite = '0';
        assert ALUSrc = '1';
        assert RegWrite = '1';
        -- SW
        instruction <= x"AC000000";
        wait for clk_period;
        assert Branch = '0';
        assert Jump = '0';
        assert ALUOp = "01";
        assert ALUSrc = '1';
        assert MemWrite = '1';
        assert RegWrite = '0';
        wait for clk_period*2;
        -- J
        instruction <= x"08000000";
        wait for clk_period;
        assert Jump = '1';
        assert MemWrite = '0';
        -- LUI
        instruction <= x"3C000000";
        wait for clk_period;
        assert ALUOp = "11";
        assert RegWrite = '1';
        assert ALUSrc = '1';
        assert MemToReg = '0';
        assert RegDst = '0';
        assert MemWrite = '0';
        wait;
    end process;
end;
