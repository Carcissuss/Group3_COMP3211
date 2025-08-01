library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.constants.all;

entity all_alu is
    generic (
        -- All default values for block diagram (literals only)
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
        alu_flp         : in std_logic;
        alu_swp         : in std_logic;
        alu_shf         : in std_logic;
        alu_xor         : in std_logic;

        read_data_a     : in std_logic_vector(TAG_BITS - 1 downto 0);
        read_data_b     : in std_logic_vector(TAG_BITS - 1 downto 0);
        read_data_c     : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        read_data_d     : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        read_data_e     : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);

        -- BD-friendly: rec_in as flat vector
        rec_in_flat     : in std_logic_vector(NUM_BLOCKS*TAG_BITS - 1 downto 0);

        data_a          : out std_logic_vector(TAG_BITS - 1 downto 0);
        data_b          : out std_logic_vector(TAG_BITS - 1 downto 0);
        xor_out         : out std_logic_vector(TAG_BITS - 1 downto 0)
    );
end all_alu;

architecture Behavioral of all_alu is

    -- Internal array version of rec_in
    signal rec_in : reg_file;

    -- Unpack helper
    procedure unpack_regfile(
        signal flat : in std_logic_vector;
        signal rf   : out reg_file
    ) is
    begin
        for i in 0 to NUM_BLOCKS-1 loop
            rf(i) <= flat((i+1)*TAG_BITS - 1 downto i*TAG_BITS);
        end loop;
    end procedure;

    -- XOR across all blocks
    function xor_all (
        fin_blocks : reg_file
    ) return std_logic_vector is
        variable var_temp_tag : std_logic_vector(TAG_BITS - 1 downto 0) := (others => '0');
    begin
        for i in 0 to NUM_BLOCKS - 1 loop
            var_temp_tag := var_temp_tag xor fin_blocks(i);
        end loop;
        return var_temp_tag;
    end function;

    function insert_slice (
        bx        : std_logic_vector(TAG_BITS - 1 downto 0);
        px        : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        s         : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        by_slice  : std_logic_vector
    ) return std_logic_vector is
        variable var_bx : std_logic_vector(TAG_BITS - 1 downto 0);
        variable var_px : integer;
        variable var_s  : integer;
    begin
        var_bx := bx;
        var_px := to_integer(unsigned(px));
        var_s  := to_integer(unsigned(s));
    
        for i in 0 to var_s - 1 loop
            var_bx((var_px + i) mod TAG_BITS) := by_slice(i);
        end loop;
    
        return var_bx;
    end function;

    function get_slice (
        bx : std_logic_vector(TAG_BITS - 1 downto 0);
        px : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
        s  : std_logic_vector(TAG_INDEX_BITS - 1 downto 0)
    ) return std_logic_vector is
        variable var_bx : std_logic_vector(TAG_BITS - 1 downto 0);
        variable var_px : integer;
        variable var_s  : integer;
        variable result : std_logic_vector(to_integer(unsigned(s)) - 1 downto 0);
    begin
        var_bx := bx;
        var_px := to_integer(unsigned(px));
        var_s  := to_integer(unsigned(s));
    
        for i in 0 to var_s - 1 loop
            result(i) := var_bx((var_px + i) mod TAG_BITS);
        end loop;
    
        return result;
    end function;

    function shift (
        bs : std_logic_vector(TAG_BITS - 1 downto 0);
        r  : std_logic_vector(TAG_INDEX_BITS - 1 downto 0)
    ) return std_logic_vector is
        variable var_bs : std_logic_vector(TAG_BITS - 1 downto 0);
        variable var_r  : integer;
    begin
        var_bs := bs;
        var_r := TO_INTEGER(unsigned(r));
        return std_logic_vector(shift_right(unsigned(var_bs), var_r));
    end function;

begin
    -- Always unpack at the start of a cycle
    unpack_regfile(rec_in_flat, rec_in);

    alu_ops : process (read_data_a, read_data_b, read_data_c, read_data_d, read_data_e,
                       alu_flp, alu_swp, alu_shf, alu_xor, rec_in) is
    begin
        -- Defaults
        data_a <= (others => '0');
        data_b <= (others => '0');
        xor_out <= (others => '0');

        if (alu_flp = '1') then
            data_a <= not(read_data_a);
        elsif (alu_swp = '1') then
            data_a <= insert_slice(read_data_a, read_data_c, read_data_e,
                                   get_slice(read_data_b, read_data_d, read_data_e));
            data_b <= insert_slice(read_data_b, read_data_d, read_data_e,
                                   get_slice(read_data_a, read_data_c, read_data_e));
        elsif (alu_shf = '1') then
            data_a <= shift(read_data_a, read_data_c);
        elsif (alu_xor = '1') then
            xor_out <= xor_all(rec_in);
        end if;
    end process;

end Behavioral;
