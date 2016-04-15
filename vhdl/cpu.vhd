library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
	port (
		-- main clock
		clk			: in std_logic;
		-- memory address
		maddr		: out std_logic_vector(15 downto 0);
		-- memory read or write; 0: read, 1: write
		mread_write	: out std_logic;
		-- high when memory is to be accessed
		ce			: out std_logic;
		-- memory data TO THE BLOODY MEMORY
		mdata_to	: out std_logic_vector(31 downto 0);
		-- memory data FROM THE BLOODY MEMORY
		mdata_from	: in std_logic_vector(31 downto 0);
		-- main program counter
		pc			: buffer std_logic_vector(10 downto 0);
		-- program memory in
		pmem_in		: in std_logic_vector(31 downto 0);
		-- reset
		rst : in std_logic
		 );
 end cpu;

architecture behavioral of cpu is
----------------------------------------------------------------------
	-- REGISTERS

	signal ir1, ir2, ir3, i4, a2, b2, im2, d3, d4, z3, z4 : std_logic_vector(31 downto 0);
	signal pc1, pc2 : std_logic_vector(10 downto 0);
----------------------------------------------------------------------
	alias ir1_a	 : std_logic_vector(4 downto 0) is ir1(20 downto 16);
	alias ir1_b	 : std_logic_vector(4 downto 0) is ir1(15 downto 11);
    alias ir2_a  : std_logic_vector(4 downto 0) is ir2(20 downto 16);
    alias ir2_b  : std_logic_vector(4 downto 0) is ir2(15 downto 11);
    alias ir2_op : std_logic_vector(5 downto 0) is ir2(31 downto 26);
	alias ir2_d	 : std_logic_vector(4 downto 0) is ir2(25 downto 21);
	alias ir3_d	 : std_logic_vector(4 downto 0) is ir3(25 downto 21);
    alias ir3_op : std_logic_vector(5 downto 0) is ir3(31 downto 26);
	alias ir4_d	 : std_logic_vector(4 downto 0) is ir4(25 downto 21);
    alias ir4_op : std_logic_vector(5 downto 0) is ir4(31 downto 26);
	alias branch_length : std_logic_vector(10 downto 0) is jump_mux(10 downto 0);
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
	constant nop : std_logic_vector(31 downto 0) := x"54000000";

    signal jump_taken, stall, is_load, reads_from_register,
                                        register_conflict : std_logic;

	-- The outputs of the multiplexers
	signal jump_mux, stall_mux, pc_mux : std_logic_vector(31 downto 0);
----------------------------------------------------------------------
	-- ALU
	signal uses_immediate : std_logic;
	signal alu_i_or_b : std_logic_vector(31 downto 0);
	signal alu_out : std_logic_vector(31 downto 0);
	signal sum_or_product : std_logic_vector(31 downto 0);
----------------------------------------------------------------------
    -- DATA FORWARDING SIGNALS
    signal ir4_write_to_register, ir3_write_to_register,
        d3_has_new_a, d3_has_new_b, z4_d4_has_new_a, z4_d4_has_new_b : std_logic;

    signal alu_a, alu_b : std_logic_vector(31 downto 0);

----------------------------------------------------------------------
	-- STATUS FLAGS
    signal f_status, c_status, o_status : std_logic;
----------------------------------------------------------------------
begin
----------------------------------------------------------------------
	-- Register file
	process(clk)
	begin
		if rising_edge(clk) then
			b2 <= reg_file(to_integer(ir2_b));
			a2 <= reg_file(to_integer(ir2_a));
			if ir4_write_to_register = '1' then
				reg_file(to_integer(reg_d)) <= d4_z4_mux;
			end if;
		end if;
	end process;
----------------------------------------------------------------------
--  JUMP AND STALL                                                  --
----------------------------------------------------------------------
    -- Stall
    is_load <= '1' when ir2(31 downto 26) = X"21" else '0';
    with "00" & ir1(31 downto 26) select reads_from_register <=
        '1' when x"21",
        '1' when x"27",
        '1' when x"2f",
        '1' when x"35",
        '1' when x"38",
        '1' when x"39",
        '0' when others;
    register_conflict <= '1' when (ir1(15 downto 11) = ir2_op) or
                         (ir2_op = ir1(20 downto 16)) else '0';
    stall <= register_conflict and reads_from_register and is_load;

    -- Jump
    jump_taken <= '1' when ((f_status = '1') and (ir2_op = 4)) or (ir2_op = 0) else '0';

	-- jump mux
	with jump_taken & stall select jump_mux <=
		pmem_in when "00",
		nop		when "10",
		jump_mux when others;

	-- stall mux
	with stall select stall_mux <=
		ir1 when '0',
		nop when others;

	-- pc mux
	with jump_taken & stall select pc_mux <=
		pc + 1 when "00",
		pc2 when "10",
		pc when others;

