---------------------------------------------------------------------------
-- register_file.vhd - Implementation of A Dual-Port, 16 x 16-bit
--                     Collection of Registers.
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


entity register_file is
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           read_register_a : in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
           read_register_b : in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);

           rectag_in           : in  std_logic_vector(RECTAG_BITS - 1 downto 0);
           write_enable_a    : in  std_logic;
           write_enable_b    : in  std_logic;
           record_to_reg     : in std_logic;
           write_register_a  : in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
           write_register_b  : in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
           write_data_a      : in  std_logic_vector(TAG_BITS - 1 downto 0);
           write_data_b      : in  std_logic_vector(TAG_BITS - 1 downto 0);
           read_data_a     : out std_logic_vector(TAG_BITS - 1 downto 0);
           read_data_b     : out std_logic_vector(TAG_BITS - 1 downto 0);

           tag_out          : out  std_logic_vector(TAG_BITS - 1 downto 0);
           rec_out          : out  reg_file);
end register_file;

architecture behavioral of register_file is

-- We leave $0 as 0 to ensure nothing wrong happens when noop.

    signal sig_regfile : reg_file;
    
--    signal sig_tag     : std_logic_vector(TAG_BITS - 1 downto 0);

    function block_partition (
            input : std_logic_vector(RECTAG_BITS - 1 downto 0)
        ) return reg_file is
            variable result : reg_file;
        begin
            -- Getting it to work like the example in the sheet
            for i in 0 to NUM_BLOCKS - 1 loop
                result(NUM_BLOCKS - 1  - i) := (others => '0');
                result(NUM_BLOCKS - 1  - i)(TAG_BITS - 1 downto 0 ) := input(input'high - i*TAG_BITS downto input'high - (i+1)*TAG_BITS + 1);
            end loop;
            return result;
        end function;
    begin



    mem_process : process ( reset,
                            clk,
                            read_register_a,
                            read_register_b,
                            write_enable_a,
                            write_enable_b,
                            write_register_a,
                            write_register_b,
                            write_data_a,
                            write_data_b) is

    variable var_regfile     : reg_file;
    variable var_read_addr_a : integer;
    variable var_read_addr_b : integer;

    variable var_write_addr_1  : integer;
    variable var_write_addr_2  : integer;
    variable var_zero_ext_record: std_logic_vector(RECTAG_BITS - 1 downto 0);
    
    
    begin
        
        var_read_addr_a := conv_integer(read_register_a);
        var_read_addr_b := conv_integer(read_register_b);

        var_write_addr_1  := conv_integer(write_register_a);
        var_write_addr_2  := conv_integer(write_register_b);
        var_zero_ext_record := (others => '0');
        if (reset = '1') then
            -- initial values of the registers - reset to zeroes
            var_regfile := (others => (others => '0'));
        elsif (rising_edge(clk) and record_to_reg = '1') then
            var_zero_ext_record(RECTAG_BITS - 1 downto RECTAG_BITS - REC_BITS) := rectag_in(RECTAG_BITS - 1 downto RECTAG_BITS - REC_BITS);
            var_regfile := block_partition(var_zero_ext_record);
            tag_out <= rectag_in(TAG_BITS - 1 downto 0);
        elsif (rising_edge(clk)) then
            -- register write on the falling clock edge
            if (write_enable_a = '1') then
                var_regfile(var_write_addr_1) := write_data_a;
            end if;
            
            if (write_enable_b = '1') then
                var_regfile(var_write_addr_2) := write_data_b;
            end if;
        end if;

        -- continuous read of the registers at location read_register_a
        -- and read_register_b
        read_data_a <= var_regfile(var_read_addr_a); 
        read_data_b <= var_regfile(var_read_addr_b);        
        rec_out <= var_regfile;
        -- the following are probe signals (for simulation purpose)
        sig_regfile <= var_regfile;
        
    end process; 
end behavioral;
