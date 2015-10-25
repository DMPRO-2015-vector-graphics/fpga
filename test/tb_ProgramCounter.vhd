LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.defs.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_ProgramCounter IS
END tb_ProgramCounter;
 
ARCHITECTURE behavior OF tb_ProgramCounter IS 

    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal pc_write : std_logic := '0';
    signal jump : std_logic := '0';
    signal branch : std_logic := '0';
    signal zero : std_logic := '0';
    signal instruction : std_logic_vector(25 downto 0) := "00000000000000000000000000";

 	--Outputs
    signal address_out : std_logic_vector(7 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
    uut: entity work.ProgramCounter port map(
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
        assert address_out = x"00";
        -- Regular increment
        pc_write <= '1';
        wait for clk_period;
        assert address_out = x"01";
        jump <= '1';
        instruction <= "00000000000000000010000000";
        wait for clk_period;
        -- JMP
        assert address_out = x"80";
        jump <= '0';
        branch <= '1';
        zero <= '1';
        instruction <= "00000000000000000001000000";
        wait for clk_period;
        -- Branch
        assert address_out = x"c1";
        pc_write <= '0';
        jump <= '0';
        branch <= '0';
        zero <= '0';
        -- insert stimulus here 
        wait;
   end process;
END;
