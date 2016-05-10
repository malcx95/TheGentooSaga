library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity cpu is
	port (
		-- main clock
		clk			: in std_logic;
		-- memory address
		maddr		: out unsigned(15 downto 0);
		-- memory read or write; 0: read, 1: write
		mread_write	: out std_logic;
		-- high when memory is to be accessed
		--ce			: out std_logic;
		-- memory data TO THE BLOODY MEMORY
		mdata_to	: out std_logic_vector(31 downto 0);
		-- memory data FROM THE BLOODY MEMORY
		mdata_from	: in std_logic_vector(31 downto 0);
		-- main program counter
		progc       : out unsigned(10 downto 0);
		-- program memory in
		pmem_in		: in std_logic_vector(31 downto 0);
		-- reset
		rst : in std_logic
		 );
 end cpu;

architecture behavioral of cpu is
----------------------------------------------------------------------
    -- CONSTANTS
    constant nop          : std_logic_vector(31 downto 0) := x"54000000";
    constant bf           : std_logic_vector(7 downto 0) := x"04";
    constant jump         : std_logic_vector(7 downto 0) := x"00";
    constant lw           : std_logic_vector(7 downto 0) := x"21";
    constant addi         : std_logic_vector(7 downto 0) := x"27";
    constant add_mul      : std_logic_vector(7 downto 0) := x"38";
    constant movhi        : std_logic_vector(7 downto 0) := x"06";
	constant subi		  : std_logic_vector(7 downto 0) := x"25";
    constant sfeq_sfne    : std_logic_vector(7 downto 0) := x"39";
    constant sfeqi_sfnei  : std_logic_vector(7 downto 0) := x"2f";
    constant sw           : std_logic_vector(7 downto 0) := x"35";
    constant shift_i      : std_logic_vector(7 downto 0) := x"2d";
----------------------------------------------------------------------
	-- REGISTERS

	signal ir1, ir2, ir3, ir4 : std_logic_vector(31 downto 0) := nop;
    signal a2, b2, im2, d4, z3, z4 : std_logic_vector(31 downto 0);
    signal d3 : unsigned(31 downto 0);
	signal pc, pc1, pc2 : unsigned(10 downto 0);
----------------------------------------------------------------------
	-- REGISTER FILE

	-- Register file type
	type reg_file_t is array(0 to 31) of std_logic_vector(31 downto 0);
	-- The register file
	signal reg_file : reg_file_t := (others => (others => '0'));
----------------------------------------------------------------------
	-- MULTIPLEXERS

	-- The D4/Z4 multiplexer
    -- TODO choose a better name
	signal d4_z4_mux : std_logic_vector(31 downto 0);

----------------------------------------------------------------------
    -- JUMP AND STALL SIGNALS

    signal jump_taken, stall, is_load, reads_from_register,
                                        register_conflict : std_logic;

	-- The outputs of the multiplexers
	signal jump_mux, stall_mux : std_logic_vector(31 downto 0);
    signal pc_mux : unsigned(10 downto 0);
    signal jump_taken_and_stall : std_logic_vector(1 downto 0);

----------------------------------------------------------------------
	-- ALU
	signal uses_immediate : std_logic;
	signal alu_i_or_b : unsigned(31 downto 0);
    signal alu_sum : unsigned(31 downto 0);
    signal alu_diff : unsigned(31 downto 0);
    signal alu_prod : unsigned(63 downto 0); -- Is there a better way to do this?
	signal alu_out : unsigned(31 downto 0);
	signal sum_or_product : unsigned(31 downto 0);
    signal left_shift_result : unsigned(31 downto 0);
    signal right_shift_result : unsigned(31 downto 0);
    signal shift_result : unsigned(31 downto 0);

    signal alu_instr_metadata : std_logic_vector(3 downto 0);
----------------------------------------------------------------------
    -- DATA FORWARDING SIGNALS
    signal ir4_write_to_register, ir3_write_to_register,
        d3_has_new_a, d3_has_new_b, z4_d4_has_new_a, z4_d4_has_new_b : std_logic;

    signal alu_a, alu_b : std_logic_vector(31 downto 0);

----------------------------------------------------------------------
	-- STATUS FLAGS
    signal f_status, c_status, o_status : std_logic;
