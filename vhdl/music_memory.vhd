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

    type song_t is array (0 to 127) of unsigned(7 downto 0);

    signal gentoo_begins : song_t := (
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


signal yakety : song_t := (		
	x"00", x"00", x"21", x"21", x"21", x"21", x"21", x"21",
	x"24", x"00", x"24", x"00", x"21", x"1f", x"1c", x"1c",
	x"1f", x"1f", x"21", x"1f", x"1f", x"1c", x"1a", x"18",
	x"18", x"00", x"18", x"1c", x"1c", x"1f", x"21", x"1f",
	x"24", x"00", x"00", x"00", x"00", x"1f", x"21", x"23",
	x"24", x"00", x"24", x"00", x"21", x"1f", x"1c", x"1c",
	x"1f", x"1f", x"21", x"1f", x"1f", x"1c", x"1a", x"18",
	x"1f", x"00", x"1f", x"1f", x"23", x"26", x"23", x"21",
	x"1f", x"00", x"00", x"00", x"00", x"1f", x"21", x"23",
	x"24", x"00", x"24", x"00", x"24", x"00", x"24", x"00",
	x"24", x"00", x"24", x"00", x"21", x"1f", x"1c", x"18",
	x"1d", x"00", x"1d", x"00", x"1d", x"00", x"1d", x"00",
	x"21", x"00", x"24", x"26", x"27", x"24", x"00", x"00",
	x"28", x"27", x"28", x"26", x"28", x"2b", x"2b", x"2b",
	x"28", x"2b", x"28", x"00", x"24", x"00", x"1f", x"00",
	x"2d", x"28", x"00", x"24", x"27", x"00", x"24", x"00");

signal imperial : song_t := (
x"93", x"00", x"93", x"00", x"93", x"00", x"90", x"16",
x"d3", x"90", x"16", x"d3", x"c0", x"9a", x"00", x"9a",
x"00", x"9a", x"00", x"9b", x"16", x"d2", x"90", x"16",
x"d3", x"c0", x"df", x"53", x"00", x"13", x"df", x"9e",
x"1d", x"1c", x"1b", x"5c", x"40", x"53", x"d9", x"98",
x"17", x"16", x"15", x"56", x"40", x"50", x"d2", x"90",
x"12", x"d6", x"93", x"16", x"da", x"c0", x"df", x"53",
x"00", x"13", x"df", x"9e", x"1d", x"1c", x"1b", x"5c",
x"40", x"53", x"d9", x"98", x"17", x"16", x"15", x"56",
x"40", x"50", x"d2", x"90", x"16", x"d3", x"90", x"16",
x"d3", x"d3", x"00", x"00", x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"
);

	signal song1 : unsigned(7 downto 0);
	signal song2 : unsigned(7 downto 0);
	signal song3 : unsigned(7 downto 0);
	signal song4 : unsigned(7 downto 0);

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
			song1 <= gentoo_begins(to_integer(address));
			song2 <= yakety(to_integer(address));
			-- TODO add more songs
			song3 <= imperial(to_integer(address));
			song4 <= (others => '0');
        end if;
    end process;

	with song_choice select data <= 
			song1 when "00",
			song2 when "01",
			song3 when "10",
			song4 when others;

end Behavioral;
