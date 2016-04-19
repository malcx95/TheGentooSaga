library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity program_memory is
    port (clk : in std_logic;
          address : in unsigned(10 downto 0);
          data : out std_logic_vector(31 downto 0));
end program_memory;

architecture Behavioral of program_memory is
    constant nop : std_logic_vector(31 downto 0) := x"54000000";

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            data <= nop;
        end if;
    end process;
end Behavioral;

