---------------------------------------------------------------------------
-- single_cycle_core.vhd - A Single-Cycle Processor Implementation
--
-- Notes : 
--
-- See single_cycle_core.pdf for the block diagram of this single
-- cycle processor core.
--
-- Instruction Set Architecture (ISA) for the single-cycle-core:
--   Each instruction is 16-bit wide, with four 4-bit fields.
--
--     noop      
--        # no operation or to signal end of program
--        # format:  | opcode = 0 |  0   |  0   |   0    | 
--
--     load  rt, rs, offset     
--        # load data at memory location (rs + offset) into rt
--        # format:  | opcode = 1 |  rs  |  rt  | offset |
--
--     store rt, rs, offset
--        # store data rt into memory location (rs + offset)
--        # format:  | opcode = 3 |  rs  |  rt  | offset |
--
--     add   rd, rs, rt
--        # rd <- rs + rt
--        # format:  | opcode = 8 |  rs  |  rt  |   rd   |
--
--     led   rd, rs, rt
--        # rd <- rs + rt
--        # format:  | opcode = 5 |  rs  |  rt  |   offset   |
--
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.constants.all;

entity single_cycle_core is
--reset  : in  std_logic;
    port ( 
           btnC   : in std_logic;
           sw     : in std_logic_vector(15 downto 0);
           clk    : in  std_logic;
--           rectag : in std_logic_vector(RECTAG_BITS - 1 downto 0);
--           done   : out std_logic
           led    : out std_logic
           );
end single_cycle_core;

architecture structural of single_cycle_core is

component program_counter is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           halt_PC  : in std_logic;
           addr_in  : in  std_logic_vector(PC_COUNT_BITS - 1 downto 0);
           addr_out : out std_logic_vector(PC_COUNT_BITS - 1 downto 0) );
end component;

component instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           halt_PC  : in std_logic;
           record_to_reg: in std_logic;
           addr_in  : in  std_logic_vector(PC_COUNT_BITS - 1 downto 0);
           insn_out : out std_logic_vector(INSTRUCTION_BITS - 1 downto 0) );
end component;

component mux_2to1_4b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(3 downto 0);
           data_b     : in  std_logic_vector(3 downto 0);
           data_out   : out std_logic_vector(3 downto 0) );
end component;

component mux_2to1_16b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(15 downto 0);
           data_b     : in  std_logic_vector(15 downto 0);
           data_out   : out std_logic_vector(15 downto 0) );
end component;

component control_unit is
    port (  opcode          : in  std_logic_vector(OPCODE_BITS - 1 downto 0);
            alu_flp         : out std_logic;
            alu_swp         : out std_logic;
            alu_shf         : out std_logic;
            alu_xor         : out std_logic;
            write_enable_a     : out std_logic;
            write_enable_b     : out std_logic;
            record_to_reg   : out std_logic
    );
end component;

component register_file is
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           read_register_a : in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
           read_register_b : in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);

           rectag_in           : in  std_logic_vector(RECTAG_BITS - 1 downto 0);
           write_enable_a    : in  std_logic;
           write_enable_b    : in  std_logic;
           record_to_reg     : in std_logic;
           write_register_a  : in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
           write_register_b  : in  std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
           write_data_a      : in  std_logic_vector(TAG_BITS - 1 downto 0);
           write_data_b      : in  std_logic_vector(TAG_BITS - 1 downto 0);
           read_data_a     : out std_logic_vector(TAG_BITS - 1 downto 0);
           read_data_b     : out std_logic_vector(TAG_BITS - 1 downto 0);

           tag_out          : out  std_logic_vector(TAG_BITS - 1 downto 0);
           rec_out          : out  reg_file);
end component;

component adder_6b is
    port ( src_a     : in  std_logic_vector(PC_COUNT_BITS - 1 downto 0);
           src_b     : in  std_logic_vector(PC_COUNT_BITS - 1 downto 0);
           halt_PC   : in std_logic;
           sum       : out std_logic_vector(PC_COUNT_BITS - 1 downto 0);
           carry_out : out std_logic );
end component;

--component adder_16b is
--    port ( src_a     : in  std_logic_vector(15 downto 0);
--           src_b     : in  std_logic_vector(15 downto 0);
--           alu_eq    : in std_logic ;
--           sum       : out std_logic_vector(15 downto 0);
--           eq        : out std_logic ;
--           carry_out : out std_logic );
--end component;

