library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.conv_std_logic_vector;

package Defs is

    type state_t is (S_FETCH, S_EXECUTE, S_STALL, S_OFFLINE);

    subtype opcode_t is std_logic_vector(5 downto 0);
    subtype reg_t is std_logic_vector(4 downto 0);
    subtype immediate_t is std_logic_vector(15 downto 0);
    subtype target_t is std_logic_vector(18 downto 0);

    type instruction_t is 
        record
            opcode : opcode_t;
            regd : reg_t;
            regs : reg_t;
            regt : reg_t;
            regu : reg_t;
            regv : reg_t;
            immediate : immediate_t;
            target : target_t;
        end record;

    type op_t is (
        nop, jmp, mov, add, lsl, line, bezquad, bezqube, ldr, str, ldrp, strp
    );

    type ALU_source_t is (REG2, INSTR);
    type MemtoReg_t is (FROM_ALU, FROM_MEM); 

    subtype RegWrite_t is boolean;
    subtype MemWrite_t is boolean;
    subtype branch_t is boolean;
    subtype jump_t is boolean;
    subtype PcWrite_t is boolean;

    type control_signals_t is
        record
            RegWrite : RegWrite_t;
            MemtoReg : MemtoReg_t;
            MemWrite : MemWrite_t;
            ALU_source : ALU_source_t;
            branch : branch_t;
            jump : jump_t;
            op : op_t;
            pc_write : PcWrite_t;
        end record;

    type PC_addr_source_t is (Branch_addr, PC_addr);

    function make_instruction(vec : std_logic_vector(31 downto 0) ) return instruction_t;
    function get_op(opcode : opcode_t) return op_t;
    
    -- Used in testbenches to make reporting somewhat less of a joke.
    function vec_string(v: std_logic_vector(31 downto 0)) return string;
    function vec_string_5b(v: std_logic_vector(4 downto 0)) return string;
    function op_string(op: op_t) return string;
    function bool_string(b: boolean) return string;
end package Defs;


package body Defs is

function make_instruction(vec : std_logic_vector(31 downto 0)) return instruction_t is
        variable result : instruction_t;
    begin
        result.opcode := vec(31 downto 26);
        result.regd := vec(25 downto 21);
        result.regs := vec(20 downto 16);
        result.regt := vec(15 downto 11);
        result.regu := vec(10 downto 6);
        result.regv := vec(5 downto 1);
        result.immediate := vec(15 downto 0);
        result.target := vec(18 downto 0);
        return result;
    end function make_instruction;

function get_op(opcode : opcode_t) return op_t is
begin
    case opcode is
        when "000000" =>
            return nop;
        when "000001" =>
            return jmp;
        when "000010" =>
            return mov;
        when "000011" =>
            return add;
        when "000100" =>
            return lsl;
        when "000101" =>
            return line;
        when "000110" =>
            return bezquad;
        when "000111" =>
            return bezqube;
        when "001000" =>
            return str;
        when "001001" =>
            return ldr;
        when "001010" =>
            return strp;
        when "001011" =>
            return ldrp;
        when others =>
            return nop;
    end case;
end get_op;

function vec_string(v: std_logic_vector(31 downto 0)) return string is begin return integer'image(to_integer(unsigned(v))); end vec_string;
function vec_string_5b(v: std_logic_vector(4 downto 0)) return string is begin return integer'image(to_integer(unsigned(v))); end vec_string_5b;
function op_string(op: op_t) return string is begin return op_t'image(op); end op_string;
function bool_string(b: boolean) return string is begin return boolean'image(b); end bool_string;

end Defs;
