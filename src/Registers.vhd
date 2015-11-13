library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registers is
    generic (
        DATA_WIDTH : natural := 32;
        ADDR_WIDTH : natural := 5
    );
    port (
        clk, reset                              : in std_logic;
        read_reg_1, read_reg_2, read_reg_3      : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        RegWrite                                : in std_logic;
        RegDst                                  : in std_logic;
        MemToReg                                : in std_logic;
        ALUResult                               : in std_logic_vector(DATA_WIDTH-1 downto 0);
        read_data_1, read_data_2                : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end Registers;

architecture Behavioral of Registers is
    type RegisterFileType is array(0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal regFile : RegisterFileType;
    signal write_reg_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal write_data : std_logic_vector(DATA_WIDTH-1 downto 0);
begin

    mux: process(clk, RegDst)
    begin
        if RegDst = '0' then
            write_reg_addr <= read_reg_2;
        else
            write_reg_addr <= read_reg_3;
        end if;
    end process;

    data_mux: process(clk, MemToReg)
    begin
        --if MemToReg = '0' then
        --    write_data <= ALUResult;
        --else
        --    write_data <= dmem_data;
        --end if;
    end process;

    process (clk, reset)
    begin
        if reset = '1' then
            regFile <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if RegWrite = '1' then
                regFile(to_integer(unsigned(write_reg_addr))) <= ALUResult;
            end if;
        end if;
    end process;

    read_data_1 <= regFile(to_integer(unsigned(read_reg_1)));
    read_data_2 <= regFile(to_integer(unsigned(read_reg_2)));
end Behavioral;

