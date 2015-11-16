----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:53:48 11/12/2015 
-- Design Name: 
-- Module Name:    dac_line - Behavioral 
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
USE ieee.numeric_std.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dac_line is
    Port ( p0 : in  STD_LOGIC_VECTOR (31 downto 0);
           p1 : in  STD_LOGIC_VECTOR (31 downto 0);
              reset : in STD_LOGIC;
           x : out  STD_LOGIC;
           y : out  STD_LOGIC;
           sync : out  STD_LOGIC;
              done : out STD_LOGIC;
           clk : in  STD_LOGIC);
end dac_line;

architecture Behavioral of dac_line is
signal din : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal dac_sync : STD_LOGIC;
signal x0 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal y0 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal x1 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal y1 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

TYPE POSSIBLE_STATES IS (waiting, updating);
signal state : POSSIBLE_STATES;

signal dx : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal dy : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal err : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin
piso: entity work.piso 
PORT MAP(
	clk => clk,
	reset => reset,
	enable => '1',
	parallel_in => din,
	x_out => x,
	y_out => y,
	sync => dac_sync
);
sync <= dac_sync;
process(clk, p0, p1, reset)
begin
	if(reset = '1') then
		state <= waiting;
	elsif rising_edge(clk) then
		case state is
			when waiting =>
				x0 <= p0(31 downto 16);
				y0 <= p0(15 downto 0);
				x1 <= p1(31 downto 16);
				y1 <= p1(15 downto 0);
				 
				dx <= std_logic_vector(unsigned(p1(31 downto 16)) - unsigned(p0(31 downto 16)));
				dy <= std_logic_vector(unsigned(p1(15 downto 0)) - unsigned(p0(15 downto 0)));
			   
			
				err <= std_logic_vector((256 * unsigned(dy)) - unsigned(dx));
				
				state <= updating;
				done <= '1';
			when updating =>
				done <= '0';
				if(dac_sync = '1') then
					din <= x0 & y0;          
					err <= std_logic_vector(unsigned(err) + (256 * unsigned(dy)));
					x0 <= std_logic_vector(unsigned(x0) + 128);
					if signed(err) > 0 then
						y0 <= std_logic_vector(unsigned(y0) + 128);
						err <= std_logic_vector(unsigned(err) - (256 * unsigned(dx)));
					end if;    
				end if;                     
				if(unsigned(x0) >= unsigned(x1)) then
					state <= waiting;
				else
					state <= updating;
				end if;
		end case;
	end if;
end process;
end Behavioral;

