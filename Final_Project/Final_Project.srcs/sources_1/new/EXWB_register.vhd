library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.constants.all;

entity EXWB_register is
    Port (
        reset             : in std_logic;
        clk               : in std_logic;
        IF_write        : in std_logic;

        read_alu_a_in    : in std_logic_vector(TAG_BITS - 1 downto 0);
        read_alu_b_in    : in std_logic_vector(TAG_BITS - 1 downto 0);
        read_alu_xor_in    : in std_logic_vector(TAG_BITS - 1 downto 0);
        
        read_alu_a_out    : out std_logic_vector(TAG_BITS - 1 downto 0);
        read_alu_b_out    : out std_logic_vector(TAG_BITS - 1 downto 0);
        read_alu_xor_out    : out std_logic_vector(TAG_BITS - 1 downto 0);
        
        write_register_a_in : in std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_register_a_out : out std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_register_b_in : in std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_register_b_out : out std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        
        tag_in            : in std_logic_vector(TAG_BITS - 1 downto 0);
        tag_out             : out std_logic_vector(TAG_BITS - 1 downto 0);
        
        -- WB stage
        write_enable_a_in     : in std_logic;
        write_enable_a_out    : out std_logic;
        write_enable_b_in     : in std_logic;
        write_enable_b_out    : out std_logic;
        
        -- Both stages
        alu_xor_in         : in std_logic;
        alu_xor_out         : out std_logic
    );
end EXWB_register;

architecture Behavioral of EXWB_register is
begin

    process (clk, reset)
    begin
        if reset = '1' or (rising_edge(clk) and IF_write = '1') then
            read_alu_a_out      <= (others => '0');
            read_alu_b_out      <= (others => '0');
            read_alu_xor_out    <= (others => '0');
    
            write_register_a_out <= (others => '0');
            write_register_b_out <= (others => '0');
    
            tag_out             <= (others => '0');
    
            alu_xor_out         <= '0';
    
            write_enable_a_out  <= '0';
            write_enable_b_out  <= '0';
    
        elsif rising_edge(clk) then
            read_alu_a_out      <= read_alu_a_in;
            read_alu_b_out      <= read_alu_b_in;
            read_alu_xor_out    <= read_alu_xor_in;
    
            write_register_a_out <= write_register_a_in;
            write_register_b_out <= write_register_b_in;
    
            tag_out             <= tag_in;
    
            alu_xor_out         <= alu_xor_in;
    
            write_enable_a_out  <= write_enable_a_in;
            write_enable_b_out  <= write_enable_b_in;
        end if;
    end process;

end Behavioral;