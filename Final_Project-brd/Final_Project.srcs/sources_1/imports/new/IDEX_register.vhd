library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.constants.all;

entity IDEX_register is
    Port (
        reset             : in std_logic;
        clk               : in std_logic;
--        IF_write        : in std_logic;

        read_data_a_in    : in std_logic_vector(TAG_BITS - 1 downto 0);
        read_data_b_in    : in std_logic_vector(TAG_BITS - 1 downto 0);
        read_data_c_in    : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        read_data_d_in    : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        read_data_e_in    : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        
        read_data_a_out   : out std_logic_vector(TAG_BITS - 1 downto 0);
        read_data_b_out   : out std_logic_vector(TAG_BITS - 1 downto 0);
        read_data_c_out   : out std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        read_data_d_out   : out std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        read_data_e_out   : out std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        
        write_register_a_in : in std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_register_a_out : out std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_register_b_in : in std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_register_b_out : out std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        
        insn_in           : in std_logic_vector(INSTRUCTION_BITS - 1 downto 0);
        insn_out          : out std_logic_vector(INSTRUCTION_BITS - 1 downto 0);
        
        tag_in            : in std_logic_vector(TAG_BITS - 1 downto 0);
        tag_out             : out std_logic_vector(TAG_BITS - 1 downto 0);
        
        rec_in            : in reg_file;
        rec_out           : out reg_file;

        -- EX stage
        alu_flp_in         : in std_logic;
        alu_flp_out         : out std_logic;
        alu_swp_in         : in std_logic;
        alu_swp_out         : out std_logic;
        alu_shf_in         : in std_logic;
        alu_shf_out         : out std_logic;

        -- WB stage
        write_enable_a_in     : in std_logic;
        write_enable_a_out    : out std_logic;
        write_enable_b_in     : in std_logic;
        write_enable_b_out    : out std_logic;
        
        -- Both stages
        alu_xor_in         : in std_logic;
        alu_xor_out         : out std_logic
    );
end IDEX_register;

architecture Behavioral of IDEX_register is
begin

    process (clk, reset)
    begin
--        if reset = '1' or (rising_edge(clk) and IF_write = '1') then
          if reset = '1' then
            read_data_a_out    <= (others => '0');
            read_data_b_out    <= (others => '0');
            read_data_c_out    <= (others => '0');
            read_data_d_out    <= (others => '0');
            read_data_e_out    <= (others => '0');
    
            write_register_a_out <= (others => '0');
            write_register_b_out <= (others => '0');
    
            insn_out           <= (others => '0');
            tag_out            <= (others => '0');
            rec_out            <= (others => (others => '0'));  -- assuming `reg_file` supports this syntax
    
            alu_flp_out        <= '0';
            alu_swp_out        <= '0';
            alu_shf_out        <= '0';
            alu_xor_out        <= '0';
    
            write_enable_a_out <= '0';
            write_enable_b_out <= '0';
    
        elsif rising_edge(clk) then
            read_data_a_out    <= read_data_a_in;
            read_data_b_out    <= read_data_b_in;
            read_data_c_out    <= read_data_c_in;
            read_data_d_out    <= read_data_d_in;
            read_data_e_out    <= read_data_e_in;
    
            write_register_a_out <= write_register_a_in;
            write_register_b_out <= write_register_b_in;
    
            insn_out           <= insn_in;
            tag_out            <= tag_in;
            rec_out            <= rec_in;
    
            alu_flp_out        <= alu_flp_in;
            alu_swp_out        <= alu_swp_in;
            alu_shf_out        <= alu_shf_in;
            alu_xor_out        <= alu_xor_in;
    
            write_enable_a_out <= write_enable_a_in;
            write_enable_b_out <= write_enable_b_in;
        end if;
    end process;

end Behavioral;