----------------------------------------------------------------------
	alias ir1_a	 : std_logic_vector(4 downto 0) is ir1(20 downto 16);
	alias ir1_b	 : std_logic_vector(4 downto 0) is ir1(15 downto 11);
	signal ir1_i	 : std_logic_vector(15 downto 0);
	--alias ir1_i_sw : std_logic_vector(15 downto 0) is ir1(25 downto 21)
	--												& ir1(10 downto 0);
    signal ir1_op : std_logic_vector(7 downto 0);
    alias ir2_a  : std_logic_vector(4 downto 0) is ir2(20 downto 16);
    alias ir2_b  : std_logic_vector(4 downto 0) is ir2(15 downto 11);
    signal ir2_op : std_logic_vector(7 downto 0);
	alias ir2_d	 : std_logic_vector(4 downto 0) is ir2(25 downto 21);
	alias ir3_d	 : std_logic_vector(4 downto 0) is ir3(25 downto 21);
    signal ir3_op : std_logic_vector(7 downto 0);
	alias ir4_d	 : std_logic_vector(4 downto 0) is ir4(25 downto 21);
    signal ir4_op : std_logic_vector(7 downto 0);
    alias branch_length : std_logic_vector(10 downto 0) is ir1(10 downto 0);
----------------------------------------------------------------------
begin
    ir1_op <= "00" & ir1(31 downto 26);
    ir2_op <= "00" & ir2(31 downto 26);
    ir3_op <= "00" & ir3(31 downto 26);
    ir4_op <= "00" & ir4(31 downto 26);
----------------------------------------------------------------------
	-- Register file
	process(clk, rst)
	begin
        if rst = '1' then
            b2 <= (others => '0');
            a2 <= (others => '0');
            reg_file <= (others => (others => '0'));
		elsif rising_edge(clk) then
            -- Some extra data forwarding for a2 and b2
            if ir4_write_to_register = '1' and ir4_d = ir1_b then
                b2 <= d4_z4_mux;
            else
                b2 <= reg_file(to_integer(unsigned(ir1_b)));
            end if;

            if ir4_write_to_register = '1' and ir4_d = ir1_a then
                a2 <= d4_z4_mux;
            else
                a2 <= reg_file(to_integer(unsigned(ir1_a)));
            end if;

            if ir4_write_to_register = '1' then
                reg_file(to_integer(unsigned(ir4_d))) <= d4_z4_mux;
            end if;
		end if;
	end process;
----------------------------------------------------------------------
--  JUMP AND STALL                                                  --
----------------------------------------------------------------------
    -- Stall
    is_load <= '1' when ir2_op = lw else '0';
    with ir1_op select reads_from_register <=
        '1' when lw,
        '1' when addi,
        '1' when sfeqi_sfnei,
        '1' when sw,
        '1' when add_mul,
        '1' when sfeq_sfne,
		'1' when subi,
		'1' when shift_i,
        '0' when others;
    register_conflict <= '1' when (ir1_b = ir2_d) or
                         (ir2_d = ir1_a) else '0';
    stall <= register_conflict and reads_from_register and is_load;

    -- Jump
    jump_taken <= '1' when ((f_status = '1') and (ir2_op = bf)) or (ir2_op = jump) else '0';

    jump_taken_and_stall <= jump_taken & stall;
	-- jump mux
	with jump_taken_and_stall select jump_mux <=
		pmem_in when "00",
		nop		when "10",
		ir1 when others;

	-- stall mux
	with stall select stall_mux <=
		ir1 when '0',
		nop when others;

	-- pc mux
	with jump_taken_and_stall select pc_mux <=
		pc + 1 when "00",
		pc2 when "10",
		pc when others;

    progc <= pc_mux when rst = '0' else to_unsigned(0, 11);

----------------------------------------------------------------------
	-- IR-registers and pc:s
	process(clk, rst)
	begin
        if rst = '1' then
            ir1 <= nop;
            ir2 <= nop;
            ir3 <= nop;
            ir4 <= nop;
            pc  <= (others => '0');
            pc1 <= (others => '0');
            pc2 <= (others => '0');
            d3  <= (others => '0');
            d4  <= (others => '0');
            z3  <= (others => '0');
		elsif rising_edge(clk) then
            ir1 <= jump_mux;
            ir2 <= stall_mux;
            ir3 <= ir2;
            ir4 <= ir3;
            pc <= pc_mux;
            pc1 <= pc;
            -- Jump ALU
            pc2 <= unsigned(branch_length) + pc1;
            d3 <= alu_out;
            d4 <= std_logic_vector(d3);
            z3 <= alu_b;
		end if;
	end process;

	mdata_to <= z3;
    z4 <= mdata_from;
	maddr <= d3(15 downto 0);
