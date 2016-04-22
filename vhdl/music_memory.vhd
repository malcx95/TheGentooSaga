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
        x"cb", x"c3", x"7c", x"ca", x"7c", x"c3", x"c8", x"c3",
        x"cf", x"7f", x"78", x"cd", x"78", x"7f", x"cb", x"7f",
        x"ca", x"c1", x"7a", x"c1", x"7a", x"c1", x"c6", x"c1",
        x"c3", x"7e", x"77", x"7e", x"77", x"7e", x"77", x"7e",
        x"cb", x"c3", x"7c", x"ca", x"7c", x"c3", x"c8", x"c3",
        x"cf", x"7f", x"78", x"cd", x"78", x"7f", x"cb", x"7f",
        x"ca", x"c1", x"7a", x"c1", x"7a", x"c1", x"c6", x"c1",
        x"c3", x"7e", x"77", x"7e", x"77", x"7e", x"77", x"7e",
        x"cf", x"c3", x"7c", x"cd", x"7c", x"c3", x"cb", x"c3",
        x"d0", x"c8", x"c1", x"cf", x"c1", x"c8", x"cd", x"c8",
        x"cb", x"c6", x"7f", x"cd", x"7f", x"c6", x"cf", x"c6",
        x"ca", x"7e", x"77", x"7e", x"77", x"7e", x"77", x"7e",
        x"cf", x"c3", x"7c", x"cd", x"7c", x"c3", x"cb", x"c3",
        x"d0", x"c8", x"c1", x"cf", x"c1", x"c8", x"cd", x"c8",
        x"cb", x"c6", x"7f", x"cd", x"7f", x"c6", x"cf", x"c6",
        x"ca", x"7e", x"77", x"7e", x"77", x"7e", x"77", x"7e"
        );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            data <= ram(to_integer(address));
        end if;
    end process;
end Behavioral;

