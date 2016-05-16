
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_memory is
    port (clk : in std_logic;
          address : in unsigned(10 downto 0);
          data : out std_logic_vector(31 downto 0);
	 uart_data : in unsigned(31 downto 0);
	 uart_write : in std_logic;
	 uart_addr : in unsigned(10 downto 0));
end program_memory;

architecture Behavioral of program_memory is
    constant nop : std_logic_vector(31 downto 0) := x"54000000";

    type memory_type is array (0 to 1023) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := (
    	x"9C000001",	-- ADDI	R0, R0,	1
	x"9C210002",	-- ADDI	R1, R1,	2
	x"54000000",	-- NOP
	x"54000000",	-- NOP
	x"54000000",	-- NOP
	x"E4600800",	-- SFGEU	R0, R1
	x"54000000",	-- NOP
	x"54000000",	-- NOP
	x"54000000",	-- NOP
	x"BC600003",	-- SFGEUI	R0, 3
	x"54000000",	-- NOP
	x"54000000",	-- NOP
	x"54000000",	-- NOP
	x"BC610001",	-- SFGEUI	R1, 1
others => nop);

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if uart_write = '1' then
                program_memory(to_integer(uart_addr)) <= std_logic_vector(uart_data);
            elsif (address >= 4 and address <= 1027) then
                data <= program_memory(to_integer(address - 4));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;