----------------------------------------------------------------------
--  DATA FORWARDING                                                 --
----------------------------------------------------------------------
    with ir3_op select ir3_write_to_register <=
        '1' when movhi,
        '1' when lw,
        '1' when addi,
        '1' when add_mul,
		'1' when subi,
        '1' when shift_i,
        '0' when others;

    with ir4_op select ir4_write_to_register <=
        '1' when movhi,
        '1' when lw,
        '1' when addi,
		'1' when subi,
        '1' when add_mul,
        '1' when shift_i,
        '0' when others;

    d3_has_new_a <= '1' when (ir3_write_to_register = '1') and (ir3_d = ir2_a) else '0';
    d3_has_new_b <= '1' when (ir3_write_to_register = '1') and (ir3_d = ir2_b) else '0';

    z4_d4_has_new_a <= '1' when (ir4_write_to_register = '1') and (ir4_d = ir2_a)
                       else '0';
    z4_d4_has_new_b <= '1' when (ir4_write_to_register = '1') and (ir4_d = ir2_b)
                       else '0';

    alu_a <= a2 when d3_has_new_a = '0' and z4_d4_has_new_a = '0' else
             d4_z4_mux when d3_has_new_a = '0' and z4_d4_has_new_a = '1' else
             std_logic_vector(d3);

    alu_b <= b2 when d3_has_new_b = '0' and z4_d4_has_new_b = '0' else
             d4_z4_mux when d3_has_new_b = '0' and z4_d4_has_new_b = '1' else
             std_logic_vector(d3);

----------------------------------------------------------------------
--  Immediate mode number register                                  --
----------------------------------------------------------------------
	ir1_i <= ir1(15 downto 0) when ir1_op /= sw else ir1(25 downto 21) 
			 & ir1(10 downto 0);
	process(clk, rst)
	begin
        if rst = '1' then
            im2 <= (others => '0');
		elsif rising_edge(clk) then
			if ir1_i(15) = '0' then
				im2 <= x"0000" & ir1_i;
			else
				im2 <= x"FFFF" & ir1_i;
			end if;
		end if;
	end process;
----------------------------------------------------------------------
-- I-mux
	-- determines whether to use register or immediate
	with ir2_op select uses_immediate <=
		'1' when addi,
		'1' when lw,
		'1' when movhi,
		'1' when sfeqi_sfnei,
		'1' when sw,
		'1' when subi,
		'1' when shift_i,
		'0' when others;

	with uses_immediate select alu_i_or_b <=
		unsigned(im2) when '1',
		unsigned(alu_b) when others;
----------------------------------------------------------------------
	-- ALU
	alu_diff <= unsigned(alu_a) - alu_i_or_b;
    alu_sum <= alu_i_or_b + unsigned(alu_a);
    alu_prod <= alu_i_or_b * unsigned(alu_a);

    left_shift_result <= shift_left(unsigned(alu_a), to_integer(alu_i_or_b(4 downto 0)));
    right_shift_result <= shift_right(unsigned(alu_a), to_integer(alu_i_or_b(4 downto 0)));
    with ir2(7 downto 5) select shift_result <=
        left_shift_result when "000",
        right_shift_result when others;

    alu_instr_metadata <= ir2(3 downto 0);
	-- Deals with add and multiply instructions
	with alu_instr_metadata select sum_or_product <=
        alu_sum when x"0",
		alu_diff when x"2",
        alu_prod(31 downto 0) when x"6",
        shift_result when x"8",
        (others => '0') when others;

	with ir2_op select alu_out <=
        sum_or_product(31 downto 0) when add_mul,
        alu_sum when addi,
        alu_sum when lw,
        alu_sum when sw,
		alu_diff when subi,
        shift_result when shift_i,
        alu_i_or_b(15 downto 0) & x"0000" when movhi,
        (others => '0') when others;

	process(clk, rst)
	begin
        if rst = '1' then
            f_status <= '0';
		elsif rising_edge(clk) then
			if (ir2_op = sfeq_sfne) or (ir2_op = sfeqi_sfnei) then
				if (ir2_d = "00000" and alu_i_or_b = unsigned(alu_a)) or
                    (ir2_d = "00001" and alu_i_or_b /= unsigned(alu_a)) or
                    (ir2_d = "00011" and alu_i_or_b < unsigned(alu_a)) then
                    f_status <= '1';
                else
                    f_status <= '0';
                end if;
			end if;
		end if;
	end process;
----------------------------------------------------------------------
	-- CE logic
	--ce <= '1' when (ir3_op = sw) or (ir3_op = lw) else '0';
	mread_write <= '1' when ir3_op = sw else '0';
----------------------------------------------------------------------
	-- D4/Z4
	d4_z4_mux <= z4 when ir4_op = lw else d4;
----------------------------------------------------------------------
end behavioral;
