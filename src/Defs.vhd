library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package Defs is
subtype instruction_t is std_logic_vector(31 downto 0);

    type state_t is (S_FETCH, S_EXECUTE, S_STALL, S_OFFLINE);

    subtype opcode_t is std_logic_vector(5 downto 0);
    subtype reg_t is std_logic_vector(4 downto 0);
    subtype shift_t is std_logic_vector(4 downto 0);
    subtype func_t is std_logic_vector(5 downto 0);
    subtype immediate_t is std_logic_vector(15 downto 0);
    subtype target_t is std_logic_vector(25 downto 0);

    type instruction is 
        record
            opcode : opcode_t;
            regs : reg_t;
            regt : reg_t;
            regd : reg_t;
            shift : shift_t;
            func_code : func_t;
            immediate : immediate_t;
            target : target_t;
        end record;

    type ALU_op_t is (
    add, sub, addu, subu, mult, div, multu, divu, mfhi, mflo, 
        iand, ior, inor, ixor, isll, isrl, isra, islt, isltu, jr, jalr
    );

    type op_t is (
        j, jal, beq, bne, sw, lw, rtype, error
    );

    -- Enumerators for control signals
    -- e[name] denotes enumerated name, because strings are not allowed and types share namespac
    -- with subtypes (WHAT THE FUCK!=?==)
    type instruction_format_t is (R_TYPE, I_TYPE, J_TYPE);
    type decoder_select_t is (OPERATION, FUNCT);


    type ALU_source_t is (REG2, INSTR);
    type RegDst_t is (REGT, REGD);
    type MemtoReg_t is (FROM_ALU, FROM_MEM); 

    subtype RegWrite_t is boolean;
    subtype MemWrite_t is boolean;
    subtype stall_t is boolean;
    subtype branch_t is boolean;
    subtype jump_t is boolean;

    type control_signals_t is
        record
            RegWrite : RegWrite_t;
            RegDst : RegDst_t;
            MemtoReg : MemtoReg_t;
            MemWrite : MemWrite_t;
            ALU_source : ALU_source_t;
            stall : stall_t;
            ALU_op : ALU_op_t;
            branch : branch_t;
            jump : jump_t;

        end record;

    
    -- not all used. 


    function get_format ( op : opcode_t) return instruction_format_t;
    function get_function ( func : func_t) return ALU_op_t;
    function get_op ( op : opcode_t) return op_t;
  
end package Defs;


package body Defs is

function get_format ( op : opcode_t) return instruction_format_t is
begin
    if op = "000000" then
        return R_TYPE;
    elsif op(5 downto 1) = "00001" or op(5 downto 2) = "0100" then
        return J_TYPE;
    else
        return I_TYPE;
    end if;
end get_format;

function get_function ( func : func_t) return ALU_op_t is
begin
    case func is
        when "100000" => return add;
        when "100001" => return addu;
        when "100100" => return iand;
        when "011010" => return div;
        when "011011" => return divu;
        when "001000" => return jr;
        when "001001" => return jalr;
        when "010000" => return mfhi;
        when "010010" => return mflo;
        when "011000" => return mult;
        when "011001" => return multu;
        when "100111" => return inor;
        when "100110" => return ixor;
        when "100101" => return ior;
        when "101010" => return islt;
        when "101011" => return isltu;
        when "000000" => return isll;
        when "000010" => return isrl;
        when "000011" => return isra;
        when "100010" => return sub;
        when "100011" => return subu;
        when others => return add;
    end case;
end get_function;
	
function get_op ( op : opcode_t) return op_t is
begin
    case op is
        when "000010" => return j;
        when "000011" => return jal;
        when "000100" => return beq;
        when "000101" => return bne;
        when "100011" => return lw;
        when "101011" => return sw;
        when "000000" => return rtype;
        when others => return error;
    end case;
end get_op;

end Defs;
