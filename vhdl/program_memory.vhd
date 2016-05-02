
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

    type memory_type is array (0 to 11) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := (
	x"E3E00800",	-- START:	ADD		R31, R0, R1
	x"946400FA",	-- 		SUBI	R3, R4, RAND
	x"00000002",	-- 		JMP		HEH
	x"54000000",	-- 	NOP
	x"54000000",	-- HA:	NOP
	x"54000000",	-- 	NOP
	x"E0222000",	-- 	ADD R1, R2, R4
	x"54000000",	-- 	NOP
	x"03FFFFFC",	-- 	JMP HA
	x"00000001",	-- 	JMP L
	x"BC03FFFF",	-- 		SFEQI	R3, KEBAB
	x"13FFFFF5"		-- 		BF		START
 );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (address >= 4 and address <= 11) then
                data <= program_memory(to_integer(address - 4));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;
