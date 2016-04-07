library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
		-- memory data
		mdata		: inout std_logic_vector(31 downto 0);
		-- main program counter
		pc			: buffer std_logic_vector(10 downto 0);
		-- program memory in
		pmem_in		: in std_logic_vector(31 downto 0)
		 );
 end cpu;

architecture behavioral of cpu is 
----------------------------------------------------------------------
	-- REGISTERS

	signal ir1, ir2, ir3, i4, a2, b2 : std_logic_vector(31 downto 0);
    signal f_status : std_logic;
----------------------------------------------------------------------
	alias ir1_a	: std_logic_vector(4 downto 0) is ir1(20 downto 16);
	alias ir1_b	: std_logic_vector(4 downto 0) is ir1(15 downto 11);
    alias ir2_a : std_logic_vector(4 downto 0) is ir2(20 downto 16);
    alias ir2_b : std_logic_vector(4 downto 0) is ir2(15 downto 11);
    alias ir2_op : std_logic_vector(5 downto 0) is ir2(31 downto 26);
	alias ir3_d	: std_logic_vector(4 downto 0) is ir3(25 downto 21);
    alias ir3_op : std_logic_vector(5 downto 0) is ir3(31 downto 26);
	alias ir4_d	: std_logic_vector(4 downto 0) is ir4(25 downto 21);
    alias ir4_op : std_logic_vector(5 downto 0) is ir4(31 downto 26);
----------------------------------------------------------------------
	-- REGISTER FILE


	-- Register file type
	type reg_file_t is array(0 to 31) of std_logic_vector(31 downto 0);
	-- The register file
	signal reg_file : reg_file_t := (others => (others => '0'));
	-- Register read, high when register file should read register rA and rB
	signal reg_file_read : std_logic;
	-- Register write, high when register file should write register rD
	signal reg_file_write : std_logic;
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

----------------------------------------------------------------------
    -- DATA FORWARDING SIGNALS
    signal ir4_write_to_register, ir3_write_to_register,
        d3_has_new_a, d3_has_new_b, z4_d4_has_new_a, z4_d4_has_new_b : std_logic;

    signal alu_a, alu_b : std_logic_vector(31 downto 0);

----------------------------------------------------------------------
begin
----------------------------------------------------------------------
	-- Register file
	process(clk)
	begin
		if rising_edge(clk) then
			if reg_file_read = '1' then
				b2 <= reg_file(to_integer(reg_b));
				a2 <= reg_file(to_integer(reg_a));
			end if;
			if reg_file_write = '1' then
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

    -- Multiplexers
    process(clk)
    begin
        if rising_edge(clk) then
            if  stall = '1'  then
                pc <= pc;
                ir1 <= ir1;
            elsif jump_taken = '1' then
                pc <= pc2;
                ir1 <= nop;
            else
                pc <= pc + 4;
                ir1 <= pmem_in;
            end if

            if stall = '1' then
                ir2 <= nop;
            else
                ir2 <= ir1;
            end if;
        end if;
    end process;
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
end behavioral;
