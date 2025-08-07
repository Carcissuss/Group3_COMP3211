library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


package constants is
    
    -- 256 max number of blocks
    constant MAX_BLOCK_BITS : integer := 8;
    
    -- A 16-bit tag as the maximum size
    constant MAX_TAG_BITS : integer := 16;
    constant TAG_INDEX_BITS : integer := 4;
    
    -- PC counter size
    constant PC_COUNT_BITS : integer := 6;
    constant OPCODE_BITS : integer := 4;
    
    -- User chosen values, number of blocks will be calculated
    constant REC_BITS : integer := 1321;
    constant TAG_BITS : integer := 16;
    constant RECTAG_BITS : integer := REC_BITS + TAG_BITS;
    constant NUM_BLOCKS: integer := ((REC_BITS + TAG_BITS - 1) / TAG_BITS);
    
    constant INSTRUCTION_BITS : integer := OPCODE_BITS + MAX_BLOCK_BITS + MAX_BLOCK_BITS + TAG_INDEX_BITS + TAG_INDEX_BITS + TAG_INDEX_BITS;
    constant REG_BITS : integer := MAX_BLOCK_BITS;
    
    type reg_file is array(0 to NUM_BLOCKS - 1) of std_logic_vector(TAG_BITS - 1 downto 0);
end package;

package body constants is
end package body;
