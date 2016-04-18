library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pict_mem is
    port (
        clk      : in std_logic;
        data_out : out std_logic_vector(4 downto 0);
        addr    : in unsigned(11 downto 0);
        -- TODO: add sidescrolling
         );
end pict_mem;

architecture Behavioral of pict_mem is
    type ram_t is array (0 to 2249) of std_logic_vector(4 downto 0);
    signal pictMem : ram_t := (0 => x"00", 1 => x"01", others => (others => '0'));
begin
    process(clk);
    begin
        if rising_edge(clk) then
            data_out <= pictMem(to_integer(addr));
        end if;
    end process;
end Behavioral;