--component data_memory is
--    port ( reset        : in  std_logic;
--           clk          : in  std_logic;
--           write_enable : in  std_logic;
--           write_data   : in  std_logic_vector(15 downto 0);
--           addr_in      : in  std_logic_vector(3 downto 0);
--           data_out     : out std_logic_vector(15 downto 0) );
--end component;

--component led_register is
--    port ( clk          : in std_logic;
--           data_mem_out : in  std_logic_vector(15 downto 0);
--           data_to_led  : in std_logic;
--           led          : out std_logic_vector(15 downto 0));
--end component;
component all_alu is
    Port (alu_flp         : in std_logic;
            alu_swp         : in std_logic;
            alu_shf         : in std_logic;
            alu_xor         : in std_logic;
            
            read_data_a     : in std_logic_vector(TAG_BITS - 1 downto 0);
            read_data_b     : in std_logic_vector(TAG_BITS - 1 downto 0);
            read_data_c     : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
            read_data_d     : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
            read_data_e     : in std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
            rec_in       : in reg_file;
            data_a          : out std_logic_vector(TAG_BITS - 1 downto 0);
            data_b          : out std_logic_vector(TAG_BITS - 1 downto 0);
            xor_out       : out std_logic_vector(TAG_BITS - 1 downto 0)
            );
end component;

component IFID_register is
    Port (
          IF_write        : in std_logic;
          reset             : in std_logic;
          clk               : in std_logic;
          insn_in           : in std_logic_vector(INSTRUCTION_BITS - 1 downto 0);
          insn_out          : out std_logic_vector(INSTRUCTION_BITS - 1 downto 0));
end component;

component IDEX_register is
    Port (
        reset             : in std_logic;
        clk               : in std_logic;
        IF_write        : in std_logic;

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
end component;

component EXWB_register is
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
end component;

--component forward_control is
--port ( insn             : in  std_logic_vector(15 downto 0);
--       MEM_mem_to_reg   : in std_logic;
--       MEM_reg_write    : in std_logic;
--       WB_reg_write     : in std_logic;
--       MEM_write_register      : in  std_logic_vector(3 downto 0);
--       WB_write_register       : in  std_logic_vector(3 downto 0);
--       MEM_FWD_data      : in  std_logic_vector(15 downto 0);
--       WB_FWD_data       : in  std_logic_vector(15 downto 0);
--       FWD_rs            : out std_logic;
--       FWD_rt            : out std_logic;
--       FWD_data_rs       : out std_logic_vector(15 downto 0);
--       FWD_data_rt       : out std_logic_vector(15 downto 0)
--   );
--end component;

--component hazard_control is
--Port (  EX_mem_to_reg       : in std_logic;
--        insn                : in  std_logic_vector(15 downto 0);
--        EX_write_register   : in  std_logic_vector(3 downto 0);
----        FWD_register        : out std_logic_vector(3 downto 0);
--        halt_PC             : out std_logic;
--        IF_write            : out std_logic
        
--  );
--end component;

component comparator is
Port (  reset     : in std_logic;
        clk       : in std_logic;
        orig_tag  : in std_logic_vector(TAG_BITS - 1 downto 0);
        xor_tag   : in std_logic_vector(TAG_BITS - 1 downto 0);
        alu_xor   : in std_logic;
        done      : out std_logic 
        );
end component;

-- Instruction signals
signal sig_next_pc              : std_logic_vector(PC_COUNT_BITS - 1 downto 0);
signal sig_curr_pc              : std_logic_vector(PC_COUNT_BITS - 1 downto 0);
signal sig_one_6b               : std_logic_vector(PC_COUNT_BITS - 1 downto 0);
signal sig_pc_carry_out         : std_logic;
signal sig_insn                 : std_logic_vector(INSTRUCTION_BITS - 1 downto 0);

-- Control signals
signal sig_alu_flp         : std_logic;
signal sig_alu_swp         : std_logic;
signal sig_alu_shf         : std_logic;
signal sig_alu_xor         : std_logic;
signal sig_write_enable_a  : std_logic;
signal sig_write_enable_b  : std_logic;
signal sig_record_to_reg   : std_logic;

-- Register signals
signal write_register_a : std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
signal write_register_b : std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);

signal sig_write_data_a           : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_write_data_b           : std_logic_vector(TAG_BITS - 1 downto 0);

signal sig_read_data_a          : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_read_data_b          : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_read_data_c          : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
signal sig_read_data_d          : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
signal sig_read_data_e          : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);

