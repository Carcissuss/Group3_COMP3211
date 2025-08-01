library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.constants.all;

entity register_file is
    generic (
        -- Literal defaults for Block Design parser
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
    port (
        reset           : in  std_logic;
        clk             : in  std_logic;

        read_register_a : in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        read_register_b : in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);

        rectag_in       : in  std_logic_vector(RECTAG_BITS - 1 downto 0);
        write_enable_a  : in  std_logic;
        write_enable_b  : in  std_logic;
        record_to_reg   : in  std_logic;
        write_register_a: in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_register_b: in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
        write_data_a    : in  std_logic_vector(TAG_BITS - 1 downto 0);
        write_data_b    : in  std_logic_vector(TAG_BITS - 1 downto 0);
        read_data_a     : out std_logic_vector(TAG_BITS - 1 downto 0);
        read_data_b     : out std_logic_vector(TAG_BITS - 1 downto 0);
        tag_out         : out std_logic_vector(TAG_BITS - 1 downto 0);

        -- BD-friendly: flat vector instead of reg_file
        rec_out_flat    : out std_logic_vector(NUM_BLOCKS*TAG_BITS - 1 downto 0)
    );
end register_file;

architecture behavioral of register_file is

    -- Internal array version
    signal sig_regfile : reg_file;

    -- Helper: pack reg_file into flat vector
    procedure pack_regfile(
        signal rf : in reg_file;
        signal flat : out std_logic_vector
    ) is
    begin
        for i in 0 to NUM_BLOCKS-1 loop
            flat((i+1)*TAG_BITS - 1 downto i*TAG_BITS) <= rf(i);
        end loop;
    end procedure;

    function block_partition (
        input : std_logic_vector(RECTAG_BITS - 1 downto 0)
    ) return reg_file is
        variable result : reg_file;
    begin
        for i in 0 to NUM_BLOCKS - 1 loop
            result(NUM_BLOCKS - 1 - i) := (others => '0');
            result(NUM_BLOCKS - 1 - i)(TAG_BITS - 1 downto 0) :=
                input(input'high - i*TAG_BITS downto input'high - (i+1)*TAG_BITS + 1);
        end loop;
        return result;
    end function;

begin
    mem_process : process (
        reset, clk,
        read_register_a, read_register_b,
        write_enable_a, write_enable_b,
        write_register_a, write_register_b,
        write_data_a, write_data_b
    ) is
        variable var_regfile     : reg_file;
        variable var_read_addr_a : integer;
        variable var_read_addr_b : integer;
        variable var_write_addr_1: integer;
        variable var_write_addr_2: integer;
        variable var_zero_ext_record: std_logic_vector(RECTAG_BITS - 1 downto 0);
    begin
        var_read_addr_a := conv_integer(read_register_a);
        var_read_addr_b := conv_integer(read_register_b);
        var_write_addr_1 := conv_integer(write_register_a);
        var_write_addr_2 := conv_integer(write_register_b);
        var_zero_ext_record := (others => '0');

        if reset = '1' then
            var_regfile := (others => (others => '0'));

        elsif rising_edge(clk) and record_to_reg = '1' then
            var_zero_ext_record(RECTAG_BITS - 1 downto RECTAG_BITS - REC_BITS) :=
                rectag_in(RECTAG_BITS - 1 downto RECTAG_BITS - REC_BITS);
            var_regfile := block_partition(var_zero_ext_record);
            tag_out <= rectag_in(TAG_BITS - 1 downto 0);

        elsif rising_edge(clk) then
            if write_enable_a = '1' then
                var_regfile(var_write_addr_1) := write_data_a;
            end if;

            if write_enable_b = '1' then
                var_regfile(var_write_addr_2) := write_data_b;
            end if;
        end if;

        -- continuous read
        read_data_a <= var_regfile(var_read_addr_a);
        read_data_b <= var_regfile(var_read_addr_b);
        sig_regfile <= var_regfile;

        -- pack internal reg_file into flat output
        pack_regfile(var_regfile, rec_out_flat);
    end process;
end behavioral;
