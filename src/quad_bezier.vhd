library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cube_bezier is
    port ( 
        clk :in STD_LOGIC;
        enable : in STD_LOGIC;
        p0 : in  STD_LOGIC_VECTOR (31 downto 0);
        p1 : in  STD_LOGIC_VECTOR (31 downto 0);
        p2 : in  STD_LOGIC_VECTOR (31 downto 0);
        p3 : in  STD_LOGIC_VECTOR (31 downto 0);
        reset : in STD_LOGIC;
		sync : in STD_LOGIC;
        dout : out STD_LOGIC_VECTOR(31 downto 0);
        done : out STD_LOGIC
    );
end cube_bezier;

architecture Behavioral of cube_bezier is
    signal temp_x : STD_LOGIC_VECTOR(111 downto 0) := (others => '0');
    signal temp_y : STD_LOGIC_VECTOR(111 downto 0) := (others => '0');

    signal bez_p0 : STD_LOGIC_VECTOR(31 downto 0);
    signal bez_p1 : STD_LOGIC_VECTOR(31 downto 0);
    signal bez_p2 : STD_LOGIC_VECTOR(31 downto 0);
    signal bez_p3 : STD_LOGIC_VECTOR(31 downto 0);

    signal i : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal t : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal u : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal a : STD_LOGIC_VECTOR(47 downto 0) := (others => '0');
    signal b : STD_LOGIC_VECTOR(95 downto 0) := (others => '0');
    signal c : STD_LOGIC_VECTOR(95 downto 0) := (others => '0');
    signal d : STD_LOGIC_VECTOR(47 downto 0) := (others => '0');

    TYPE POSSIBLE_STATES IS (waiting, updating, finished);
    signal state : POSSIBLE_STATES;

begin

process(clk, p0, p1, p2, reset, sync)
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
						bez_p0 <= p0;
						bez_p1 <= p1;
						bez_p2 <= p2;
                        bez_p3 <= p3;
						i <= (others => '0');
						if enable = '1' then
							 state <= updating;
						else
							 state <= waiting;
						end if;
				  when updating =>
				      done <= '0';
						if sync = '1' then
							i <= std_logic_vector(unsigned(i) + 2);			
							dout <= temp_x(30 downto 15) & temp_y(30 downto 15);
						else
							t <= i & "00000";
							u <= std_logic_vector(1024 - unsigned(i)) & "00000";
							
							a <= std_logic_vector(((unsigned(u) * unsigned(u)) srl 15) * unsigned(u) srl 15);
							b <= std_logic_vector((((unsigned(t) * unsigned(u)) srl 15) * unsigned(u) srl 15) * 3);
							c <= std_logic_vector((((unsigned(t) * unsigned(t)) srl 15) * unsigned(u) srl 15) * 3);
                            d <= std_logic_vector(((unsigned(t) * unsigned(t)) srl 15) * unsigned(t) srl 15);
							                         
							temp_x <= std_logic_vector(((unsigned(a) * unsigned(bez_p0(31 downto 16))) + (unsigned(b) * unsigned(bez_p1(31 downto 16))) + (unsigned(c) * unsigned(bez_p2(31 downto 16))) + (unsigned(d) * unsigned(bez_p3(31 downto 16)))));
							temp_y <= std_logic_vector(((unsigned(a) * unsigned(bez_p0(15 downto 0))) + (unsigned(b) * unsigned(bez_p1(15 downto 0))) + (unsigned(c) * unsigned(bez_p2(15 downto 0))) + (unsigned(d) * unsigned(bez_p3(15 downto 0)))));
						end if;
					
						if unsigned(i) >= (1024 + 2) then
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

