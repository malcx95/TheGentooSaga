library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart is
	port(
		clk,rst,rx : in std_logic;
		pmem_addr : buffer unsigned(10 downto 0);
		data : out unsigned(31 downto 0);
		pmem_write : out std_logic);
end uart;

architecture behavioral of uart is
	signal rx1, rx2, sp, lp, end_of_file, rst_delay : std_logic;
	signal shift_reg : unsigned(9 downto 0);
	signal instruction_reg : unsigned(31 downto 0);
	alias byte : unsigned(7 downto 0) is shift_reg(8 downto 1);

	-- control unit
	signal help_counter : unsigned(9 downto 0) := (others => '0');
	signal help_counter_rst : std_logic := '0';
	signal help_counter_ce : std_logic := '0';
	signal load_half : std_logic := '0';
	signal sp_count : unsigned(3 downto 0) := "0000";
	constant sp_cycle : unsigned(9 downto 0) := "1101100100";
	constant half : unsigned(9 downto 0) := "0110110010";

	-- position counter
	signal pos_counter : unsigned(1 downto 0);
	signal pos_counter_rst : std_logic;
	signal pos_counter_ce : std_logic;
	signal pos_min : std_logic;
	signal pos_min_op : std_logic;
	signal pos_min_q : std_logic;

	constant eof : unsigned(31 downto 0) := (others => '1');

begin

	-- Sync-flipflops
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				rx1 <= '1';
				rx2 <= '1';
			else
				rx1 <= rx;
				rx2 <= rx1;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			rst_delay <= rst;
		end if;
	end process;

	-- Shift register
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				shift_reg <= (others => '0');
			elsif sp = '1' then
				shift_reg <= rx2 & shift_reg(9 downto 1);
			end if;
		end if;
	end process;

	-- ****************************************************************
	-- Control unit
	-- ****************************************************************

	-- main control unit
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				sp_count <= (others => '0');
				sp <= '0';
				lp <= '0';
				help_counter_rst <= '0';
				help_counter_ce <= '0';
				load_half <= '0';
			else
				if rx1 = '0' and rx2 = '1' and help_counter_ce = '0' then
					help_counter_ce <= '1';
					load_half <= '1';
				else
					load_half <= '0';
					if sp_count = "1010" then
						lp <= '1';
						help_counter_ce <= '0';
						sp_count <= (others => '0');
					else
						lp <= '0';
					end if;
				end if;
				if help_counter = sp_cycle then
					sp_count <= sp_count + 1;
					sp <= '1';
					help_counter_rst <= '1';
				else
					sp <= '0';
					help_counter_rst <= '0';
				end if;
			end if;
		end if;
	end process;

	-- help counter
	process(clk)
	begin
		if rising_edge(clk) then
			if help_counter_rst = '1' or rst = '1' then
				help_counter <= (others => '0');
			elsif load_half = '1' then
				help_counter <= half;
			elsif help_counter_ce = '1' then
				help_counter <= help_counter + 1;
			end if;
		end if;
	end process;
	-- ****************************************************************

	-- position counter
	process(clk)
	begin
		if rising_edge(clk) then
			if pos_counter_rst = '1' or rst = '1' then
				pos_counter <= (others => '0');
			elsif pos_counter_ce = '1' then
				pos_counter <= pos_counter + 1;
			end if;
		end if;
	end process;

	pos_min <= '1' when pos_counter = "00" else '0';

	pos_counter_ce <= lp;

	-- one pulser
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				pos_min_q <= '0';
			else
				pos_min_q <= pos_min;
			end if;
		end if;
	end process;

	pos_min_op <= (not pos_min_q) and pos_min and (not rst_delay);

	-- instruction shift reg
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				instruction_reg <= (others => '0');
			elsif lp = '1' then
				instruction_reg <= instruction_reg(23 downto 0) & byte;
			end if;
		end if;
	end process;

	data <= instruction_reg;
	pmem_write <= pos_min_op and (not end_of_file) and (not rst);

	-- address counter
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				pmem_addr <= (others => '0');
			elsif pos_min_op = '1' then
				pmem_addr <= pmem_addr + 1;
			end if;
		end if;
	end process;

	end_of_file <= '1' when instruction_reg = eof else '0';

end behavioral;
