library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity dac_line is
    port ( 
        p0 : in  STD_LOGIC_VECTOR (31 downto 0);
        p1 : in  STD_LOGIC_VECTOR (31 downto 0);
        reset : in STD_LOGIC;
        x : out  STD_LOGIC;
        y : out  STD_LOGIC;
        sync : out  STD_LOGIC;
        done : out STD_LOGIC;
        clk : in  STD_LOGIC;
        enable : in STD_LOGIC
    );
end dac_line;

architecture Behavioral of dac_line is
    signal din : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal dac_sync : STD_LOGIC;
    signal x0 : STD_LOGIC_VECTOR (16 downto 0) := (others => '0');
    signal y0 : STD_LOGIC_VECTOR (16 downto 0) := (others => '0');
    signal x1 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal y1 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

    TYPE POSSIBLE_STATES IS (waiting, updating, finished);
    signal state : POSSIBLE_STATES;

    signal dx : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal dy : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal err : STD_LOGIC_VECTOR(47 downto 0) := (others => '0');

    signal step_x : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal step_y : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

begin
    piso: entity work.piso 
    PORT MAP(
        clk => clk,
        reset => reset,
        enable => enable,
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
                when finished =>
                    done <= '1';
                    state <= waiting;
                when waiting =>
                    done <= '0';
                    x0 <= "0" & p0(31 downto 16);
                    y0 <= "0" & p0(15 downto 0);
                    x1 <= p1(31 downto 16);
                    y1 <= p1(15 downto 0);

                    dx <= std_logic_vector(unsigned(p1(31 downto 16)) - unsigned(p0(31 downto 16)));
                    dy <= std_logic_vector(unsigned(p1(15 downto 0)) - unsigned(p0(15 downto 0)));

                    step_x <= std_logic_vector((unsigned(p1(31 downto 16)) - unsigned(p0(31 downto 16))) / 128);
                    step_y <= std_logic_vector((unsigned(p1(15 downto 0)) - unsigned(p0(15 downto 0))) / 128);

                    err <= x"0000" & std_logic_vector(1024 * (unsigned(unsigned(p1(15 downto 0)) - unsigned(p0(15 downto 0))) - unsigned(unsigned(p1(31 downto 16)) - unsigned(p0(31 downto 16)))));

                    if enable = '1' then
                        state <= updating;
                    else
                        state <= waiting;
                    end if;                      
                when updating =>
                    done <= '0';
                    if(dac_sync = '1') then
                        din <= x0(15 downto 0) & y0(15 downto 0 );               
                        x0 <= std_logic_vector(unsigned(x0) + unsigned(step_x));
                        if signed(err) > 0 then
                            y0 <= std_logic_vector(unsigned(y0) + unsigned(step_y));
                            err <= std_logic_vector(unsigned(err) - ((2*unsigned(step_x)) * unsigned(dx)));
                        end if;
                        err <= std_logic_vector(unsigned(err) + ((2*unsigned(step_y)) * unsigned(dy)));
                    end if;                     
                    if(unsigned(x0) >= unsigned(x1)) then
                        done <= '1';
                        state <= finished;
                    else
                        state <= updating;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
