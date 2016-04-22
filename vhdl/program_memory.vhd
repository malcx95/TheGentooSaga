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
        x"18200000",   -- movhi r1, 0000
        x"18400000",   -- movhi r2, 0000
        x"9c210008",   -- addi r1, r1, 0008
        x"9c420020",   -- addi r2, r2, 0020
        x"84620000",   -- lw r3, 0000(r2)
        x"84820020",   -- lw r4, 0020(r2)
        x"e0c62800",   -- add r6, r6, r5
        x"e0a41b06",   -- muls r5, r4, r3
        x"9c420001",   -- addi r2, r2, 0001
        x"9c21ffff",   -- addi r1, r1, FFFF
        x"e4200800",   -- sfne r0, r1
        x"13fffff9",   -- bf 0000010
        x"d4003000"    -- sw 0000(r0), r6
    );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (address <= 12) then
                data <= program_memory(to_integer(address));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;

