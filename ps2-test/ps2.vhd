library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2 is
	port(
		clk : in std_logic;
		ps2_clk : in std_logic;
		ps2_data : in std_logic;
		key_addr : in std_logic_vector(1 downto 0);
		key_out : out std_logic;
		key_reg_out : out std_logic_vector(3 downto 0);
		rst : in std_logic
		);
end ps2;

architecture behavioral of ps2 is

	signal ps2_clk_sync : std_logic := '1';
	signal ps2_data_sync : std_logic := '1';
	signal ps2_clk_one_pulse : std_logic := '0';
--	signal one_pulse_q1 : std_logic := '0';
	signal one_pulse_q : std_logic := '0';

	signal ps2_bit_counter : std_logic_vector(3 downto 0) := "0000";
	signal ps2_bit_counter_ce : std_logic := '0';
	signal ps2_bit_counter_clear : std_logic := '0';
	signal bc11 : std_logic := '0';
	
	signal shift_register : std_logic_vector(10 downto 0) := (others => '0');
	signal scancode : std_logic_vector(7 downto 0) := (others => '0');

	type state_type is (IDLE, MAKE, BREAK, E0);
	signal ps2_state : state_type := IDLE;
	signal ps2_make : std_logic := '0';
	signal ps2_break : std_logic := '0';

	signal valid_key : std_logic := '0';
	signal key_index : std_logic_vector(1 downto 0) := "00";
	signal key_reg_load : std_logic := '0';
	signal key_reg : std_logic_vector(3 downto 0) := "0000";

----------------------------------------------------------------------
begin
----------------------------------------------------------------------
	-- The first two flip flops

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then 
				ps2_clk_sync <= '1';
				ps2_data_sync <= '1';
			else
				ps2_clk_sync <= ps2_clk;
				ps2_data_sync <= ps2_data;
			end if;
		end if;
	end process;

----------------------------------------------------------------------
	-- ONEPULSARE

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				one_pulse_q <= '0';
			else
				one_pulse_q <= ps2_clk_sync;
			end if;
		end if;
	end process;
	ps2_clk_one_pulse <= (not one_pulse_q) and ps2_clk_sync;

--	process(clk)
--	begin
--		if rising_edge(clk) then
--			if rst='1' then
--				one_pulse_q1 <= '1';
--				one_pulse_q2 <= '0';
--			else
--				one_pulse_q1 <= ps2_clk_sync;
--				one_pulse_q2 <= not one_pulse_q1;
--			end if;
--		end if;
--	end process;
--	  
--	ps2_clk_one_pulse <= (not one_pulse_q1) and (not one_pulse_q2);

----------------------------------------------------------------------
	-- PS2 bit counter
	process(clk)
	begin
		if rising_edge(clk) then
			if ps2_bit_counter_clear = '1' or rst = '1' then
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
			if rst = '1' then
				shift_register <= (others => '0');
			elsif ps2_clk_one_pulse = '1' then
				shift_register <= ps2_data_sync &
								  shift_register (10 downto 1);
			end if;
		end if;
	end process;

	scancode <= shift_register(8 downto 1);
----------------------------------------------------------------------
	-- State machine

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				ps2_state <= IDLE;
			elsif ps2_state = IDLE then
				if bc11 = '1' and 
				scancode /= x"F0" and 
				scancode /= x"E0" then
					ps2_state <= MAKE;
				elsif bc11 = '1' and scancode = x"E0" then
					ps2_state <= E0;
				elsif bc11 = '1' and scancode = x"F0" then
					ps2_state <= BREAK;
				end if;
			elsif ps2_state = MAKE then
				ps2_state <= IDLE;
			elsif ps2_state = BREAK then
				if bc11 = '1' then
					ps2_state <= IDLE;
				end if;
			else
				if bc11 = '1' and scancode = x"F0" then
					ps2_state <= BREAK;
				elsif bc11 = '1' and scancode /= x"F0" then
					ps2_state <= MAKE;
				end if;
			end if;
		end if;
	end process;

	ps2_make <= '1' when ps2_state = MAKE else '0';
	ps2_break <= '1' when ps2_state = BREAK else '0';
----------------------------------------------------------------------
	-- Key table

	with scancode select key_index <=
		"00" when x"6B", -- left arrow
		"01" when x"74", -- right arrow
		"10" when x"29", -- space
		"11" when others; -- invalid key
	
	valid_key <= '1' when key_index /= "11" else '0';

----------------------------------------------------------------------
	-- Key register
	key_reg_load <= (ps2_make or ps2_break) and valid_key;

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				key_reg <= "0000";
			elsif key_reg_load = '1' then
				key_reg(to_integer(unsigned(key_index))) <= ps2_make;
			end if;
		end if;
	end process;

	key_out <= key_reg(to_integer(unsigned(key_addr)));
	key_reg_out <= key_reg;

----------------------------------------------------------------------
end behavioral;
