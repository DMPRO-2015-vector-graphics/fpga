library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity dac_line is
    port ( 
        p0 : in  STD_LOGIC_VECTOR (31 downto 0);
        p1 : in  STD_LOGIC_VECTOR (31 downto 0);
        reset : in STD_LOGIC;
		dout : out STD_LOGIC_VECTOR(31 downto 0);
        done : out STD_LOGIC;
		sync : in STD_LOGIC;
        clk : in  STD_LOGIC;
        enable : in STD_LOGIC
    );
end dac_line;

architecture Behavioral of dac_line is
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
    
    signal neg_x : STD_LOGIC;
    signal neg_y : STD_LOGIC;

begin
    process(clk, p0, p1, reset, sync)
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


                    if(unsigned(p1(31 downto 16)) > unsigned(p0(31 downto 16))) then
                        dx <= std_logic_vector(unsigned(p1(31 downto 16)) - unsigned(p0(31 downto 16)));
                        step_x <= std_logic_vector((unsigned(p1(31 downto 16)) - unsigned(p0(31 downto 16))) srl 7);
                        neg_x <= '0';
                    else
                        dx <= std_logic_vector(unsigned(p0(31 downto 16)) - unsigned(p1(31 downto 16)));
                        step_x <= std_logic_vector((signed(((unsigned(p0(31 downto 16))) - unsigned(p1(31 downto 16)))) srl 7));
                        neg_x <= '1';
                    end if;
                    
                    if(unsigned(p1(15 downto 0)) > unsigned(p0(15 downto 0))) then
                        dy <= std_logic_vector(unsigned(p1(15 downto 0)) - unsigned(p0(15 downto 0)));
                        step_y <= std_logic_vector((unsigned(p1(15 downto 0)) - unsigned(p0(15 downto 0))) srl 7);
                        neg_y <= '0';
                    else
                        dx <= std_logic_vector(unsigned(p0(15 downto 0)) - unsigned(p1(15 downto 0)));
                        step_y <= std_logic_vector((signed(((unsigned(p0(15 downto 0))) - unsigned(p1(15 downto 0)))) srl 7));
                        neg_y <= '1';
                    end if;
                    
                    err <= x"0000" & std_logic_vector(1024 * (unsigned(unsigned(p1(15 downto 0)) - unsigned(p0(15 downto 0))) - unsigned(unsigned(p1(31 downto 16)) - unsigned(p0(31 downto 16)))));

                    if enable = '1' then
                        state <= updating;
                    else
                        state <= waiting;
                    end if;                      
                when updating =>
                    done <= '0';
                    if(sync = '1') then
                        dout <= x0(15 downto 0) & y0(15 downto 0 );
                        if neg_x = '1' then                        
                            x0 <= std_logic_vector(unsigned(x0) - unsigned(step_x));
                        else 
                            x0 <= std_logic_vector(unsigned(x0) + unsigned(step_x));
                        end if;
                        if signed(err) > 0 then
                            if neg_y = '1' then
                                y0 <= std_logic_vector(unsigned(y0) - unsigned(step_y));
                            else
                                y0 <= std_logic_vector(unsigned(y0) + unsigned(step_y));
                            end if;
                            err <= std_logic_vector(unsigned(err) - ((2*unsigned(step_x)) * unsigned(dx)));
                        end if;
                        err <= std_logic_vector(unsigned(err) + ((2*unsigned(step_y)) * unsigned(dy)));
                    end if;
                    if neg_x = '1' and unsigned(x1) >= unsigned(x0) then
                        done <= '1';
                        state <= finished;
                    elsif neg_x = '0' and unsigned(x0) >= unsigned(x1) then
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