signal sig_tag                  : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_rec                  : reg_file;

-- ALU signals
signal sig_alu_data_a           : std_logic_vector(TAG_BITS - 1  downto 0);
signal sig_alu_data_b           : std_logic_vector(TAG_BITS - 1  downto 0);
signal sig_xor_tag              : std_logic_vector(TAG_BITS - 1  downto 0);

-- IFID stage
signal sig_IFID_write           : std_logic;
signal sig_IFID_insn            : std_logic_vector(INSTRUCTION_BITS - 1 downto 0);

-- IDEX stage
signal sig_IDEX_read_data_a    : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_IDEX_read_data_b    : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_IDEX_read_data_c    : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
signal sig_IDEX_read_data_d    : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
signal sig_IDEX_read_data_e    : std_logic_vector(TAG_INDEX_BITS - 1 downto 0);
signal sig_IDEX_write_register_a : std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
signal sig_IDEX_write_register_b : std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
signal sig_IDEX_insn           : std_logic_vector(INSTRUCTION_BITS - 1 downto 0);
signal sig_IDEX_tag            : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_IDEX_rec            : reg_file;
signal sig_IDEX_alu_flp        : std_logic;
signal sig_IDEX_alu_swp        : std_logic;
signal sig_IDEX_alu_shf        : std_logic;
signal sig_IDEX_alu_xor        : std_logic;
signal sig_IDEX_write_enable_a : std_logic;
signal sig_IDEX_write_enable_b : std_logic;

-- EXWB stage
signal sig_EXWB_alu_data_a       : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_EXWB_alu_data_b       : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_EXWB_alu_data_xor     : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_EXWB_write_register_a : std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
signal sig_EXWB_write_register_b : std_logic_vector(MAX_BLOCK_BITS - 1 downto 0);
signal sig_EXWB_tag              : std_logic_vector(TAG_BITS - 1 downto 0);
signal sig_EXWB_write_enable_a   : std_logic;
signal sig_EXWB_write_enable_b   : std_logic;
signal sig_EXWB_alu_xor          : std_logic;

-- Forwarding Controller
signal sig_FWD_rs             : std_logic;
signal sig_FWD_rt             : std_logic;

signal sig_FWD_data_rs           : std_logic_vector(15 downto 0);
signal sig_FWD_data_rt           : std_logic_vector(15 downto 0);
signal sig_FWD_mux_rs_data      : std_logic_vector(15 downto 0);
signal sig_FWD_mux_rt_data      : std_logic_vector(15 downto 0);

-- Hazard Controller
signal sig_halt_PC           : std_logic;
signal sig_IF_write              : std_logic;

-- Comparator
signal sig_done             : std_logic;

-- Dummy signals for later
signal rectag               : std_logic_vector(15 downto 0);
signal reset                    : std_logic;
begin
    -- reset <= btnC;
    sig_one_6b <= "000001";
    led <= sig_done;
    rectag  <= sw(15 downto 0);
    reset <= btnC;

    pc : program_counter
    port map ( reset    => reset,
               clk      => clk,
               halt_PC => sig_halt_PC,
               addr_in  => sig_next_pc,
               addr_out => sig_curr_pc ); 

    next_pc : adder_6b 
    port map ( src_a     => sig_curr_pc, 
               src_b     => sig_one_6b,
               halt_PC   => sig_halt_PC,
               sum       => sig_next_pc,   
               carry_out => sig_pc_carry_out );
               
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               halt_PC  => sig_halt_PC,
               record_to_reg => sig_record_to_reg,
               addr_in  => sig_curr_pc,
               insn_out => sig_insn );

    ctrl_unit : control_unit 
    port map (
        opcode          => sig_IFID_insn(INSTRUCTION_BITS - 1 downto INSTRUCTION_BITS - OPCODE_BITS),
        alu_flp         => sig_alu_flp,
        alu_swp         => sig_alu_swp,
        alu_shf         => sig_alu_shf,
        alu_xor         => sig_alu_xor,
        write_enable_a  => sig_write_enable_a,
        write_enable_b  => sig_write_enable_b,
        record_to_reg   => sig_record_to_reg
    );

