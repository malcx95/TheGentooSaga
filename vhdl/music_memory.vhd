library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity music_memory is
    port (clk : in std_logic;
          address : in unsigned(6 downto 0);
          data : out unsigned(7 downto 0);
		  song_choice : in std_logic_vector(1 downto 0));

end music_memory;

architecture Behavioral of music_memory is

    type gentoo_begins_t is array (0 to 127) of unsigned(7 downto 0);

    signal gentoo_begins : gentoo_begins_t := (
        x"67", x"5f", x"58", x"66", x"58", x"5f", x"64", x"5f",
        x"6b", x"5b", x"54", x"69", x"54", x"5b", x"67", x"5b",
        x"66", x"5d", x"56", x"5d", x"56", x"5d", x"62", x"5d",
        x"5f", x"5a", x"53", x"5a", x"53", x"5a", x"53", x"5a",
        x"67", x"5f", x"58", x"66", x"58", x"5f", x"64", x"5f",
        x"6b", x"5b", x"54", x"69", x"54", x"5b", x"67", x"5b",
        x"66", x"5d", x"56", x"5d", x"56", x"5d", x"62", x"5d",
        x"5f", x"5a", x"53", x"5a", x"53", x"5a", x"53", x"5a",
        x"6b", x"5f", x"58", x"69", x"58", x"5f", x"67", x"5f",
        x"6c", x"64", x"5d", x"6b", x"5d", x"64", x"69", x"64",
        x"67", x"62", x"5b", x"69", x"5b", x"62", x"6b", x"62",
        x"66", x"5a", x"53", x"5a", x"53", x"5a", x"53", x"5a",
        x"6b", x"5f", x"58", x"69", x"58", x"5f", x"67", x"5f",
        x"6c", x"64", x"5d", x"6b", x"5d", x"64", x"69", x"64",
        x"67", x"62", x"5b", x"69", x"5b", x"62", x"6b", x"62",
        x"66", x"5a", x"53", x"5a", x"53", x"5a", x"53", x"5a");

	type example_t is array (0 to 127) of unsigned(7 downto 0);

signal example : example_t := (
		x"e1", x"24", x"00", x"24", x"00", x"21", x"1f", x"5c",
		x"1f", x"1f", x"21", x"5f", x"1c", x"1a", x"58", x"00",
		x"18", x"5c", x"1f", x"21", x"1f", x"24", x"c0", x"1f",
		x"21", x"23", x"24", x"00", x"24", x"00", x"21", x"1f",
		x"5c", x"5f", x"21", x"5f", x"1c", x"1a", x"18", x"1f",
		x"00", x"5f", x"23", x"26", x"23", x"21", x"1f", x"c0",
		x"1f", x"21", x"23", x"24", x"00", x"24", x"00", x"24",
		x"00", x"24", x"00", x"24", x"00", x"24", x"00", x"21",
		x"1f", x"1c", x"18", x"1d", x"00", x"1d", x"00", x"1d",
		x"00", x"1d", x"00", x"61", x"24", x"26", x"27", x"24",
		x"40", x"28", x"27", x"28", x"26", x"28", x"ab", x"28",
		x"2b", x"68", x"64", x"5f", x"2d", x"68", x"24", x"66",
		x"64", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00");

	signal song1 : unsigned(7 downto 0);
	signal song2 : unsigned(7 downto 0);

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
			song1 <= gentoo_begins(to_integer(address));
			song2 <= example(to_integer(address));
        end if;
    end process;

	with song_choice select data <= 
			song1 when "00",
			song2 when "01",
			(others => '0') when others;

end Behavioral;

