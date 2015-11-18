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
    type output_states is (fetch, decode, draw);
    
	 signal piso_in : STD_LOGIC_VECTOR(31 downto 0);
	 signal piso_enable : STD_LOGIC;
	 signal sync : STD_LOGIC;
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
    signal line_data : STD_LOGIC_VECTOR(31 downto 0);

    --BEZ QUAD
    signal quad_enable : STD_LOGIC := '0';
    signal quad_done : STD_LOGIC := '0';
    signal quad_data : STD_LOGIC_VECTOR(31 downto 0);
    
    --BEZ CUBE
    signal cube_enable : STD_LOGIC := '0';
    signal cube_done : STD_LOGIC := '0';
    signal cube_data : STD_LOGIC_VECTOR(31 downto 0);
begin

    dac_sync <= sync;

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
	 
	piso: entity work.piso 
    port map(
        clk => clk,
        reset => reset,
        enable => piso_enable,
        parallel_in => piso_in,
        x_out => dac0_data,
        y_out => dac1_data,
        sync => sync
    );

    -- DRAW LINES
    dac_line: entity work.dac_line 
    port map (
        p0 => p0,
        p1 => p1,
		dout => line_data,
        reset => reset,
        done => line_done,
		sync => sync,
        enable => line_enable,
        clk => clk
    );

    -- DRAW QUADRATIC BEZIER
    dac_quad_bez: entity work.quad_bezier 
    port map(
        clk => clk,
        enable => quad_enable,
		dout => quad_data,
        p0 => p0,
        p1 => p1,
        p2 => p2,
        reset => reset,
		sync => sync,
        done => quad_done
    );
    
    -- DRAW CUBIC BEZIER
    dac_cube_bez: entity work.cube_bezier 
    port map(
        clk => clk,
        enable => cube_enable,
		dout => cube_data,
        p0 => p0,
        p1 => p1,
        p2 => p2,
        p3 => p3,
        reset => reset,
		sync => sync,
        done => cube_done
    );

    process(clk, reset, next_addr)
    begin
        address <= next_addr;

        if(reset = '1') then
            state <= fetch;
            next_addr <= (others => '0');
				piso_enable <= '0';
				line_enable <= '0';
				quad_enable <= '0';
                cube_enable <= '0';
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
						  
                    quad_enable <= '0';
                    line_enable <= '0';
				    piso_enable <= '0';
                    cube_enable <= '0';
                    piso_in <= (others => '0');						  
                when decode =>
                    p_type <= primitive(135 downto 128);							
                    p0 <= primitive(127 downto 96);
                    p1 <= primitive(95 downto 64);
                    p2 <= primitive(63 downto 32);
                    p3 <= primitive(31 downto 0);

                    piso_in <= (others => '0');
					line_enable <= '0';
                    quad_enable <= '0';
                    cube_enable <= '0';
					piso_enable <= '0';
					if unsigned(next_addr) > unsigned(primitive_count) then
                        next_addr <= (others => '0');
                    end if;               
                    
					if enable = '1' then
                        state <= draw;
                    else
                        state <= fetch;
                    end if;    
                when draw =>
					piso_enable <= '1';
                    if p_type = "00000000" then
                        line_enable <= '0';
                        quad_enable <= '0';
                        cube_enable <= '0';
                        state <= fetch;
                        piso_in <= (others => '0');
                    elsif p_type = "00000001" then --LINE
                        piso_in <= line_data;
                        line_enable <= '1';
                        quad_enable <= '0';
                        cube_enable <= '0';
                        if line_done = '1' then
                            line_enable <= '0';
                            piso_enable <= '0';
                            state <= fetch;
                        else
                            state <= draw;
                        end if;
                    elsif p_type = "00000010" then --QUAD BEZ
                        piso_in <= quad_data;
                        line_enable <= '0';
                        cube_enable <= '0';
                        quad_enable <= '1';
                        if quad_done = '1' then
                            quad_enable <= '0';
                            piso_enable <= '0';
                            state <= fetch;
                        else
                            state <= draw;
                        end if;
                    elsif p_type = "00000011" then --CUBE BEZ
                        piso_in <= cube_data;
                        line_enable <= '0';
                        cube_enable <= '1';
                        quad_enable <= '0';
                        if cube_done = '1' then
                            cube_enable <= '0';
                            piso_enable <= '0';
                            state <= fetch;
                        else
                            state <= draw;
                        end if;
                    else
                        line_enable <= '0';
                        cube_enable <= '0';
                        quad_enable <= '0';
                        piso_in <= (others => '0');
                        state <= fetch;
                    end if;
            end case;    
        end if;
    end process;
end Behavioral;
