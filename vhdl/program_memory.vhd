
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

    type memory_type is array (0 to 29) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := (
	x"18200001",	-- MOVHI   R1,1        
	x"18400004",	-- MOVHI   R2,4        
	x"E4612000",	-- SFGEU   R1,R4
	x"10000006",	-- BF HELLO
	x"E0611000",	-- ADD     R3,R1,R2    
	x"9C420002",	-- ADDI    R2,R2,0B10     
	x"9C210001",	-- ADDI    R1,R1,0B01     
	x"84810014",	-- LW      R4,R1,20    
	x"E0A11006",	-- MUL     R5,R1,R2    
	x"54000000",	-- HELLO: NOP                 
	x"18200006",	-- MOVHI   R1,6        
	x"18400006",	-- MOVHI   R2,6        
	x"BC610006",	-- SFGEUI  R1,6
	x"10000002",	-- BF CHICKEN
	x"E4011000",	-- SFEQ    R1,R2       
	x"18200002",	-- CHICKEN: MOVHI   R1,2        
	x"54000000",	-- NOP                 
	x"54000000",	-- NOP                 
	x"E4011000",	-- SFEQ    R1,R2       
	x"54000000",	-- NOP                 
	x"54000000",	-- NOP                 
	x"54000000",	-- NOP                 
	x"54000000",	-- NOP                 
	x"18200005",	-- MOVHI   R1,5        
	x"E4230800",	-- SFNE    R3,R1       
	x"54000000",	-- NOP                 
	x"54000000",	-- NOP                 
	x"54000000",	-- NOP                 
	x"BC210005",	-- SFNEI   R1,5        
	x"D4060800"		-- SW      R6,R1,0     
 );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (address >= 4 and address <= 33) then
                data <= program_memory(to_integer(address - 4));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;
