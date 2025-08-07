----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.06.2025 17:50:19
-- Design Name: 
-- Module Name: led_register - Behavioral
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

entity led_register is
    port ( clk          : in std_logic;
           data_mem_out : in  std_logic_vector(15 downto 0);
           data_to_led  : in std_logic;
           led          : out std_logic_vector(15 downto 0));
end led_register;

architecture Behavioral of led_register is
signal temp : std_logic_vector(15 downto 0);

begin
    process(clk)
    begin
        if (falling_edge(clk) and data_to_led = '1') then
            temp <= data_mem_out;
        end if;
    end process;
    
    led <= temp;
end Behavioral;
