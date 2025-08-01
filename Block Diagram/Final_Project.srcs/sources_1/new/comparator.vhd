----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.07.2025 18:24:49
-- Design Name: 
-- Module Name: comparator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.constants.all;

entity comparator is
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
    Port (reset     : in std_logic;
        clk       : in std_logic;
        orig_tag  : in std_logic_vector(TAG_BITS - 1 downto 0);
        xor_tag   : in std_logic_vector(TAG_BITS - 1 downto 0);
        alu_xor   : in std_logic;
        done      : out std_logic 
    );
end comparator;

architecture Behavioral of comparator is
    
begin
    process(orig_tag, xor_tag, alu_xor, clk, reset) is
    begin 
        if (reset = '1') then
            done <= '0';
        elsif (rising_edge (clk) and (orig_tag = xor_tag) and alu_xor = '1') then
            done <= '1';
        end if;
    end process;

end Behavioral;
