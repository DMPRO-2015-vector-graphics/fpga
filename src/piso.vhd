library ieee; 

use ieee.std_logic_1164.all;

entity piso is

generic ( n : integer := 24);

port( clk: in std_logic; 
      reset: in std_logic; 
      enable: in std_logic; --enables shifting 
      parallel_in: in std_logic_vector(31 downto 0); 
      x_out: out std_logic; --serial output
		y_out: out std_logic;
      sync: out std_logic

);
end piso;

architecture behavioral of piso is

signal temp_x: std_logic_vector(n-1 downto 0) := (others => '0');
signal temp_y: std_logic_vector(n-1 downto 0) := (others => '0');
TYPE POSSIBLE_STATES IS (waiting, shifting);
signal state : POSSIBLE_STATES;
begin

process(clk,reset)
    variable shift_counter: integer := 0;
begin

    if(reset = '1') then
        temp_x <= (others => '0');
		  temp_y <= (others => '0');
        state <= waiting;
        shift_counter := 0;
        sync <= '1';
    elsif(rising_edge(clk)) then
        case state is
            when waiting =>
                shift_counter := 0;
                temp_x <= "00000000" & parallel_in(31 downto 16);
					 temp_y <= "00000000" & parallel_in(15 downto 0);
                x_out <= '0';
					 y_out <= '0';
                sync <= '1';
                if(enable = '1') then
                    state <= shifting;
                else
                    state <= waiting;
                end if;
            when shifting =>
                shift_counter := shift_counter + 1;
                x_out <= temp_x(n-1);
					 y_out <= temp_y(n-1);
                temp_x <= temp_x(n-2 downto 0) & '0';
					 temp_y <= temp_y(n-2 downto 0) & '0';
                
                if (shift_counter >= n) then
                    state <= waiting;
						  sync <= '1';
                else
						  sync <= '0';
                    state <= shifting;
                end if; 
        end case;
    end if;
end process;

end behavioral;
