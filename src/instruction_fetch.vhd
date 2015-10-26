library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity instruction_fetch is
    Port ( clk : in STD_LOGIC;
	        reset : in STD_LOGIC;
		     address : in  STD_LOGIC_VECTOR (18 downto 0);
           instruction : out  STD_LOGIC_VECTOR (31 downto 0);
			  valid : out STD_LOGIC
		    );
end instruction_fetch;

architecture Behavioral of instruction_fetch is
type fetch_states is (low, high, rst);
signal state : fetch_states;
signal temp : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal addr : STD_LOGIC_VECTOR(18 downto 0) := (others => '0');
signal instr : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal low_valid : STD_LOGIC := '0';
signal high_valid : STD_LOGIC := '0';
begin
    sram: entity work.sram
    port map(
        clk => clk,
        address => addr,
        data_out => temp,
        wr => '0',
		  data_in => (others => '0')
    );
	 
	 process(clk, address, reset)
    begin
	     if(reset = '1') then
		      instruction <= (others => '0');
		      state <= rst;
		  end if;
        if(rising_edge(clk)) then
            case state is
				    when rst =>
					     addr <= address;
						  high_valid <= '0';
						  low_valid <= '0';
						  if(reset = '0') then
						      state <= low;
                    end if;
				    when low =>
				        instr(15 downto 0) <=  temp;
						  addr <= std_logic_vector(unsigned(addr) + 2);
						  state <= high;
						  low_valid <= '1';
					 when high =>
                    instr(31 downto 16) <= temp;
						  addr <= std_logic_vector(unsigned(addr) + 2);
						  state <= low;
						  high_valid <= '1';
						  instruction <= instr;
            end case;
        end if;	  
		  valid <= low_valid and high_valid;
    end process;

end Behavioral;

