LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;
 
ENTITY tb_ProgramCounter IS
END tb_ProgramCounter;
 
ARCHITECTURE behavior OF tb_ProgramCounter IS 

    constant ADDR_WIDTH : integer := 19;

    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal pc_write : pc_write_t;
    signal jump : jump_t;
    signal branch : branch_t;
    signal zero : std_logic := '0';
    signal instruction : instruction_t;

 	--Outputs
    signal address_out : std_logic_vector(ADDR_WIDTH-1 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.ProgramCounter
    generic map(
        ADDR_WIDTH => ADDR_WIDTH
    )
    port map(
        clk => clk,
        reset => reset,
        pc_write => pc_write,
        jump => jump,
        branch => branch,
        zero => zero,
        instruction => instruction,
        address_out => address_out
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
    end process;
 

    -- Stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        wait for clk_period / 2;
        reset <= '1';
        wait for clk_period;	
        reset <= '0';
        assert unsigned(address_out) = 0;
        -- Regular increment
        pc_write <= true;
        wait for clk_period;
        assert unsigned(address_out) = 1;
        jump <= true;
        instruction <= make_instruction(x"0402AAAA");
        wait for clk_period;
        -- JMP
        assert address_out = "0101010101010101010";
        jump <= false;
        branch <= true;
        zero <= '1';
        instruction <= make_instruction(x"3022000A");
        wait for clk_period;
        -- Branch
        assert address_out = "0101010101010110101";
        pc_write <= false;
        jump <= false;
        branch <= false;
        zero <= '0';
        wait;
   end process;
END;
