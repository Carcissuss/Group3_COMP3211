----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/08/06 23:22:54
-- Design Name: 
-- Module Name: 7_segment - Behavioral
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

entity 7_segment is
    Port ( data_in : in STD_LOGIC_VECTOR(MAX_TALLY_BITS -1 downto 0);
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR(3 downto 0)
           );
end 7_segment;

architecture Behavioral of 7_segment is
    
begin
        -- create 3 data
    value <= to_integer(data_in); 
    hundred <= std_logic_vector(to_unsigned(value/100, 4));
    ten <= std_logic_vector(to_unsigned((value mod 100) / 10, 4));
    digit <= std_logic_vector(to_unsigned((value mod 10), 4));
    
    led <= STD_LOGIC_VECTOR(sum);
     process(clk) -- 10ns clock 
    begin
        if rising_edge(clk) then
            count <= count+1 ;
            if (count(15 downto 14) = "00") then
                an <= "1110";
                data <= digit;
            elsif (count(15 downto 14) = "01") then 
                an <= "1101";
                data <= ten;
            elsif (count(15 downto 14) = "10") then
                an <= "1011";
                data <= hundred;
            else 
                an <= "0111";
                data <= "0000";
            end if; 
        end if; 
    end process;
    process(an)
        begin
            case data is
                 when "0000" => seg <= "1000000";
                 when "0001" => seg <= "1111001";
                 when "0010" => seg <= "0100100";
                 when "0011" => seg <= "0110000";
                 when "0100" => seg <= "0011001";
                 when "0101" => seg <= "0010010";
                 when "0110" => seg <= "0000010";
                 when "0111" => seg <= "1111000";
                 when "1000" => seg <= "0000000";
                 when "1001" => seg <= "0010000";
                 when others => seg <= "1111111";
              end case;
        end process;

end Behavioral;
