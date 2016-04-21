library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity music_memory is
    port (clk : in std_logic;
          address : in unsigned(6 downto 0);
          data : out unsigned(7 downto 0));
end music_memory;

architecture Behavioral of music_memory is

    type ram_t is array (0 to 127) of unsigned(7 downto 0);

    signal ram : ram_t := (
      x"4b", x"43", x"3c", x"4a", x"3c", x"43", x"48", x"43",
      x"4f", x"3f", x"38", x"4d", x"38", x"3f", x"4b", x"3f",
      x"4a", x"41", x"3a", x"41", x"3a", x"41", x"46", x"41",
      x"43", x"3e", x"37", x"3e", x"37", x"3e", x"37", x"3e",
      x"4b", x"43", x"3c", x"4a", x"3c", x"43", x"48", x"43",
      x"4f", x"3f", x"38", x"4d", x"38", x"3f", x"4b", x"3f",
      x"4a", x"41", x"3a", x"41", x"3a", x"41", x"46", x"41",
      x"43", x"3e", x"37", x"3e", x"37", x"3e", x"37", x"3e",
      x"4f", x"43", x"3c", x"4d", x"3c", x"43", x"4b", x"43",
      x"50", x"48", x"41", x"4f", x"41", x"48", x"4d", x"48",
      x"4b", x"46", x"3f", x"4d", x"3f", x"46", x"4f", x"46",
      x"4a", x"3e", x"37", x"3e", x"37", x"3e", x"37", x"3e",
      x"4f", x"43", x"3c", x"4d", x"3c", x"43", x"4b", x"43",
      x"50", x"48", x"41", x"4f", x"41", x"48", x"4d", x"48",
      x"4b", x"46", x"3f", x"4d", x"3f", x"46", x"4f", x"46",
      x"4a", x"3e", x"37", x"3e", x"37", x"3e", x"37", x"3e");

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            data <= ram(to_integer(address));
        end if;
    end process;
end Behavioral;

