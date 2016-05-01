
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

    type memory_type is array (0 to 12) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := (
	x"9D6B00E0",	--             ADDI    R11, R11, 224
	x"D500580A",	--             SW      R0, R11, SPRITE1_Y
	x"87E04008",	-- LOOP:       LW      R31, R0, NEW_FRAME
	x"BC1F0000",	--             SFEQI   R31, 0
	x"13FFFFFE",	--             BF      LOOP
	x"54000000",	--             NOP
	x"84208000",	--             LW      R1, R0, LEFT
	x"E14A0800",	-- 	        ADD	    R10, R10, R1
	x"84208001",	-- 	        LW      R1, R0, RIGHT
	x"E14A0802",	-- 	        SUB	    R10, R10, R1
	x"D5005009",	--             SW      R0, R10, SPRITE1_X
	x"03FFFFF7",	--             JMP     LOOP
	x"54000000"		--             NOP
 );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            -- Small offset because of unreliable behaviour near pc=0
            if address >= 4 and address <= 16 then
                data <= program_memory(to_integer(address - 4));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;
