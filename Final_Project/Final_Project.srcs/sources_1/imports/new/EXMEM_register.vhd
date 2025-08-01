library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EXMEM_register is
  Port ( 
        reset             : in std_logic;
        clk               : in std_logic;

        alu_result_in     : in std_logic_vector(15 downto 0);
        write_data_in     : in std_logic_vector(15 downto 0);
        alu_result_out    : out std_logic_vector(15 downto 0);
        write_data_out    : out std_logic_vector(15 downto 0);
        write_register_in : in std_logic_vector(3 downto 0);
        write_register_out: out std_logic_vector(3 downto 0);

        -- MEM stage
        mem_write_in      : in std_logic;
        mem_write_out     : out std_logic;

        -- WB stage
        mem_to_reg_in     : in std_logic;
        mem_to_reg_out    : out std_logic;
        data_to_led_in    : in std_logic;
        data_to_led_out   : out std_logic;
        sw_to_reg_in      : in std_logic;
        sw_to_reg_out     : out std_logic;
        reg_write_in      : in std_logic;
        reg_write_out     : out std_logic
  );
end EXMEM_register;

architecture Behavioral of EXMEM_register is
begin

    process (clk, reset)
    begin
        if reset = '1' then
            alu_result_out     <= (others => '0');
            write_data_out     <= (others => '0');
            write_register_out <= (others => '0');

            mem_write_out      <= '0';

            mem_to_reg_out     <= '0';
            data_to_led_out    <= '0';
            sw_to_reg_out      <= '0';
            reg_write_out      <= '0';

        elsif rising_edge(clk) then
            alu_result_out     <= alu_result_in;
            write_data_out     <= write_data_in;
            write_register_out <= write_register_in;

            mem_write_out      <= mem_write_in;

            mem_to_reg_out     <= mem_to_reg_in;
            data_to_led_out    <= data_to_led_in;
            sw_to_reg_out      <= sw_to_reg_in;
            reg_write_out      <= reg_write_in;
        end if;
    end process;

end Behavioral;
