library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity dac_output is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           vref_sleep : out STD_LOGIC;
           dac_clk : out  STD_LOGIC;
			  dac_sync : out  STD_LOGIC;
           dac0_data : out  STD_LOGIC;
           dac1_data    : out  STD_LOGIC
    );
end dac_output;

architecture Behavioral of dac_output is
signal piso_in : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

--signal p1 : STD_LOGIC_VECTOR(31 downto 0) := x"40004000";
signal p0 : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal p1 : STD_LOGIC_VECTOR(31 downto 0) := x"40001000";


type draw_states is (draw_p1, draw_p2, draw_p3);--, draw_p4, draw_p5, draw_p6, draw_p7, draw_p8);
signal state : draw_states := draw_p1;

signal clk48 : STD_LOGIC;
signal clk30 : STD_LOGIC;
signal clk10 : STD_LOGIC;
signal clk20 : STD_LOGIC;
signal locked : STD_LOGIC;
signal done : STD_LOGIC;

begin
-- DIVIDE CLK
divider : entity work.pll
port map (
    -- Clock in ports
    CLK_IN1 => clk,
    -- Clock out ports
    CLK_OUT1 => clk48,
    CLK_OUT2 => clk10,
    CLK_OUT3 => clk20,
    CLK_OUT4 => clk30,
    -- Status and control signals
    RESET  => reset,
    LOCKED => locked
);

-- FORWARD CLK
ODDR2_inst : ODDR2
port map (
    Q => dac_clk, -- 1-bit output data
    C0 => clk10, -- 1-bit clock input
    C1 => (not clk10), -- 1-bit clock input
    CE => '1',  -- 1-bit clock enable input
    D0 => '1',   -- 1-bit data input (associated with C0)
    D1 => '0',   -- 1-bit data input (associated with C1)
    R => '0',    -- 1-bit reset input
    S => '0'     -- 1-bit set input
);
 
dac_line: entity work.dac_line 
PORT MAP (
    p0 => p0,
    p1 => p1,
    x => dac0_data,
    y => dac1_data,
    sync => dac_sync,
    reset => '0',
    done => done,
    clk => clk10
);
 
vref_sleep <= '1';
process(clk10, reset)
begin
    if(reset = '1') then
        state <= draw_p1;
        p0 <= x"00000000";
        p1 <= x"40001000";
    elsif rising_edge(clk10) then
        case state is
            when draw_p1 =>
                if done = '1' then
                    p0 <= x"00000000";
                    p1 <= x"FFFFFFFF";
                    state <= draw_p2;
                end if;
				when draw_p2 =>
                if done = '1' then
					     p0 <= x"00000000";
                    p1 <= x"10004000";  
                    state <= draw_p3;
                end if;
				when draw_p3 =>
                if done = '1' then
                    p0 <= x"00000000";
                    p1 <= x"40001000";
                    state <= draw_p3;
                end if;
        end case;    
    end if;
end process;
end Behavioral;