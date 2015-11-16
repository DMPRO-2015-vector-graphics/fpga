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
        alu_result                         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        read_data_1,
        read_data_2,
        read_data_3,
        read_data_4,
        read_data_5                       : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end Registers;

architecture Behavioral of Registers is
    type RegisterFileType is array(0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg_file : RegisterFileType;
begin
    
    update: process (clk, reset)
    begin
        if reset = '1' then
            reg_file <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if reg_write = true then
                if reg_dest = REG1 then
                    reg_file(to_integer(unsigned(reg_1))) <= alu_result;
                elsif reg_dest = REG2 then
                    reg_file(to_integer(unsigned(reg_2))) <= alu_result;
                elsif reg_dest = REG3 then
                    reg_file(to_integer(unsigned(reg_3))) <= alu_result;
                elsif reg_dest = REG4 then
                    reg_file(to_integer(unsigned(reg_4))) <= alu_result;
                elsif reg_dest = REG5 then
                    reg_file(to_integer(unsigned(reg_5))) <= alu_result;
                else
                    reg_file(to_integer(unsigned(reg_1))) <= alu_result;
                end if;
            end if;
        end if;
    end process;

    read_data_1 <= reg_file(to_integer(unsigned(reg_1)));
    read_data_2 <= reg_file(to_integer(unsigned(reg_2)));
    read_data_3 <= reg_file(to_integer(unsigned(reg_3)));
    read_data_4 <= reg_file(to_integer(unsigned(reg_4)));
    read_data_5 <= reg_file(to_integer(unsigned(reg_5)));
end Behavioral;

