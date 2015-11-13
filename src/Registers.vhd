library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity Registers is
    generic (
        DATA_WIDTH : natural := 32;
        ADDR_WIDTH : natural := 5
    );
    port (
        clk, reset                                          : in std_logic;
        read_reg_1, read_reg_2, read_reg_3, read_reg_4      : in reg_t;
        reg_dest                                            : in reg_t;
        RegWrite                                            : in RegWrite_t;
        MemToReg                                            : in MemToReg_t;
        ALUResult                                           : in std_logic_vector(DATA_WIDTH-1 downto 0);
        read_data_1, read_data_2, read_data_3, read_data_4  : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end Registers;

architecture Behavioral of Registers is
    type RegisterFileType is array(0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal regFile : RegisterFileType;
begin

    process (clk, reset)
    begin
        if reset = '1' then
            regFile <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if RegWrite = true then
                regFile(to_integer(unsigned(reg_dest))) <= ALUResult;
            end if;
        end if;
    end process;

    read_data_1 <= regFile(to_integer(unsigned(read_reg_1)));
    read_data_2 <= regFile(to_integer(unsigned(read_reg_2)));
    read_data_3 <= regFile(to_integer(unsigned(read_reg_3)));
    read_data_4 <= regFile(to_integer(unsigned(read_reg_4)));
end Behavioral;

