----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:08:50 10/27/2015 
-- Design Name: 
-- Module Name:    quad_bezier - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity quad_bezier is
    Port ( clk :in STD_LOGIC;
	        p0 : in  STD_LOGIC_VECTOR (31 downto 0);
           p1 : in  STD_LOGIC_VECTOR (31 downto 0);
           p2 : in  STD_LOGIC_VECTOR (31 downto 0);
			  i  : in  STD_LOGIC_VECTOR (9  downto 0);
           pout : out  STD_LOGIC_VECTOR (31 downto 0));
end quad_bezier;

architecture Behavioral of quad_bezier is
signal temp_x : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal temp_y : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    process(clk, p0, p1, p2, i)
	     variable t: integer := 0;
		  variable u: integer := 0;
        variable a: integer := 0;
        variable b: integer := 0;
        variable c: integer := 0;
		  variable local : integer := 0;
	 begin
	     local := to_integer(unsigned(i));
		  if(rising_edge(clk)) then	      	  
            t := local * 32;
				u := (1024 - local) * 32;		
				a := (u * u) / 32768;
				b := ((t * u) / 32768) * 2;
				c := (t * t) / 32768;
					
				temp_x <= std_logic_vector(unsigned(a * unsigned(p0(31 downto 16)) + b * unsigned(p1(31 downto 16)) + c * unsigned(p2(31 downto 16))) / 32768);
				temp_y <= std_logic_vector(unsigned(a * unsigned(p0(15 downto 0)) + b * unsigned(p1(15 downto 0)) + c * unsigned(p2(15 downto 0))) / 32768);

				pout <= temp_x(15 downto 0) & temp_y(15 downto 0);
		  end if;	  
	 end process;
end Behavioral;

