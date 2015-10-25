LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.defs.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_Registers IS
END tb_Registers;
 
ARCHITECTURE behavior OF tb_Registers IS 

    --Constants
    constant ADDR_WIDTH : natural := 5;
    constant DATA_WIDTH : natural := 32;

    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal read_reg_1 : std_logic_vector(ADDR_WIDTH-1 downto 0) := "00001";
    signal read_reg_2 : std_logic_vector(ADDR_WIDTH-1 downto 0) := "00001";
    signal read_reg_3 : std_logic_vector(ADDR_WIDTH-1 downto 0) := "00010";
    signal RegWrite : std_logic := '0';
    signal MemToReg : std_logic := '0';
    signal RegDst : std_logic := '0';
    signal ALUResult : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";
    signal dmem_data : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";

 	--Outputs
    signal read_data_1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal read_data_2 : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
    uut: entity work.Registers port map(
        clk => clk,
        reset => reset,
        read_reg_1 => read_reg_1,
        read_reg_2 => read_reg_2,
        read_reg_3 => read_reg_3,
        RegWrite => RegWrite,
        RegDst => RegDst,
        MemToReg => MemToReg,
        ALUResult => ALUResult,
        dmem_data => dmem_data,
        read_data_1 => read_data_1,
        read_data_2 => read_data_2
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
        -- reset
        wait for clk_period/2;
        reset <= '1';
        -- Prep for write
        wait for clk_period;
        RegWrite <= '1';
        reset <= '0';
        -- Write to r1 from alu result
        read_reg_2 <= "00001";
        ALUResult <= x"DEADBEEF";
        MemToReg <= '0';
        RegDst <= '0';
        wait for clk_period*2;
        read_reg_1 <= "00001";
        RegWrite <= '0';
        assert read_data_1 = x"DEADBEEF";
        -- insert stimulus here 
        wait;
   end process;

END;
