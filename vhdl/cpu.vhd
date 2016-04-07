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
		pc			: buffer std_logic_vector(31 downto 0);
		-- program memory in
		pmem_in		: in std_logic_vector(31 downto 0)
		 );
 end cpu;

architecture behavioral of cpu is 
----------------------------------------------------------------------
	-- REGISTERS

	-- Register IR1
	signal ir1		: std_logic_vector(31 downto 0);
	-- Register IR2
	signal ir2		: std_logic_vector(31 downto 0);
	-- Register IR3
	signal ir3		: std_logic_vector(31 downto 0);
	-- Register IR4
	signal ir4		: std_logic_vector(31 downto 0);
	-- Register A2
	signal a2		: std_logic_vector(31 downto 0);
	-- Register B2
	signal b2		: std_logic_vector(31 downto 0);
----------------------------------------------------------------------
	-- REGISTER FILE

	-- Register A in intruction (rA)
	alias reg_a		: std_logic_vector(4 downto 0) 
						is ir1(20 downto 16);
	-- Register B in intruction (rB)
	alias reg_b		: std_logic_vector(4 downto 0) 
						is ir1(15 downto 11);
	-- Register D in intruction (rD)
	alias reg_d		: std_logic_vector(4 downto 0)
						is ir4(25 downto 21);
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
	
	-- The D4/Z4 multiplexer TODO not yet implemented
	signal d4_z4_mux : std_logic_vector(31 downto 0);

	-- Multiplexer between program memory and IR1
	signal ir1_mux : std_logic_vector(31 downto 0);
----------------------------------------------------------------------
	-- JUMP and STALL logic TODO not yet implemented
	-- nop instruction
	constant nop : std_logic_vector(31 downto 0) := x"54000000";
	signal jmp_taken : std_logic_vector(1 downto 0);
	signal stall : std_logic;
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
	-- Multiplexer between program memory and IR1
	-- TODO implement
----------------------------------------------------------------------
end behavioral;
