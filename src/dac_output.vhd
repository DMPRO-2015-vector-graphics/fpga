library IEEE;
Library UNISIM;
use IEEE.STD_LOGIC_1164.all;
use UNISIM.vcomponents.all;
use ieee.numeric_std.all;

entity dac_output is
    generic (
        DATA_WIDTH : natural := 136;
        ADDR_WIDTH : natural := 10
    );
    port ( 
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        dac_clk    : out STD_LOGIC;
        dac_sync   : out STD_LOGIC;
        dac0_data  : out STD_LOGIC;
        dac1_data  : out STD_LOGIC;
        address    : out STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
        data       : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        enable     : in  STD_LOGIC;
        primitive_count : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0)
    );
end dac_output;

architecture Behavioral of dac_output is
type output_states is (fetch, decode, draw, waiting);

signal state : output_states := fetch;
signal primitive : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
signal next_addr : STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);

--PRIMITIVE
signal p_type : STD_LOGIC_VECTOR(7 downto 0);
signal p0 : STD_LOGIC_VECTOR(31 downto 0);
signal p1 : STD_LOGIC_VECTOR(31 downto 0);
signal p2 : STD_LOGIC_VECTOR(31 downto 0);
signal p3 : STD_LOGIC_VECTOR(31 downto 0);

--LINE
signal line_enable : STD_LOGIC := '0';
signal line_done : STD_LOGIC := '0';
signal line_x : STD_LOGIC := '0';
signal line_y : STD_LOGIC := '0';
signal line_sync : STD_LOGIC := '0';

--BEZ QUAD
signal quad_enable : STD_LOGIC := '0';
signal quad_done : STD_LOGIC := '0';
signal quad_x : STD_LOGIC := '0';
signal quad_y : STD_LOGIC := '0';
signal quad_sync : STD_LOGIC := '0';
begin
-- FORWARD CLK
ODDR2_inst : ODDR2
port map (
    Q => dac_clk, -- 1-bit output data
    C0 => clk, -- 1-bit clock input
    C1 => (not clk), -- 1-bit clock input
    CE => '1',  -- 1-bit clock enable input
    D0 => '1',   -- 1-bit data input (associated with C0)
    D1 => '0',   -- 1-bit data input (associated with C1)
    R => '0',    -- 1-bit reset input
    S => '0'     -- 1-bit set input
);
 
-- DRAW LINES
dac_line: entity work.dac_line 
port map (
    p0 => p0,
    p1 => p1,
    x => line_x,
    y => line_y,
    sync => line_sync,
    reset => reset,
    done => line_done,
    enable => line_enable,
    clk => clk
);

-- DRAW QUADRATIC BEZIER
dac_quad_bez: entity work.quad_bezier 
port map(
		clk => clk,
		enable => quad_enable,
		p0 => p0,
		p1 => p1,
		p2 => p2,
		reset => reset,
		x => quad_x,
		y => quad_y,
		sync => quad_sync,
		done => quad_done
);
 
process(clk, reset)
begin
    address <= next_addr;

    if(reset = '1') then
        state <= fetch;
        next_addr <= (others => '0');
    elsif rising_edge(clk) then
        case state is
            when fetch =>
                primitive <= data;
					 next_addr <= std_logic_vector(unsigned(next_addr) + 1);
					 if enable = '1' then
				 		  state <= decode;
					 else
						  state <= fetch;
					 end if;

                line_enable <= '0';					 
            when decode =>
                p_type <= data(135 downto 128);
					      line_enable <= '0';
                     quad_enable <= '1';							
                     p0 <= data(127 downto 96);
                     p1 <= data(95 downto 64);
                     p2 <= data(63 downto 32);
                     p3 <= data(31 downto 0);
                     
                     if unsigned(next_addr) > unsigned(primitive_count) then
                         next_addr <= (others => '0');
                     end if;               
                     if enable = '1' then
                         state <= draw;
                     else
                         state <= fetch;
                     end if;    
                when draw =>
					     if p_type = "00000000" then
						        line_enable <= '0';
								  quad_enable <= '0';
								  state <= fetch;
                    elsif p_type = "00000001" then --LINE
								  dac0_data <= line_x;
								  dac1_data <= line_y;
								  dac_sync <= line_sync;
                          line_enable <= '1';
							     quad_enable <= '0';
                          state <= waiting;
                    elsif p_type = "00000010" then --QUAD BEZ
                          dac0_data <= quad_x;
								  dac1_data <= quad_y;
								  dac_sync <= quad_sync;
                          line_enable <= '0';
							     quad_enable <= '1';
                          state <= waiting;
--                    elsif p_type = "00000111" then --CUBE BEZ         
                    else
								  line_enable <= '0';
								  quad_enable <= '0';
								  state <= fetch;
                    end if;
					when waiting =>
					    if p_type = "00000001" then --LINE
   						  dac0_data <= line_x;
							  dac1_data <= line_y;
							  dac_sync <= line_sync;
							  line_enable <= '1';
							  quad_enable <= '0';
						     if line_done = '1' then
							      line_enable <= '0';
							      state <= fetch;
							  else
									state <= waiting;
							  end if;
						 elsif p_type = "00000010" then --QUAD BEZ
						     dac0_data <= quad_x;
							  dac1_data <= quad_y;
							  dac_sync <= quad_sync;
							  line_enable <= '0';
							  quad_enable <= '1';
						     if line_done = '1' then
							      quad_enable <= '0';
							      state <= fetch;
							  else
									state <= waiting;
							  end if;
						 end if;
        end case;    
    end if;
end process;
end Behavioral;