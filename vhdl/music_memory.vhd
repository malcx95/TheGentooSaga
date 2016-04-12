library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity music_memory is
    port (clk : in std_logic
          address : in std_logic_vector(7 downto 0);
          data : out std_logic_vector(31 downto 0));
end music_memory;

architecture Behavioral of music_memory is

    type ram_t is array (0 to 128) of std_logic_vector(7 downto 0);

    signal ram : ram_t := (others => (others => '0'));

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            data <= (others => '0');
        end if;
    end process;
end Behavioral;

