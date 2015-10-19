library ieee; 

use ieee.std_logic_1164.all;

entity piso is

generic ( n : integer := 24);

port( clk: in std_logic; 
      reset: in std_logic; 
      enable: in std_logic; --enables shifting 
      parallel_in: in std_logic_vector(15 downto 0); 
      s_out: out std_logic; --serial output
      sync: out std_logic

);
end piso;

architecture behavioral of piso is

signal temp_reg: std_logic_vector(n-1 downto 0) := (others => '0');
TYPE POSSIBLE_STATES IS (waiting, shifting);
signal state : POSSIBLE_STATES;
begin

process(clk,reset)
    variable shift_counter: integer := 0;
begin

    if(reset = '1') then
        temp_reg <= (others => '0');   
        state <= waiting;
        shift_counter := 0;
        sync <= '1';
    elsif(clk'event and clk='1') then
        case state is
            when waiting =>
                shift_counter := 0;
                temp_reg <= "00000000" & parallel_in;
                s_out <= '0';
                sync <= '1';
                if(enable = '1') then
                    state <= shifting;
                else
                    state <= waiting;
                end if;
            when shifting =>
                shift_counter := shift_counter + 1;
                s_out <= temp_reg(n-1);
                temp_reg <= temp_reg(n-2 downto 0) & '0';
                sync <= '0';
                if (shift_counter >= n) then
                    state <= waiting;
                else
                    state <= shifting;
                end if; 
        end case;
    end if;
end process;

end behavioral;
