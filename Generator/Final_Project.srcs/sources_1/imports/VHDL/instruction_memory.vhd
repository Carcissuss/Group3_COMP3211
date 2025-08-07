---------------------------------------------------------------------------
-- instruction_memory.vhd - Implementation of A Single-Port, 16 x 16-bit
--                          Instruction Memory.
-- 
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
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

entity instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           halt_PC  : in  std_logic;
           record_to_reg: in std_logic;
           addr_in  : in  std_logic_vector(PC_COUNT_BITS - 1 downto 0);
           insn_out : out std_logic_vector(INSTRUCTION_BITS -  1 downto 0));
end instruction_memory;

architecture behavioral of instruction_memory is

type mem_array is array(0 to 63) of std_logic_vector(INSTRUCTION_BITS -  1 downto 0);
signal sig_insn_mem : mem_array;

begin
    mem_process: process ( clk,
                           addr_in ) is
  
    variable var_insn_mem : mem_array;
    variable var_addr     : integer;
  
    begin
        -- 2 cycle delay for now
        if (reset = '1') then
            -- Block partition
            var_insn_mem(0)  := X"10000000";
            -- XOR and compare tags
            var_insn_mem(1)  := X"50000000";
            var_insn_mem(2)  := X"00000000";
            var_insn_mem(3)  := X"00000000";
            var_insn_mem(4)  := X"00000000";
            var_insn_mem(5)  := X"00000000";
            
            var_insn_mem(6)  := X"00000000";
            var_insn_mem(7)  := X"00000000";
            var_insn_mem(8)  := X"00000000";
            var_insn_mem(9)  := X"00000000";
            var_insn_mem(10) := X"00000000";
            var_insn_mem(11) := X"00000000";
            var_insn_mem(12) := X"00000000";
            var_insn_mem(13) := X"00000000";
            var_insn_mem(14) := X"00000000";
            var_insn_mem(15) := X"00000000";
            var_insn_mem(16) := X"00000000";
            var_insn_mem(17) := X"00000000";
            var_insn_mem(18) := X"00000000";
            var_insn_mem(19) := X"00000000";
            var_insn_mem(20) := X"00000000";
            var_insn_mem(21) := X"00000000";
            var_insn_mem(22) := X"00000000";
            var_insn_mem(23) := X"00000000";
            var_insn_mem(24) := X"00000000";
            var_insn_mem(25) := X"00000000";
            var_insn_mem(26) := X"00000000";
            var_insn_mem(27) := X"00000000";
            var_insn_mem(28) := X"00000000";
            var_insn_mem(29) := X"00000000";
            var_insn_mem(30) := X"00000000";
            var_insn_mem(31) := X"00000000";
            var_insn_mem(32) := X"00000000";
            var_insn_mem(33) := X"00000000";
            var_insn_mem(34) := X"00000000";
            var_insn_mem(35) := X"00000000";
            var_insn_mem(36) := X"00000000";
            var_insn_mem(37) := X"00000000";
            var_insn_mem(38) := X"00000000";
            var_insn_mem(39) := X"00000000";
            var_insn_mem(40) := X"00000000";
            var_insn_mem(41) := X"00000000";
            var_insn_mem(42) := X"00000000";
            var_insn_mem(43) := X"00000000";
            var_insn_mem(44) := X"00000000";
            var_insn_mem(45) := X"00000000";
            var_insn_mem(46) := X"00000000";
            var_insn_mem(47) := X"00000000";
            var_insn_mem(48) := X"00000000";
            var_insn_mem(49) := X"00000000";
            var_insn_mem(50) := X"00000000";
            var_insn_mem(51) := X"00000000";
            var_insn_mem(52) := X"00000000";
            var_insn_mem(53) := X"00000000";
            var_insn_mem(54) := X"00000000";
            var_insn_mem(55) := X"00000000";
            var_insn_mem(56) := X"00000000";
            var_insn_mem(57) := X"00000000";
            var_insn_mem(58) := X"00000000";
            var_insn_mem(59) := X"00000000";
            var_insn_mem(60) := X"00000000";
            var_insn_mem(61) := X"00000000";
            var_insn_mem(62) := X"00000000";
            var_insn_mem(63) := X"00000000";
    
        elsif (rising_edge (clk)) then
            -- read instructions on the rising clock edge
            if (halt_PC = '1') then
                insn_out <= (others => '0');
            else 
                var_addr := conv_integer(addr_in);
                insn_out <= var_insn_mem(var_addr);
            end if;
        end if;

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;

    end process;
  
end behavioral;