--    mux_reg_dst : mux_2to1_4b 
--    port map ( mux_select => sig_reg_dst,
--               data_a     => sig_IFID_insn(7 downto 4),
--               data_b     => sig_IFID_insn(3 downto 0),
--               data_out   => sig_write_register );

    reg_file : register_file 
    port map (
        reset              => reset,
        clk                => clk,

        read_register_a    => sig_IFID_insn(INSTRUCTION_BITS - OPCODE_BITS - 1 
                                  downto INSTRUCTION_BITS - OPCODE_BITS - MAX_BLOCK_BITS),

        read_register_b    => sig_IFID_insn(INSTRUCTION_BITS - OPCODE_BITS - MAX_BLOCK_BITS - 1 
                                  downto INSTRUCTION_BITS - OPCODE_BITS - 2*MAX_BLOCK_BITS),
        rectag_in          => rectag,
        write_enable_a     => sig_EXWB_write_enable_a,
        write_enable_b     => sig_EXWB_write_enable_b,
        record_to_reg      => sig_record_to_reg,
        write_register_a   => sig_EXWB_write_register_a,
        write_register_b   => sig_EXWB_write_register_b,
        write_data_a       => sig_EXWB_alu_data_a,
        write_data_b       => sig_EXWB_alu_data_b,
        read_data_a        => sig_read_data_a,
        read_data_b        => sig_read_data_b,

        tag_out            => sig_tag,
        rec_out            => sig_rec
    );
    
--    mux_alu_src : mux_2to1_16b 
--    port map ( mux_select => sig_IDEX_alu_src,
--               data_a     => sig_FWD_mux_rt_data,
--               data_b     => sig_IDEX_immediate,
--               data_out   => sig_alu_src_b );

    alu : all_alu
        port map (
            alu_flp     => sig_IDEX_alu_flp,
            alu_swp     => sig_IDEX_alu_swp,
            alu_shf     => sig_IDEX_alu_shf,
            alu_xor     => sig_IDEX_alu_xor,
    
            read_data_a => sig_IDEX_read_data_a,
            read_data_b => sig_IDEX_read_data_b,
            read_data_c => sig_IDEX_read_data_c,
            read_data_d => sig_IDEX_read_data_d,
            read_data_e => sig_IDEX_read_data_e,
            rec_in      => sig_IDEX_rec,
    
            data_a      => sig_alu_data_a,
            data_b      => sig_alu_data_b,
            xor_out     => sig_xor_tag
        );
               
               
    IFID_stage : IFID_register
    port map (IF_write    => sig_IF_write,
              reset       => reset,
              clk         => clk,
              insn_in     => sig_insn,
              insn_out    => sig_IFID_insn
    );
    
    IDEX_stage : IDEX_register
    port map (
        reset                => reset,
        clk                  => clk,
        IF_write             => sig_IF_write,

        read_data_a_in       => sig_read_data_a,
        read_data_b_in       => sig_read_data_b,
        read_data_c_in       => sig_IFID_insn(INSTRUCTION_BITS - OPCODE_BITS - 2*MAX_BLOCK_BITS - 1 
                                  downto INSTRUCTION_BITS - OPCODE_BITS - 2*MAX_BLOCK_BITS - TAG_INDEX_BITS),
                                  
        read_data_d_in       => sig_IFID_insn(INSTRUCTION_BITS - OPCODE_BITS - 2*MAX_BLOCK_BITS - TAG_INDEX_BITS - 1 
                                  downto INSTRUCTION_BITS - OPCODE_BITS - 2*MAX_BLOCK_BITS - 2*TAG_INDEX_BITS),
                                  
        read_data_e_in       => sig_IFID_insn(INSTRUCTION_BITS - OPCODE_BITS - 2*MAX_BLOCK_BITS - 2*TAG_INDEX_BITS - 1 
                                  downto INSTRUCTION_BITS - OPCODE_BITS - 2*MAX_BLOCK_BITS - 3*TAG_INDEX_BITS),

        read_data_a_out      => sig_IDEX_read_data_a,
        read_data_b_out      => sig_IDEX_read_data_b,
        read_data_c_out      => sig_IDEX_read_data_c,
        read_data_d_out      => sig_IDEX_read_data_d,
        read_data_e_out      => sig_IDEX_read_data_e,

        write_register_a_in  => sig_IFID_insn(INSTRUCTION_BITS - OPCODE_BITS - 1 
                                  downto INSTRUCTION_BITS - OPCODE_BITS - MAX_BLOCK_BITS),
        write_register_a_out => sig_IDEX_write_register_a,
        write_register_b_in  => sig_IFID_insn(INSTRUCTION_BITS - OPCODE_BITS - MAX_BLOCK_BITS - 1 
                                  downto INSTRUCTION_BITS - OPCODE_BITS - 2*MAX_BLOCK_BITS),
        write_register_b_out => sig_IDEX_write_register_b,

        insn_in              => sig_insn,
        insn_out             => sig_IDEX_insn,

        tag_in               => sig_tag,
        tag_out              => sig_IDEX_tag,

        rec_in               => sig_rec,
        rec_out              => sig_IDEX_rec,

        -- EX stage
        alu_flp_in           => sig_alu_flp,
        alu_flp_out          => sig_IDEX_alu_flp,
        alu_swp_in           => sig_alu_swp,
        alu_swp_out          => sig_IDEX_alu_swp,
        alu_shf_in           => sig_alu_shf,
        alu_shf_out          => sig_IDEX_alu_shf,

        -- WB stage
        write_enable_a_in    => sig_write_enable_a,
        write_enable_a_out   => sig_IDEX_write_enable_a,
        write_enable_b_in    => sig_write_enable_b,
        write_enable_b_out   => sig_IDEX_write_enable_b,

        -- Both stages
        alu_xor_in           => sig_alu_xor,
        alu_xor_out          => sig_IDEX_alu_xor
    );
    
    EXWB_stage : EXWB_register
    port map (
        reset                 => reset,
        clk                   => clk,
        IF_write              => sig_IF_write,

        read_alu_a_in         => sig_alu_data_a,
        read_alu_b_in         => sig_alu_data_b,
        read_alu_xor_in       => sig_xor_tag,

        read_alu_a_out        => sig_EXWB_alu_data_a,
        read_alu_b_out        => sig_EXWB_alu_data_b,
        read_alu_xor_out      => sig_EXWB_alu_data_xor,

        write_register_a_in   => sig_IDEX_write_register_a,
        write_register_a_out  => sig_EXWB_write_register_a,
        write_register_b_in   => sig_IDEX_write_register_b,
        write_register_b_out  => sig_EXWB_write_register_b,

        tag_in                => sig_IDEX_tag,
        tag_out               => sig_EXWB_tag,

        -- WB stage
        write_enable_a_in     => sig_IDEX_write_enable_a,
        write_enable_a_out    => sig_EXWB_write_enable_a,
        write_enable_b_in     => sig_IDEX_write_enable_b,
        write_enable_b_out    => sig_EXWB_write_enable_b,

        -- Both stages
        alu_xor_in            => sig_IDEX_alu_xor,
        alu_xor_out           => sig_EXWB_alu_xor
    );
    
    compare: comparator
    port map (  reset     => reset,
                clk       => clk,
                orig_tag  => sig_EXWB_tag,
                xor_tag   => sig_EXWB_alu_data_xor,
                alu_xor   => sig_EXWB_alu_xor,
                done      => sig_done
    );
    
