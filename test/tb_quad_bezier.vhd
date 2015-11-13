--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:57:04 10/27/2015
-- Design Name:   
-- Module Name:   D:/git/fpga/test/tb_quad_bezier.vhd
-- Project Name:  fpga
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: quad_bezier
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_quad_bezier IS
END tb_quad_bezier;
 
ARCHITECTURE behavior OF tb_quad_bezier IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT quad_bezier
    PORT(
         clk : IN  std_logic;
         p0 : IN  std_logic_vector(31 downto 0);
         p1 : IN  std_logic_vector(31 downto 0);
         p2 : IN  std_logic_vector(31 downto 0);
         pout : OUT  std_logic_vector(31 downto 0);
			i  : IN std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal p0 : std_logic_vector(31 downto 0) := (others => '0');
   signal p1 : std_logic_vector(31 downto 0) := (others => '0');
   signal p2 : std_logic_vector(31 downto 0) := (others => '0');
	signal i  : std_logic_vector(9 downto 0) := (others => '0');
 	--Outputs
   signal pout : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: quad_bezier PORT MAP (
          clk => clk,
          p0 => p0,
          p1 => p1,
          p2 => p2,
          pout => pout,
			 i => i
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
      wait for 100 ns;	

      wait for clk_period*10;
		p0 <= x"00010001";
		p1 <= x"008000FF";
		p2 <= x"00FF0001";
		i  <= "0000000001";
		wait for clk_period;
		i  <= "0000000010";
		wait for clk_period;
		i  <= "0000000100";
		wait for clk_period;
		i  <= "0000001000";
		wait for clk_period;
		i  <= "0000010000";
		wait for clk_period;
		i  <= "0000100000";
		wait for clk_period;
		i  <= "0001100000";
		wait for clk_period;
		i  <= "0000111000";
		wait for clk_period;
		i  <= "0000001000";
		wait for clk_period;
		i  <= "0010001000";
		wait for clk_period;
		i  <= "1111111111";
		wait for clk_period;
      -- insert stimulus here 

      wait;
   end process;

END;
