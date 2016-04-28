
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

    type memory_type is array (0 to 1) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := (
	x"D5005002",	-- 			SW		R0, R10, LED2
	x"54000000"		-- 			NOP
 );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (address <= 1) then
                data <= program_memory(to_integer(address));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;
