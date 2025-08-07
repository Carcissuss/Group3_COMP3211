----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/08/01 15:12:09
-- Design Name: 
-- Module Name: tally_file - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
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

entity tally_files is
    Port ( tally_rec : in STD_LOGIC_VECTOR(REC_BITS - 1 DOWNTO 0);
           clk : in STD_LOGIC;
           left, right, up, down: in std_logic;
           done : in STD_LOGIC;
           data_out: out STD_LOGIC_VECTOR(TALLY_BITS - 1 downto 0)
           );
end tally_files;

architecture Behavioral of tally_files is

    signal sum : std_logic_vector(TALLY_BITS DOWNTO 0);
    signal data: std_logic_vector(3 downto 0);
    signal tally: std_logic_vector(TALLY_BITS - 1 downto 0);
    signal candidate: std_logic_vector(CAND_BITS - 1 downto 0);
    signal district: std_logic_vector(DIST_BITS - 1 downto 0);
    signal tally_array: tally_file;
    signal display_candidate: integer := 0;
    signal display_district: integer := 0;
begin
     tally <= tally_rec((REC_BITS - 1 - HEAD_BITS) downto 0);
     candidate <= tally_rec(REC_BITS - 1 downto REC_BITS - CAND_BITS);
     district <= tally_rec(REC_BITS - CAND_BITS - 1 downto REC_BITS - CAND_BITS - DIST_BITS);
     tally_file_process: process ( clk,
                           done,
                           tally
                           ) is
    
    variable var_tally_array : tally_file;
    variable var_display_cand: integer := display_candidate;
    variable var_display_dist: integer := display_district;
    variable var_candidate : integer := conv_integer(candidate);
    variable var_district :  integer := conv_integer(district);
    begin
--        if (reset = '1') then
--            -- initial values of the data memory : reset to zero 
--            for i in 0 to CAND_BITS - 1 LOOP
--                 tally_file_mem(i) := (others => '0');
--            END LOOP;
    
        if (rising_edge (clk)) then
            -- memory writes on the falling clock edge
--            save data in the 
            if (done = '1') then
                sum <= ("0"&var_tally_array(var_candidate)(var_district)) + ("0"&tally);
                var_tally_array(var_candidate)(var_district) := sum(TALLY_BITS - 1 downto 0);
             elsif (left = '1' AND var_display_cand < 63) then
                var_display_dist := var_display_dist + 1;
             elsif (right = '1' AND var_display_cand > 0) then
                var_display_dist := var_display_dist - 1;
             elsif (up = '1' AND var_display_cand > 0) then
                var_display_cand := var_display_cand - 1;
             elsif (down = '1' AND var_display_cand < 63) then
                var_display_cand := var_display_cand + 1;
             end if;
        end if;
       
        -- continuous read of the memory location given by var_addr 
        data_out <= var_tally_array(var_display_cand)(var_display_dist);
 
        -- the following are probe signals (for simulation purpose) 
        tally_array <= var_tally_array;

    end process;
end Behavioral;
