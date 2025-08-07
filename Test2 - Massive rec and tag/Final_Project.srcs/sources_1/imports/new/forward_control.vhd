----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.07.2025 16:02:54
-- Design Name: 
-- Module Name: forward_control - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity forward_control is
port ( insn           : in  std_logic_vector(15 downto 0);
       MEM_mem_to_reg : in std_logic;
       MEM_reg_write  : in std_logic;
       WB_reg_write   : in std_logic;
       MEM_write_register     : in  std_logic_vector(3 downto 0);
       WB_write_register      : in  std_logic_vector(3 downto 0);
       MEM_FWD_data     : in  std_logic_vector(15 downto 0);
       WB_FWD_data      : in  std_logic_vector(15 downto 0);
       FWD_rs       : out std_logic;
       FWD_rt       : out std_logic;
       FWD_data_rs       : out std_logic_vector(15 downto 0);
       FWD_data_rt       : out std_logic_vector(15 downto 0)
     );
end forward_control;

architecture Behavioral of forward_control is
    signal rs, rt : std_logic_vector(3 downto 0);
begin

    rs <= insn(11 downto 8);
    rt <= insn(7 downto 4);

    process (rs, rt, MEM_write_register, WB_write_register, MEM_reg_write, WB_reg_write)
    begin
        FWD_rs <= '0';
        FWD_rt <= '0';
        -- rs forwarding
        if MEM_reg_write = '1' and MEM_write_register /= "0000" and MEM_mem_to_reg = '0' and MEM_write_register = rs then
            FWD_rs <= '1';
            FWD_data_rs <= MEM_FWD_data;
        elsif WB_reg_write = '1' and WB_write_register /= "0000" and WB_write_register = rs then
            FWD_rs <= '1';
            FWD_data_rs <= WB_FWD_data;
        end if;
    
        -- rt forwarding
        if MEM_reg_write = '1' and MEM_write_register /= "0000" and MEM_mem_to_reg = '0' and MEM_write_register = rt then
            FWD_rt <= '1';
            FWD_data_rt <= MEM_FWD_data;
        elsif WB_reg_write = '1' and WB_write_register /= "0000" and WB_write_register = rt then
            FWD_rt <= '1';
            FWD_data_rt <= WB_FWD_data;
        end if;
    end process;

end Behavioral;