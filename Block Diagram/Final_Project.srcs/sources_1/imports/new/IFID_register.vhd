----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.07.2025 00:14:18
-- Design Name: 
-- Module Name: IDEX_register - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IFID_register is
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
    Port (
          IF_write        : in std_logic;
          reset             : in std_logic;
          clk               : in std_logic;
          insn_in           : in std_logic_vector(INSTRUCTION_BITS - 1 downto 0);
          insn_out          : out std_logic_vector(INSTRUCTION_BITS - 1 downto 0));
end IFID_register;

architecture Behavioral of IFID_register is
signal temp : std_logic_vector(INSTRUCTION_BITS - 1 downto 0);
begin

process (clk, reset)
    begin
        if (reset = '1') then
            temp <= (others => '0');
        elsif rising_edge(clk) then
--            if IF_write = '0' then
                temp <= insn_in;
--            else
--                temp <= (others => '0');
--            end if;
        end if;
    end process;

    insn_out <= temp;

end Behavioral;
