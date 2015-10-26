library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Defs.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values                  
--use IEEE.NUMERIC_STD.ALL;


entity Control is
    generic (
        INSTR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32
    );
    port (
             clk                 : in std_logic;
             reset               : in std_logic;
             processor_enable    : in std_logic;
             instruction         : in std_logic_vector(INSTR_WIDTH-1 downto 0);		
             RegDst              : out std_logic := '0';
             Branch              : out std_logic := '0';
             Jump                : out std_logic := '0';
             MemToReg            : out std_logic := '0';
             ALUOp               : out std_logic_vector(1 downto 0) := "00";
             MemWrite            : out std_logic := '0';
             ALUSrc              : out std_logic := '0';
             RegWrite            : out std_logic := '0';
             PCWrite             : out std_logic := '0'
         );
end Control;

architecture Behavioral of Control is
    signal state : state_t := S_OFFLINE;
begin

    state_transitions: process(clk, reset, processor_enable)
    begin

        if processor_enable = '0' then
            state <= S_OFFLINE;
        elsif reset = '1' then
            state <= S_FETCH;
        elsif rising_edge(clk) then
            PCWrite <= '0';
            if state = S_FETCH then
                PCWrite <= '1';
                state <= S_EXECUTE;
            elsif state = S_EXECUTE then
                if instruction(31 downto 26) = b"100011" or instruction(31 downto 26) = b"101011" then
                    state <= S_STALL;
                else
                    state <= S_FETCH;
                end if;
            else
                state <= S_FETCH;
            end if;
        end if;
    end process;

    update: process(instruction, state)
    begin
        if state = S_FETCH then
            RegWrite <= '0';
            MemWrite <= '0';
        elsif state = S_EXECUTE then
            case instruction(31 downto 26) is
                when b"000000" => -- R-Type
                    RegDst <= '1';
                    Branch <= '0';
                    MemToReg <= '0';
                    Jump <= '0';
                    ALUOp <= "00";
                    MemWrite <= '0';
                    ALUSrc <= '0';
                    RegWrite <= '1';
                when b"000100" => -- beq
                    Branch <= '1';
                    Jump <= '0';
                    ALUOp <= "10";
                    MemWrite <= '0';
                    ALUSrc <= '0';
                when b"100011" => -- LW
                    MemToReg <= '1';
                    Branch <= '0';
                    Jump <= '0';
                    ALUOp <= "01";
                    MemWrite <= '0';
                    ALUSrc <= '1';
                    RegWrite <= '1';
                when b"101011" => --SW
                    Branch <= '0';
                    Jump <= '0';
                    ALUOp <= "01";
                    ALUSrc <= '1';
                    MemWrite <= '1';
                    RegWrite <= '0';
                when b"000010" => --J
                    Jump <= '1';
                    MemWrite <= '0';
                when b"001111" => --lui
                    ALUOp <= "11";
                    RegWrite <= '1';
                    ALUSrc <= '1';
                    MemToReg <= '0';
                    RegDst <= '0';
                    MemWrite <= '0';
                when others =>
                    null;
            end case;
        elsif state = S_STALL then
            null;
        end if;
    end process;
end Behavioral;

