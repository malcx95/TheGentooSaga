library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ps2 is
	port(
		clk : in std_logic;
		ps2_clk : in std_logic;
		ps2_data : in std_logic;
		key_addr : in std_logic_vector(1 downto 0);
		key_out : out std_logic_vector(1 downto 0)
		);
end ps2;

architecture behavioral of ps2 is

	signal ps2_clk_sync : std_logic;
	signal ps2_data_sync : std_logic;
	signal ps2_clk_one_pulse : std_logic;
	signal one_pulse_q : std_logic;

	signal ps2_bit_counter : std_logic_vector(3 downto 0);
	signal ps2_bit_counter_ce : std_logic;
	signal ps2_bit_counter_clear : std_logic;
	signal bc11 : std_logic;
	
	signal shift_register : std_logic_vector(10 downto 0);
	signal scancode : std_logic_vector(7 downto 0);

	type state_type is (IDLE, MAKE, BREAK);
	signal ps2_state : state_type := IDLE;
	signal ps2_make : std_logic;
	signal ps2_break : std_logic;

	-- TODO fixa knapptabell och sånt
----------------------------------------------------------------------
begin
----------------------------------------------------------------------
	-- The first two flip flops

	process(clk)
	begin
		if rising_edge(clk) then
			ps2_clk_sync <= ps2_clk;
			ps2_data_sync <= ps2_data;
		end if;
	end process;

----------------------------------------------------------------------
	-- ONEPULSARE

	process(clk)
	begin
		if rising_edge(clk) then
			one_pulse_q <= ps2_clk_sync;
		end if;
	end process;
	ps2_clk_one_pulse <= (not one_pulse_q) and ps2_clk_sync;

----------------------------------------------------------------------
	-- PS2 bit counter
	process(clk)
	begin
		if rising_edge(clk) then
			if ps2_bit_counter_clear = '1' then
				ps2_bit_counter <= (others => '0');
			elsif ps2_bit_counter_ce = '1' then
				ps2_bit_counter <= ps2_bit_counter + 1;
			end if;
		end if;
	end process;

	bc11 <= '1' when ps2_bit_counter = "1011" else '0';
	ps2_bit_counter_clear <= bc11;
	ps2_bit_counter_ce <= ps2_clk_one_pulse;
----------------------------------------------------------------------
	-- Shift register

	process(clk)
	begin
		if rising_edge(clk) then
			if ps2_clk_one_pulse = '1' then
				shift_register <= ps2_data_sync &
								  ps2_data_shift_reg(10 downto 1);
			end if;
		end if;
	end process;

	scancode <= ps2_data_shift_reg(8 downto 1);
----------------------------------------------------------------------
	-- State machine

	process(clk)
	begin
		if rising_edge(clk) then
			if ps2_state = IDLE then
				if bc11 = '1' and (not scancode = x"F0") then
					ps2_state <= MAKE;
				elsif bc11 = '1' and scancode = x"F0" then
					ps2_state <= BREAK;
				end if;
			elsif ps2_state = MAKE then
				ps2_state <= IDLE;
			else
				if bc11 = '1' then
					ps2_state <= IDLE;
				end if;
			end if;
		end if;
	end process;

	ps2_make <= '1' when ps2_state = MAKE else '0';
	ps2_break <= '1' when ps2_state = BREAK else '0';
----------------------------------------------------------------------
end behavioral;
