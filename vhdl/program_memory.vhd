
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_memory is
    port (clk : in std_logic;
          address : in unsigned(10 downto 0);
          data : out std_logic_vector(31 downto 0));
end program_memory;

architecture Behavioral of program_memory is
    constant nop : std_logic_vector(31 downto 0) := x"54000000";

    type memory_type is array (0 to 3) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := (
	x"18005555",	-- MOVHI	R0, 0B0101010101010101
	x"9C005555",	-- ADDI	R0, R0, 0B0101010101010101
	x"B4000024",	-- SRLI	R0, R0, 4
	x"B4000004"		-- SLLI	R0, R0, 4
 );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (address >= 4 and address <= 7) then
                data <= program_memory(to_integer(address - 4));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;
