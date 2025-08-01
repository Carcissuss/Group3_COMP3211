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
    Port ( tally : in STD_LOGIC_VECTOR(REC_BITS - 1 DOWNTO 0);
           clk : in STD_LOGIC;
           done : in STD_LOGIC;
--           reset : in STD_LOGIC;
           addr_in : in STD_LOGIC_VECTOR(CAND_BITS - 1 downto 0);
           btnC, btnR, btnL, btnU, btnD : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR(15 DOWNTO 0);
           led : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           seg : out STD_LOGIC_VECTOR(6 DOWNTO 0);
           an : inout STD_LOGIC_VECTOR(3 DOWNTO 0));
end tally_files;

architecture Behavioral of tally_files is
	signal count : std_logic_vector(15 downto 0) := (others => '0');
    signal sum : UNSIGNED(7 DOWNTO 0);
    signal binary : std_LOGIC_VECTOR(7 DOWNTO 0);
    signal saturation : STD_LOGIC;
    signal hundred : std_logic_vector(3 downto 0);
    signal ten: std_logic_vector(3 downto 0);
    signal digit: std_logic_vector(3 downto 0);
    signal data: std_logic_vector(3 downto 0);
    signal value: integer;
    signal load: std_logic;

begin
     tally_file_process: process ( clk,
                           done,
                           tally,
                           addr_in ) is
  
    variable tally_file_mem : tally_file;
    variable var_addr     : integer;
    begin
        var_addr := conv_integer(addr_in);
        
--        if (reset = '1') then
--            -- initial values of the data memory : reset to zero 
--            for i in 0 to CAND_BITS - 1 LOOP
--                 tally_file_mem(i) := (others => '0');
--            END LOOP;

        if (rising_edge (clk) and done = '1') then
            -- memory writes on the falling clock edge
            
            var_data_mem(var_addr) := write_data;
        end if;
       
        -- continuous read of the memory location given by var_addr 
        data_out <= var_data_mem(var_addr);
 
        -- the following are probe signals (for simulation purpose) 
        sig_data_mem <= var_data_mem;

    end process;
    process(clk)
    begin
        if (clk'EVENT and clk = '1') then 
            if btnC = '1' then

            end if;
            if ((("0"&a) + ("0"&b)) >= "100000000" ) then
                sum <= "11111111";
            else
                sum <= a + b;
            end if;
        end if;
    end process;
        -- create 3 data
    value <= to_integer(sum); 
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
