---------------------------------------------------------------------------
-- control_unit.vhd - Control Unit Implementation
--
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
--
--  control signals:
--     reg_dst    : asserted for ADD instructions, so that the register
--                  destination number for the 'write_register' comes from
--                  the rd field (bits 3-0). 
--     reg_write  : asserted for ADD and LOAD instructions, so that the
--                  register on the 'write_register' input is written with
--                  the value on the 'write_data' port.
--     alu_src    : asserted for LOAD and STORE instructions, so that the
--                  second ALU operand is the sign-extended, lower 4 bits
--                  of the instruction.
--     mem_write  : asserted for STORE instructions, so that the data 
--                  memory contents designated by the address input are
--                  replaced by the value on the 'write_data' input.
--     mem_to_reg : asserted for LOAD instructions, so that the value fed
--                  to the register 'write_data' input comes from the
--                  data memory.
--
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.constants.all;


entity control_unit is
    generic (
        -- All default values for block diagram
        MAX_BLOCK_BITS     : integer := 8;
        MAX_TAG_BITS       : integer := 16;
        TAG_INDEX_BITS     : integer := 4;
        PC_COUNT_BITS      : integer := 6;
        OPCODE_BITS        : integer := 4;
        REC_BITS           : integer := 15;
        TAG_BITS           : integer := 4;
        RECTAG_BITS        : integer := 19;
        NUM_BLOCKS         : integer := 4;
        INSTRUCTION_BITS   : integer := 32;
        REG_BITS           : integer := 8
    );
    port (  opcode          : in  std_logic_vector(OPCODE_BITS - 1 downto 0);
            alu_flp         : out std_logic;
            alu_swp         : out std_logic;
            alu_shf         : out std_logic;
            alu_xor         : out std_logic;
            write_enable_a     : out std_logic;
            write_enable_b     : out std_logic;
            record_to_reg   : out std_logic
    );
end control_unit;

architecture behavioural of control_unit is

constant OP_BLK   : std_logic_vector(OPCODE_BITS - 1 downto 0) := "0001";
constant OP_FLP   : std_logic_vector(OPCODE_BITS - 1 downto 0) := "0010";
constant OP_SWP   : std_logic_vector(OPCODE_BITS - 1 downto 0) := "0011";
constant OP_SHF   : std_logic_vector(OPCODE_BITS - 1 downto 0) := "0100";
constant OP_XOR   : std_logic_vector(OPCODE_BITS - 1 downto 0) := "0101";
begin
    
    alu_flp    <= '1' when opcode = OP_FLP else
                  '0';
    alu_swp    <= '1' when opcode = OP_SWP else
                  '0';
                  
    alu_shf    <= '1' when opcode = OP_SHF else
                  '0';
    alu_xor    <= '1' when opcode = OP_XOR else
                  '0';
   
    write_enable_a  <= '1' when (opcode = OP_FLP or opcode = OP_SWP or opcode = OP_SHF) else
                   '0';
                   
    write_enable_b  <= '1' when opcode = OP_SWP else
                  '0';
                  
    record_to_reg <= '1' when opcode = OP_BLK else
                  '0';

end behavioural;
