library ieee; 

use ieee.std_logic_1164.all;

entity piso is

generic ( n : integer := 24);

port( clk: in std_logic; 
      reset: in std_logic; 
      enable: in std_logic; -- Enables shifting 
      parallel_in: in std_logic_vector(31 downto 0); -- 32-bit number. Upper half is X, lower half is Y.
      x_out: out std_logic; -- Serial output X
        y_out: out std_logic; -- Serial output Y
      sync: inout std_logic -- DAC Sync

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
                -- A zero byte as well as 16 data bits needed for the 24-bit shift register on the DACs
                temp_x <= x"00" & parallel_in(31 downto 16);
                temp_y <= x"00" & parallel_in(15 downto 0);
                x_out <= '0';
                y_out <= '0';
                sync <= '1';
                if(enable = '1') then
                    state <= shifting;
                else
                    state <= waiting;
                end if;
            when shifting =>
                sync <= '0';
                shift_counter := shift_counter + 1;
                x_out <= temp_x(n-1);
                y_out <= temp_y(n-1);
                temp_x <= temp_x(n-2 downto 0) & '0';
                temp_y <= temp_y(n-2 downto 0) & '0';
                if (shift_counter >= n) then
                    state <= waiting;
                else
                    state <= shifting;
                end if; 
        end case;
    end if;
end process;
end behavioral;
