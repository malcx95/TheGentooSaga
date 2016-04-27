
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

    type memory_type is array (0 to 8) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := (
	x"18000000",	--     MOVHI R0, 0
	x"18200000",	--     MOVHI R1, 0
	x"84208000",	-- START: LW R1, R0, LEFT
	x"D5000800",	-- 	   SW R0, R1, 0X4000
	x"84208001",	-- 	   LW R1, R0, RIGHT
	x"D5000801",	-- 	   SW R0, R1, 0X4001
	x"84208002",	-- 	   LW R1, R0, SPACE
	x"D5000802",	-- 	   SW R0, R1, 0X4002
	x"03FFFFFA"		-- 	   JMP START
 );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (address <= 8) then
                data <= program_memory(to_integer(address));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;