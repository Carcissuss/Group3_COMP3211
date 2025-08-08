----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.07.2025 16:46:57
-- Design Name: 
-- Module Name: all_alu - Behavioral
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
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity all_alu is
  Port (alu_flp         : in std_logic;
        alu_swp         : in std_logic;
        alu_shf         : in std_logic;
        alu_xor         : in std_logic;
        
        read_data_a     : in std_logic_vector(TAG_BITS - 1 downto 0);
        read_data_b     : in std_logic_vector(TAG_BITS - 1 downto 0);
        read_data_c     : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        read_data_d     : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        read_data_e     : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        rec_in       : in reg_file;
        data_a          : out std_logic_vector(TAG_BITS - 1 downto 0);
        data_b          : out std_logic_vector(TAG_BITS - 1 downto 0);
        xor_out       : out std_logic_vector(TAG_BITS - 1 downto 0)
        );
end all_alu;

    
architecture Behavioral of all_alu is

    function xor_all (
        fin_blocks : reg_file
    ) return std_logic_vector is
--        variable var_temp_tag : std_logic_vector(TAG_BITS - 1 downto 0) := (others => '0');
        variable half: integer := NUM_BLOCKS;
        variable blocks: reg_file := fin_blocks;
    begin
        -- Expression to round up the number of blocks
        while half /= 1 loop
            if ((half mod 2 /= 0)) then
                blocks(0) := blocks(0) xor blocks(half - 1);
            end if;
            half := half / 2;
            for i in 0 to (half - 1) loop
                blocks(i) := blocks(i) xor blocks(i + half);
            end loop;
         end loop;
        return blocks(0);
    end function;
    
    function insert_slice (
        bx        : std_logic_vector(TAG_BITS - 1 downto 0);
        px        : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        s         : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        by_slice  : std_logic_vector
    ) return std_logic_vector is
        variable var_bx : std_logic_vector(TAG_BITS - 1 downto 0);
        variable var_px : integer;
        variable var_s  : integer;
    begin
        var_bx := bx;
        var_px := to_integer(unsigned(px));
        var_s  := to_integer(unsigned(s));
    
        for i in 0 to TAG_BITS loop
            exit when i = var_s;
            var_bx((var_px + i) mod TAG_BITS) := by_slice(i);
        end loop;
    
        return var_bx;
    end function;
    
    function get_slice (
        bx : std_logic_vector(TAG_BITS - 1 downto 0);
        px : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        s  : integer
    ) return std_logic_vector is
        variable var_bx : std_logic_vector(TAG_BITS - 1 downto 0);
        variable var_px : integer;
        variable var_s  : integer;
        variable result : std_logic_vector(63 downto 0) := (others => '0');
    begin
        var_bx := bx;
        var_px := to_integer(unsigned(px));
        var_s  := s;
    
        for i in 0 to TAG_BITS loop
            exit when i = var_s ;
            result(i) := var_bx((var_px + i) mod TAG_BITS);
        end loop;
    
        return result;
    end function;
    
    function shift (
        bs : std_logic_vector(TAG_BITS - 1 downto 0);
        r : std_logic_vector(TAG_INDEX_BITS - 1 downto 0)
    ) return std_logic_vector is
        variable var_bs : std_logic_vector(TAG_BITS - 1 downto 0);
        variable var_r : integer;
    begin
        var_bs := bs;
        var_r := TO_INTEGER(unsigned(r));
        
        return std_logic_vector(shift_right(unsigned(var_bs), var_r));
    end function;
    signal shift_size: integer := conv_integer(read_data_e);
begin
    alu_ops : process ( read_data_a,
                        read_data_b,
                        read_data_c,
                        read_data_d,
                        read_data_e,
                        alu_flp,
                        alu_swp,
                        alu_shf,
                        alu_xor) is
     begin
        if (alu_flp = '1') then
            data_a <= not(read_data_a);
        elsif (alu_swp = '1') then
            data_a <= insert_slice(read_data_a, read_data_c, read_data_e, get_slice(read_data_b, read_data_d, shift_size)); 
            data_b <= insert_slice(read_data_b, read_data_d, read_data_e, get_slice(read_data_a, read_data_c, shift_size)); 
        elsif (alu_shf = '1') then
            data_a <= shift(read_data_a, read_data_c);
        elsif (alu_xor = '1') then
                xor_out <= xor_all(rec_in);
        end if;
     end process;

end Behavioral;
