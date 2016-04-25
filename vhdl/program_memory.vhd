
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
    
    type memory_type is array (0 to 9) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := ( 
	x"18000000",	-- 		MOVHI	R0, 0 # R0 BARA 0
	x"1820FFFF",	-- 		MOVHI	R1, 0XFFFF
	x"9C21FFFF",	-- 		ADDI	R1, R1, 0XFFFF # R1 BARA 1
	x"84408000",	-- LOOP:	LW		R2, R0, SPACE
	x"E4001000",	-- 		SFEQ	R0, R2
	x"13FFFFFE",	-- 		BF		LOOP
	x"84408000",	-- BLINK:	LW		R2, R0, SPACE
	x"E4201000",	-- 		SFNE	R0, R2
	x"13FFFFFE",	-- 		BF		BLINK
	x"03FFFFFA"		-- 		JMP		LOOP
 );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (address <= 9) then
                data <= program_memory(to_integer(address));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;