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
        -- nop
        report "NOP";
        instruction <= make_instruction(x"00000000");
        wait for clk_period;
        assert control_signals_out.reg_write = false;
        assert control_signals_out.prim_reg_write = false;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = false;
        assert control_signals_out.alu_source_a = REG1;
        assert control_signals_out.alu_source_b = REG1;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = nop;
        assert control_signals_out.pc_write = true;
        wait for clk_period;
        assert control_signals_out.pc_write = false;
        -- jmp
        report "JMP";
        instruction <= make_instruction(x"0402AAAA");
        wait for clk_period;
        assert control_signals_out.reg_write = false;
        assert control_signals_out.prim_reg_write = false;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = false;
        assert control_signals_out.alu_source_a = REG1;
        assert control_signals_out.alu_source_b = REG1;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = true;
        assert control_signals_out.op = jmp;
        assert control_signals_out.pc_write = true;
        wait for clk_period;
        assert control_signals_out.pc_write = false;
        -- add
        report "ADD";
        instruction <= make_instruction(x"0C211000");
        wait for clk_period;
        assert control_signals_out.reg_write = true;
        assert control_signals_out.prim_reg_write = false;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = false;
        assert control_signals_out.alu_source_a = REG2;
        assert control_signals_out.alu_source_b = REG3;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = add;
        assert control_signals_out.pc_write = true;
        wait for clk_period;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        -- mov
        report "MOV";
        instruction <= make_instruction(x"08201234");
        assert control_signals_out.reg_write = true;
        assert control_signals_out.prim_reg_write = false;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = false;
        assert control_signals_out.alu_source_a = IMM;
        assert control_signals_out.alu_source_b = REG1;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = mov;
        assert control_signals_out.pc_write = true;
        wait for clk_period;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        -- lsl
        report "LSL";
        instruction <= make_instruction(x"10220005");
        assert control_signals_out.reg_write = true;
        assert control_signals_out.prim_reg_write = false;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = false;
        assert control_signals_out.alu_source_a = REG2;
        assert control_signals_out.alu_source_b = IMM;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = lsl;
        assert control_signals_out.pc_write = true;
        wait for clk_period;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        -- line
        report "LINE";
        instruction <= make_instruction(x"14011000");
        assert control_signals_out.reg_write = false;
        assert control_signals_out.prim_reg_write = true;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = false;
        assert control_signals_out.alu_source_a = REG1;
        assert control_signals_out.alu_source_b = REG1;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = line;
        assert control_signals_out.pc_write = true;
        wait for clk_period;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        -- bezquad
        report "BEZQUAD";
        instruction <= make_instruction(x"180110C0");
        assert control_signals_out.reg_write = false;
        assert control_signals_out.prim_reg_write = true;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = false;
        assert control_signals_out.alu_source_a = REG1;
        assert control_signals_out.alu_source_b = REG1;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = bezquad;
        assert control_signals_out.pc_write = true;
        wait for clk_period;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        -- bezqube
        report "BEZQUBE";
        instruction <= make_instruction(x"1C0110C8");
        assert control_signals_out.reg_write = false;
        assert control_signals_out.prim_reg_write = true;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = false;
        assert control_signals_out.alu_source_a = REG1;
        assert control_signals_out.alu_source_b = REG1;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = bezqube;
        assert control_signals_out.pc_write = true;
        wait for clk_period;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        -- ldr
        report "LDR";
        instruction <= make_instruction(x"2027FFFF");
        assert control_signals_out.reg_write = true;
        assert control_signals_out.prim_reg_write = false;
        assert control_signals_out.mem_to_reg = FROM_MEM;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = false;
        assert control_signals_out.alu_source_a = REG1;
        assert control_signals_out.alu_source_b = REG1;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = ldr;
        assert control_signals_out.pc_write = true;
        wait for clk_period*2;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        -- str
        report "STR";
        instruction <= make_instruction(x"2427FFFF");
        assert control_signals_out.reg_write = false;
        assert control_signals_out.prim_reg_write = false;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = true;
        assert control_signals_out.alu_source_a = REG1;
        assert control_signals_out.alu_source_b = REG1;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = str;
        assert control_signals_out.pc_write = true;
        wait for clk_period*2;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        -- ldrp
        report "LDRP";
        instruction <= make_instruction(x"28000001");
        assert control_signals_out.reg_write = false;
        assert control_signals_out.prim_reg_write = true;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = true;
        assert control_signals_out.alu_source_a = REG1;
        assert control_signals_out.alu_source_b = REG1;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = ldrp;
        assert control_signals_out.pc_write = true;
        wait for clk_period*2;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        -- strp
        report "STRP";
        instruction <= make_instruction(x"2C000001");
        assert control_signals_out.reg_write = false;
        assert control_signals_out.prim_reg_write = false;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = true;
        assert control_signals_out.alu_source_a = REG1;
        assert control_signals_out.alu_source_b = REG1;
        assert control_signals_out.branch = false;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = strp;
        assert control_signals_out.pc_write = true;
        wait for clk_period*2;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        -- beq
        report "BEQ";
        instruction <= make_instruction(x"3022000A");
        assert control_signals_out.reg_write = false;
        assert control_signals_out.prim_reg_write = false;
        assert control_signals_out.mem_to_reg = FROM_ALU;
        assert control_signals_out.reg_dest = REG1;
        assert control_signals_out.mem_write = false;
        assert control_signals_out.alu_source_a = REG1;
        assert control_signals_out.alu_source_b = REG2;
        assert control_signals_out.branch = true;
        assert control_signals_out.jump = false;
        assert control_signals_out.op = beq;
        assert control_signals_out.pc_write = true;
        wait for clk_period*2;
        assert control_signals_out.pc_write = false;
        wait for clk_period;
        wait;
    end process;
end;
