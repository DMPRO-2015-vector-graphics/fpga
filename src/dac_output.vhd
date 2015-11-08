----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:14:05 11/04/2015 
-- Design Name: 
-- Module Name:    dac_output - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dac_output is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           dac_sync : out  STD_LOGIC;
           dac_clk : out  STD_LOGIC;
           dac_x : out  STD_LOGIC;
           dac_y : out  STD_LOGIC;
           mem_data : in  STD_LOGIC_VECTOR (135 downto 0);
           mem_address : out  STD_LOGIC_VECTOR (9 downto 0));
end dac_output;

architecture Behavioral of dac_output is
signal piso_in : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
	piso: piso PORT MAP(
		clk => clk,
		reset => reset,
		enable => '1',
		parallel_in => piso_in,
		x_out => dac_x,
		y_out => dac_y,
		sync => dac_sync
	);
	dac_clk <= clk;
	
	process(clk, reset)
	begin
   	 if rising_edge(clk) then
           if dac_sync = '1' then
                piso_in <= (others => '1');
			  end if;
	    end if;
	end process;
end Behavioral;
