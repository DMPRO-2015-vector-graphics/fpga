library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity line2 is
    port ( 
        clk :in STD_LOGIC;
        enable : in STD_LOGIC;
        p0 : in  STD_LOGIC_VECTOR (31 downto 0);
        p1 : in  STD_LOGIC_VECTOR (31 downto 0);
        reset : in STD_LOGIC;
		sync : in STD_LOGIC;
        dout : out STD_LOGIC_VECTOR(31 downto 0);
        done : out STD_LOGIC
    );
end line2;

architecture Behavioral of line2 is
    signal temp_x : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_y : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal p_start : STD_LOGIC_VECTOR(31 downto 0);
    signal p_end : STD_LOGIC_VECTOR(31 downto 0);

    signal i : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal t : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal u : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    TYPE POSSIBLE_STATES IS (waiting, updating, finished);
    signal state : POSSIBLE_STATES;

begin

process(clk, p0, reset, sync)
begin
    if(reset = '1') then
        state <= waiting;
    elsif rising_edge(clk) then
        case state is
            when finished =>
                done <= '1';
                state <= waiting;
            when waiting =>
                done <= '0';
                p_start <= p0;
                p_end <= p1;
                i <= (others => '0');
                if enable = '1' then
                    state <= updating;
                else
                    state <= waiting;
                end if;
            when updating =>
				done <= '0';
				if sync = '1' then
                    i <= std_logic_vector(unsigned(i) + 8);			
					dout <= temp_x(30 downto 15) & temp_y(30 downto 15);
				else
					t <= i & "00000";
					u <= std_logic_vector(1024 - unsigned(i)) & "00000";
	
                    temp_x <= std_logic_vector((unsigned(u) * unsigned(p_start(31 downto 16))) + (unsigned(t) * unsigned(p_end(31 downto 16))));
					temp_y <= std_logic_vector((unsigned(u) * unsigned(p_start(15 downto 0))) + (unsigned(t) * unsigned(p_end(15 downto 0))));
				end if;
					
				if unsigned(i) >= (1024 + 8) then
					done <= '1';
					state <= finished;
				elsif enable = '0' then
					state <= waiting;
				else
					state <= updating;
				end if;
        end case;
    end if;
end process;
end Behavioral;