--    fwd_unit : forward_control
--    port map( 
--        insn                => sig_IDEX_insn,
--        MEM_mem_to_reg      => sig_EXMEM_mem_to_reg,
--        MEM_reg_write       => sig_EXMEM_reg_write,
--        WB_reg_write        => sig_MEMWB_reg_write,
--        MEM_write_register  => sig_EXMEM_write_register,
--        WB_write_register   => sig_MEMWB_write_register,
--        MEM_FWD_data        => sig_EXMEM_alu_result,
--        WB_FWD_data         => sig_mux_to_reg,
--        FWD_rs              => sig_FWD_rs,
--        FWD_rt              => sig_FWD_rt,
--        FWD_data_rs         => sig_FWD_data_rs,
--        FWD_data_rt         => sig_FWD_data_rt
--    );
    
--    hzrd_unit : hazard_control
--    port map( 
--            EX_mem_to_reg       => sig_IDEX_mem_to_reg,
--            insn                => sig_IFID_insn,
--            EX_write_register   => sig_IDEX_write_register,
--            halt_PC             => sig_halt_PC,
--            IF_write            => sig_IF_write
            
--      );
      
--    rs_mux :  mux_2to1_16b 
--    port map ( mux_select => sig_FWD_rs,
--               data_a     => sig_IDEX_read_data_a,
--               data_b     => sig_FWD_data_rs,
--               data_out   => sig_FWD_mux_rs_data );
               
--    rt_mux :  mux_2to1_16b 
--    port map ( mux_select => sig_FWD_rt,
--               data_a     => sig_IDEX_read_data_b,
--               data_b     => sig_FWD_data_rt,
--               data_out   => sig_FWD_mux_rt_data );

end structural;
