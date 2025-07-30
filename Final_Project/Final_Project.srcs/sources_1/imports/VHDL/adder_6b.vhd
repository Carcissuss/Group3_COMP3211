---------------------------------------------------------------------------
-- adder_4b.vhd - 4-bit Adder Implementation
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
use IEEE.numeric_std.all;

library work;
use work.constants.all;

entity adder_6b is
    port ( src_a     : in  std_logic_vector(PC_COUNT_BITS - 1 downto 0);
           src_b     : in  std_logic_vector(PC_COUNT_BITS - 1 downto 0);
           halt_PC   : in std_logic;
           sum       : out std_logic_vector(PC_COUNT_BITS - 1 downto 0);
           carry_out : out std_logic );
end adder_6b;

architecture behavioural of adder_6b is

signal sig_result : unsigned (PC_COUNT_BITS downto 0);
signal with_imm : signed(PC_COUNT_BITS - 1 downto 0);
begin

    sig_result <= ('0' & unsigned(src_a)) + ('0' & unsigned(src_b));
    sum        <=  std_logic_vector(sig_result(PC_COUNT_BITS - 1 downto 0));
    carry_out  <= sig_result(PC_COUNT_BITS);

    -- src_a = current PC counter
    
--    a_plus_b <= ('0' & unsigned(src_a)) +
--                ('0' & unsigned(src_b));
--    with_imm <= signed(a_plus_b) +
--                resize(signed(src_c), PC_COUNT_BITS) when eq = '1'
--                else signed(a_plus_b);

--    sum       <= std_logic_vector(with_imm(3 downto 0)) when halt_PC = '0' 
--                                                        else std_logic_vector(unsigned(src_a) - 2);
--    sum       <= std_logic_vector(with_imm(3 downto 0));
--    carry_out <= with_imm(4);
    
    
end behavioural;