----------------------------------------------------------------------
	-- IR-registers and pc:s
	process(clk)
	begin
		if rising_edge(clk) then
			ir1 <= jump_mux;
			ir2 <= stall_mux;
			ir3 <= ir2;
			ir4 <= i3;
			pc <= pc_mux;
			pc1 <= pc;
			-- Jump ALU
			pc2 <= branch_length + pc1;
			d3 <= alu_out;
			z3 <= alu_b;
			if ce = '1' and mread_write = '0' then
				z4 <= mdata_from;
			end if;
		end if;
	end process;

	mdata_to <= z3;
	maddr <= d3;
----------------------------------------------------------------------
--  DATA FORWARDING                                                 --
----------------------------------------------------------------------
    function writes_back(signal opcode : std_logic_vector(5 downto 0))
        return std_logic is
    begin
        case "00" & opcode is
            when x"06" => return '1';
            when x"21" => return '1';
            when x"27" => return '1';
            when x"38" => return '1';
            when others => return '0';
        end case;
    end writes_back;

    ir3_write_to_register <= writes_back(ir3_op);
    ir4_write_to_register <= writes_back(ir4_op);

    d3_has_new_a <= '1' when (ir3_write_to_register = '1') and (ir3_d = ir2_a) else '0';
    d3_has_new_b <= '1' when (ir3_write_to_register = '1') and (ir3_d = ir2_b) else '0';

    z4_d4_has_new_a <= '1' when (ir4_write_to_register = '1') and (ir4_d = ir2_a)
                       else '0';
    z4_d4_has_new_b <= '1' when (ir4_write_to_register = '1') and (ir4_d = ir2_b)
                       else '0';

    with d3_has_new_a & z4_d4_has_new_a select alu_a <=
        a2 when "00",
        d4_z4_mux when "01",
        d3 when others;

    with d3_has_new_b & z4_d4_has_new_b select alu_b <=
        b2 when "00",
        d4_z4_mux when "01",
        d3 when others;

----------------------------------------------------------------------
--  Immediate mode number register                                  --
----------------------------------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
			if jump_mux(15) = '0' then
				im2 <= (others => '0') & jump_mux(15 downto 0);
			else
				im2 <= (others => '1') & jump_mux(15 downto 0);
			end if;
		end if;
	end process;
----------------------------------------------------------------------
-- I-mux
	-- determines whether to use register or immediate
	with "00" & ir2_op select uses_immediate <=
		'1' when x"27",
		'1' when x"21",
		'1' when x"06",
		'1' when x"2f",
		'1' when x"35",
		'0' when others;

	with uses_immediate select alu_i_or_b <=
		im2 when '1',
		alu_b when others;
----------------------------------------------------------------------
	-- ALU

	-- Deals with add and multiply instructions
	with '0' & ir2(10 downto 0) select sum_or_product <=
		alu_i_or_b + alu_a when x"000",
		std_logic_vector(unsigned(alu_i_or_b) * unsigned(alu_a)) when x"006",
		(others => '0') when others;

	with "00" & ir2_op select alu_out <=
		sum_or_product when x"38",
		alu_i_or_b + alu_a when x"27",
		alu_i_or_b + alu_a when x"21",
		alu_i_or_b + alu_a when x"35",
		(others => '0') when others;

	process(clk)
	begin
		if rising_edge(clk) then
			if "00" & ir2_op = x"39" or "00" & ir2_op = x"2f" then
				f_status <= '1' when (ir2_d = "00000" and alu_i_or_b = alu_a) or
							(ir2_d = "00001" and alu_i_or_b /= alu_a) else '0';
			end if;
		end if;
	end process;
----------------------------------------------------------------------
	-- CE logic
	ce <= '1' when "00" & ir3_op = x"35" or "00" & ir3_op = x"21" else '0';
	mread_write <= '1' when "00" & ir3_op = x"35" else '0';
----------------------------------------------------------------------
	-- D4/Z4
	d4_z4_mux <= z4 when "00" & ir4_op = x"21" else d4;
----------------------------------------------------------------------
end behavioral;
