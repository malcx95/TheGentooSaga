library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seg_disp is
	port (
		clk,rst,load : in std_logic;
		disp_select : in std_logic_vector(1 downto 0);
		data_in : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0);
		seg_disp_choose : out std_logic_vector(3 downto 0));
end seg_disp;

architecture Behavioral of seg_disp is

	type seg_t is array (0 to 3) of
		std_logic_vector(7 downto 0);
	
	signal disp : seg_t :=	("10100110",
							"01010101",
							"11111111",
							"00000000");

---------------------------------------------------------------------------
	-- 7-seg multiplexing
	signal clk_counter : std_logic_vector(16 downto 0) := (others => '0');
	signal disp_change : std_logic := '0';
	signal selected_disp : integer := 0;

---------------------------------------------------------------------------
begin
---------------------------------------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				disp <= (others => (others => '0'));
			elsif load = '1' then
				disp(conv_integer(disp_select)) <= data_in;
			end if;
		end if;
	end process;

---------------------------------------------------------------------------
	-- 7-seg multiplexing

	-- clk-counter
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' or disp_change = '1' then
				clk_counter <= (others => '0');
			else
				clk_counter <= clk_counter + 1;
			end if;
		end if;
	end process;

	disp_change <= '1' when clk_counter <= "11000011010100000" else '0';

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' or selected_disp = 3 then
				selected_disp <= 0;
			elsif disp_change = '1' then
				selected_disp <= selected_disp + 1;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				data_out <= (others => '0');
			else
				data_out <= disp(selected_disp);
			end if;
		end if;
	end process;
	
	with selected_disp select seg_disp_choose <=
		"0111" when 0,
		"1011" when 1,
		"1101" when 2,
		"1110" when others;

---------------------------------------------------------------------------

end Behavioral;
