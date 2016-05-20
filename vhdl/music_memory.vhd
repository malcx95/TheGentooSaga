library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity music_memory is
    port (clk : in std_logic;
          address : in unsigned(6 downto 0);
          data : out unsigned(7 downto 0);
		  song_choice : in std_logic_vector(2 downto 0));

end music_memory;

architecture Behavioral of music_memory is

    type song_t is array (0 to 127) of unsigned(7 downto 0);
	
	type songs_t is array (0 to 7) of song_t;

	-- gentoo begins
    signal s1 : song_t := (
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

	-- yakety sax
	signal s2 : song_t := (		
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
	
	-- epic sax guy
	signal s3 : song_t := (
		x"2a", x"2a", x"2a", x"2a", x"00", x"00", x"00", x"00",
		x"2a", x"00", x"2a", x"2a", x"28", x"2a", x"00", x"00",
		x"2a", x"2a", x"2a", x"2a", x"00", x"00", x"00", x"00",
		x"2a", x"00", x"2a", x"2a", x"28", x"2a", x"00", x"00",
		x"2a", x"2a", x"2a", x"2a", x"00", x"00", x"2d", x"2d",
		x"2d", x"2d", x"2a", x"2a", x"00", x"00", x"28", x"28",
		x"28", x"28", x"26", x"26", x"00", x"00", x"23", x"00",
		x"23", x"23", x"25", x"25", x"26", x"26", x"23", x"23",
		x"2a", x"2a", x"2a", x"2a", x"00", x"00", x"00", x"00",
		x"2a", x"00", x"2a", x"2a", x"28", x"2a", x"00", x"00",
		x"2a", x"2a", x"2a", x"2a", x"00", x"00", x"00", x"00",
		x"2a", x"00", x"2a", x"2a", x"28", x"2a", x"00", x"00",
		x"2a", x"2a", x"2a", x"2a", x"00", x"00", x"2d", x"2d",
		x"2d", x"2d", x"2a", x"2a", x"00", x"00", x"28", x"28",
		x"28", x"28", x"26", x"26", x"00", x"00", x"23", x"00",
		x"23", x"23", x"25", x"25", x"26", x"26", x"23", x"23"
		);

	-- something random
	signal s4 : song_t := (
		x"18", x"00", x"19", x"00", x"18", x"00", x"19", x"00",
		x"18", x"00", x"19", x"00", x"18", x"00", x"19", x"00",
		x"2b", x"2a", x"2b", x"2a", x"2b", x"2a", x"2b", x"2a",
		x"2b", x"2a", x"2b", x"2a", x"2b", x"2a", x"2b", x"2a",
		x"18", x"1a", x"1c", x"1d", x"18", x"1a", x"1c", x"1d",
		x"18", x"1a", x"1c", x"1d", x"18", x"1a", x"1c", x"1d",
		x"18", x"00", x"19", x"00", x"18", x"00", x"19", x"00",
		x"18", x"00", x"19", x"00", x"18", x"00", x"19", x"00",
		x"2b", x"2a", x"2b", x"2a", x"2b", x"2a", x"2b", x"2a",
		x"2b", x"2a", x"2b", x"2a", x"2b", x"2a", x"2b", x"2a",
		x"18", x"00", x"19", x"00", x"18", x"00", x"19", x"00",
		x"18", x"00", x"19", x"00", x"18", x"00", x"19", x"00",
		x"2b", x"2a", x"2b", x"2a", x"2b", x"2a", x"2b", x"2a",
		x"2b", x"2a", x"2b", x"2a", x"2b", x"2a", x"2b", x"2a",
		x"2b", x"2a", x"2b", x"2a", x"2b", x"2a", x"2b", x"2a",
		x"2b", x"2a", x"2b", x"2a", x"2b", x"2a", x"2b", x"2a"
		);

	-- mexican hat dance
	signal s5 : song_t := (
		x"24", x"00", x"23", x"00", x"24", x"00", x"21", x"00",
		x"20", x"00", x"21", x"00", x"1d", x"00", x"1c", x"00",
		x"1d", x"00", x"18", x"00", x"00", x"00", x"15", x"00",
		x"16", x"00", x"18", x"00", x"1a", x"00", x"1c", x"00",
		x"1d", x"00", x"1f", x"00", x"21", x"00", x"22", x"00",
		x"1f", x"00", x"00", x"00", x"00", x"00", x"22", x"00",
		x"21", x"00", x"22", x"00", x"1f", x"00", x"1e", x"00",
		x"1f", x"00", x"1c", x"00", x"1b", x"00", x"1c", x"00",
		x"18", x"00", x"00", x"00", x"00", x"00", x"24", x"00",
		x"24", x"00", x"24", x"00", x"26", x"00", x"24", x"00",
		x"22", x"00", x"21", x"00", x"1f", x"00", x"1d", x"00",
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"
	);

	signal s6 : song_t := (others => (others => '0'));
	signal s7 : song_t := (others => (others => '0'));
	signal s8 : song_t := (others => (others => '0'));

	signal songs : songs_t := (s1, s2, s3, s4, s5, s6, s7, s8);

begin

    process(clk)
    begin
        if (rising_edge(clk)) then
			data <= songs(to_integer(unsigned(song_choice)))(to_integer(address));
        end if;
    end process;

end Behavioral;
