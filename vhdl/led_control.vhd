library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_control is 
	port (
		clk : in std_logic;
		rst : in std_logic;
		address : in std_logic_vector(2 downto 0);
		led_data_in : in std_logic;
		led_write : in std_logic;
		led_data_out : out std_logic_vector(7 downto 0)
		 );
end led_control;

architecture behavioral of led_control is
	signal led_reg : std_logic_vector(7 downto 0) := (others => '0');
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				led_reg <= x"F1";
			elsif led_write = '1' then
				led_reg(conv_integer(address)) <= led_data_in;
			end if;
		end if;
	end process;

	led_data_out <= led_reg;

end behavioral;
