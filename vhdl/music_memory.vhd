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
        x"67", x"5f", x"66", x"58", x"58", x"5f", x"64", x"5f",
        x"6b", x"5f", x"69", x"58", x"58", x"5f", x"67", x"5f",
        x"6b", x"5f", x"69", x"58", x"58", x"5f", x"67", x"5f",
        x"67", x"62", x"69", x"5b", x"5b", x"62", x"6b", x"62",
        x"6b", x"5b", x"69", x"54", x"54", x"5b", x"67", x"5b",
        x"6c", x"64", x"6b", x"5d", x"5d", x"64", x"69", x"64",
        x"67", x"62", x"69", x"5b", x"5b", x"62", x"6b", x"62",
        x"6c", x"64", x"6b", x"5d", x"5d", x"64", x"69", x"64",
        x"5f", x"5a", x"5a", x"53", x"53", x"5a", x"53", x"5a",
        x"6b", x"5b", x"69", x"54", x"54", x"5b", x"67", x"5b",
        x"66", x"5d", x"5d", x"56", x"56", x"5d", x"62", x"5d",
        x"66", x"5d", x"5d", x"56", x"56", x"5d", x"62", x"5d",
        x"5f", x"5a", x"5a", x"53", x"53", x"5a", x"53", x"5a",
        x"67", x"5f", x"66", x"58", x"58", x"5f", x"64", x"5f",
        x"66", x"5a", x"5a", x"53", x"53", x"5a", x"53", x"5a",
        x"66", x"5a", x"5a", x"53", x"53", x"5a", x"53", x"5a");

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
			if song_choice = "00" then
				data <= gentoo_begins(to_integer(address));
			elsif song_choice = "01" then
				data <= example(to_integer(address));
			else
				data <= (others => '0');
        end if;
    end process;

end Behavioral;

