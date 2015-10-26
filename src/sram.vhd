library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sram is
    Port (
	        clk : in STD_LOGIC;
			  we : out  STD_LOGIC;
           oe : out  STD_LOGIC;
           a : out  STD_LOGIC_VECTOR (18 downto 0);
           io : inout  STD_LOGIC_VECTOR (15 downto 0);
			  ce : out  STD_LOGIC;
			  
			  address : in  STD_LOGIC_VECTOR (18 downto 0);
			  data_in : in  STD_LOGIC_VECTOR (15 downto 0);
			  data_out : out  STD_LOGIC_VECTOR (15 downto 0);
           wr : in STD_LOGIC
			  );
           
end sram;

architecture Behavioral of sram is
begin
	process(clk, wr, address)
	begin
		if(rising_edge(clk)) then
			if(wr = '1') then
				oe <= '1';
				we <= '0';
				io <= data_in;
			else
				oe <= '0';
				we <= '1';
				data_out <= io;
			end if;
		end if;
		a <= address;
		ce <= '1';
	end process;
end Behavioral;
