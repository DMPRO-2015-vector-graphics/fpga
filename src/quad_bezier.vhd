library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity quad_bezier is
    port ( 
        clk :in STD_LOGIC;
        enable : in STD_LOGIC;
        p0 : in  STD_LOGIC_VECTOR (31 downto 0);
        p1 : in  STD_LOGIC_VECTOR (31 downto 0);
        p2 : in  STD_LOGIC_VECTOR (31 downto 0);
        reset : in STD_LOGIC;
        x : out  STD_LOGIC;
        y : out  STD_LOGIC;
        sync : out  STD_LOGIC;
        done : out STD_LOGIC
    );
end quad_bezier;

architecture Behavioral of quad_bezier is
    signal temp_x : STD_LOGIC_VECTOR(59 downto 0) := (others => '0');
    signal temp_y : STD_LOGIC_VECTOR(59 downto 0) := (others => '0');
    signal din : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal dac_sync : STD_LOGIC;

    signal bez_p0 : STD_LOGIC_VECTOR(31 downto 0);
    signal bez_p1 : STD_LOGIC_VECTOR(31 downto 0);
    signal bez_p2 : STD_LOGIC_VECTOR(31 downto 0);

    signal i : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal t : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal u : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal a : STD_LOGIC_VECTOR(21 downto 0) := (others => '0');
    signal b : STD_LOGIC_VECTOR(32 downto 0) := (others => '0');
    signal c : STD_LOGIC_VECTOR(21 downto 0) := (others => '0');

    TYPE POSSIBLE_STATES IS (waiting, updating, finished);
    signal state : POSSIBLE_STATES;

begin
    piso: entity work.piso 
    port map(
        clk => clk,
        reset => reset,
        enable => '1',
        parallel_in => din,
        x_out => x,
        y_out => y,
        sync => dac_sync
    );
    sync <= dac_sync;


    process(clk, p0, p1, p2, reset)
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
                    i <= (others => '0');
                    if enable = '1' then
                        state <= updating;
                    else
                        state <= waiting;
                    end if;
                when updating =>
                    done <= '0';
                    if dac_sync = '1' then
                        i <= std_logic_vector(unsigned(i) + 64);			
                        din <= temp_x(59 downto 44) & temp_y(59 downto 44);
                    end if;
                    t <= i & "00000";
                    u <= std_logic_vector(1024 - unsigned(i)) & "00000";

                    a <= std_logic_vector((unsigned(u) * unsigned(u)));
                    b <= std_logic_vector(((unsigned(t) * unsigned(u)))) & "0";
                    c <= std_logic_vector((unsigned(t) * unsigned(t)));

                    temp_x <= std_logic_vector(((unsigned(a) * unsigned(bez_p0(31 downto 16))) + (unsigned(b) * unsigned(bez_p1(31 downto 16))) + (unsigned(c) * unsigned(bez_p2(31 downto 16)))));
                    temp_y <= std_logic_vector(((unsigned(a) * unsigned(bez_p0(15 downto 0))) + (unsigned(b) * unsigned(bez_p1(15 downto 0))) + (unsigned(c) * unsigned(bez_p2(15 downto 0)))));


                    if unsigned(i) >= 1025 then
                        done <= '1';
                        state <= finished;
                    else
                        state <= updating;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;

