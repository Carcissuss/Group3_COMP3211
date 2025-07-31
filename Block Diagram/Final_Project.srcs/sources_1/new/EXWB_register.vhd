library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.constants.all;

entity EXWB_register is
    generic (
        MAX_BLOCK_BITS     : integer := 8;
        MAX_TAG_BITS       : integer := 16;
        TAG_INDEX_BITS     : integer := 4;
        PC_COUNT_BITS      : integer := 6;
        OPCODE_BITS        : integer := 4;
        REC_BITS           : integer := 15;
        TAG_BITS           : integer := 4;
        RECTAG_BITS        : integer := 19;
        NUM_BLOCKS         : integer := 4;
        INSTRUCTION_BITS   : integer := 32;
        REG_BITS           : integer := 8
    );
    Port (
        reset               : in std_logic;
        clk                 : in std_logic;
        IF_write            : in std_logic;

        -- ALU results
        read_alu_a_in       : in std_logic_vector(TAG_BITS - 1 downto 0);
        read_alu_b_in       : in std_logic_vector(TAG_BITS - 1 downto 0);
        read_alu_xor_in     : in std_logic_vector(TAG_BITS - 1 downto 0);
        
        read_alu_a_out      : out std_logic_vector(TAG_BITS - 1 downto 0);
        read_alu_b_out      : out std_logic_vector(TAG_BITS - 1 downto 0);
        read_alu_xor_out    : out std_logic_vector(TAG_BITS - 1 downto 0);
        
        -- Destination registers
        write_register_a_in  : in std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_register_a_out : out std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_register_b_in  : in std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_register_b_out : out std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        
        -- Tag output
        tag_in              : in std_logic_vector(TAG_BITS - 1 downto 0);
        tag_out             : out std_logic_vector(TAG_BITS - 1 downto 0);
        
        -- WB stage controls
        write_enable_a_in   : in std_logic;
        write_enable_a_out  : out std_logic;
        write_enable_b_in   : in std_logic;
        write_enable_b_out  : out std_logic;
        
        -- ALU control
        alu_xor_in          : in std_logic;
        alu_xor_out         : out std_logic
    );
end EXWB_register;

architecture Behavioral of EXWB_register is
begin

    process (clk, reset)
    begin
        if reset = '1' or (rising_edge(clk) and IF_write = '1') then
            -- Clear all pipeline outputs
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
            -- Pass through pipeline data
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
