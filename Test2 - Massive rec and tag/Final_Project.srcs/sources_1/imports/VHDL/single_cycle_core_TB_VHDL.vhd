
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity Single_cycle_core_TB_VHDL is
end Single_cycle_core_TB_VHDL;


architecture behave of Single_cycle_core_TB_VHDL is
 
  -- 1 GHz = 2 nanoseconds period
  constant c_CLOCK_PERIOD : time := 2 ns; 

 signal r_rectag         : std_logic_vector(RECTAG_BITS - 1 downto 0);
 signal r_CLOCK     : std_logic := '0';
 signal r_reset    : std_logic := '0';
  signal r_done    : std_logic := '0';

-- Component declaration for the Unit Under Test (UUT)
component single_cycle_core is
    port ( reset   : in std_logic;
--           sw     : in std_logic_vector(15 downto 0);
           clk    : in  std_logic;
           rectag : in std_logic_vector(RECTAG_BITS - 1 downto 0);
           done   : out std_logic
--           led    : out std_logic_vector(15 downto 0)
           );
      end component ;
      
      
      begin
       r_rectag <=  "00001111001100101011110000100100010100111011010100001000111100001000010111101101110001001100111110110100011011111101010010010101011001111111101010110111110110010011101110100110001101110001101110110001101000101100001101100011111100000100101011100100000110110100011001101010101001111100101101111011100000001001001101011110000101101000100001111010001110010100101100100010111101100111001100111010001010000011110001111101110111000111010100110001100000011111010110111001010011001000011000001110101001111101100010011001100001101001001100011001100000111100101101111110110010001111101100110011000100010110010100101111001111011001110110100100010000011110000111110100110011111110111100111110010110101000101100100100001100010001110110000011010100010001111011011101100110101101100110101000100111110010010110010001101000100111110001101000111100101101011001000100110101100100000010011101110001100011001011010001011111101101011100100100011101101101111010101100100111000111010110000001111010011010001100000101100011101100100100001101010000011111000110111011010001011000011001110111000011101110010111111011101110001001010101010100111101001010100011001011000000101100101010011010000000010100001010010010010101000100010001010100011100100001001001110001101010111101100111101010101001000100011010101100100100100110010011100010010101110101111000000001111110001";
        -- Instantiate the Unit Under Test (UUT)
        UUT : single_cycle_core
          port map (
            reset     => r_reset,
            clk       => r_CLOCK,
            rectag    => r_rectag,
            done      => r_done            
            );
       
        p_CLK_GEN : process is
        begin
          wait for c_CLOCK_PERIOD/2;
          r_CLOCK <= not r_CLOCK;
        end process p_CLK_GEN; 
         
        process                               -- main testing
        begin
          r_reset <= '0';
       
             wait for 2*c_CLOCK_PERIOD ;
        r_reset <= '1';
           
           wait for 2*c_CLOCK_PERIOD ;
                r_reset <= '0';         
          
          wait for 2 sec;
           
        end process;
         
      end behave;
      
      
      
      
      
      
      