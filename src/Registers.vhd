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
        clk, reset                        : in std_logic;
        reg_1, reg_2, reg_3, reg_4, reg_5 : in reg_t;
        reg_dest                          : in reg_dest_t;
        reg_write                         : in reg_write_t;
        mem_to_reg                        : in mem_to_reg_t;
        ALUResult                         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        read_data_1,
        read_data_2,
        read_data_3,
        read_data_4,
        read_data_5                       : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end Registers;

architecture Behavioral of Registers is
    type RegisterFileType is array(0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal regFile : RegisterFileType;
begin
    
    update: process (clk, reset)
    begin
        if reset = '1' then
            regFile <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if reg_write = true then
                if reg_dest = REG1 then
                    regFile(to_integer(unsigned(reg_1))) <= ALUResult;
                elsif reg_dest = REG2 then
                    regFile(to_integer(unsigned(reg_2))) <= ALUResult;
                elsif reg_dest = REG3 then
                    regFile(to_integer(unsigned(reg_3))) <= ALUResult;
                elsif reg_dest = REG4 then
                    regFile(to_integer(unsigned(reg_4))) <= ALUResult;
                elsif reg_dest = REG5 then
                    regFile(to_integer(unsigned(reg_5))) <= ALUResult;
                else
                    regFile(to_integer(unsigned(reg_1))) <= ALUResult;
                end if;
            end if;
        end if;
    end process;

    read_data_1 <= regFile(to_integer(unsigned(reg_1)));
    read_data_2 <= regFile(to_integer(unsigned(reg_2)));
    read_data_3 <= regFile(to_integer(unsigned(reg_3)));
    read_data_4 <= regFile(to_integer(unsigned(reg_4)));
    read_data_5 <= regFile(to_integer(unsigned(reg_5)));
end Behavioral;

