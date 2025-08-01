----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.07.2025 16:02:43
-- Design Name: 
-- Module Name: hazard_control - Behavioral
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

entity hazard_control is
  Port (EX_mem_to_reg       : in std_logic;
        insn                : in  std_logic_vector(15 downto 0);
        EX_write_register   : in  std_logic_vector(3 downto 0);
        halt_PC             : out std_logic;
        IF_write            : out std_logic
        
  );
end hazard_control;

architecture Behavioral of hazard_control is
signal rs, rt : std_logic_vector(3 downto 0);
begin
    rs <= insn(11 downto 8);
    rt <= insn(7 downto 4);

    process (rs, rt, EX_mem_to_reg, EX_write_register)
    begin
        halt_PC <= '0';
        IF_write <= '0';

        if (EX_mem_to_reg = '1' and EX_write_register /= "0000" and (EX_write_register = rs or EX_write_register = rt)) then
            halt_PC <= '1';
            IF_write <= '1';
        end if;
    end process;

end Behavioral;
