
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
    
    type memory_type is array (0 to 27) of std_logic_vector(31 downto 0);
    signal program_memory : memory_type := ( 
	x"18200001",	--         MOVHI   R1,1        ; R1 = 1
	x"18400004",	--         MOVHI   R2,4        ; R2 = 4
	x"9C210001",	-- LOOP:   ADDI    R1,R1,0B01  ; INCEMENT R1 BY 1
	x"03FFFFFF",	--         JMP     LOOP        ; JUMP BACK TO LOOP
	x"E0611000",	--         ADD     R3,R1,R2    ; R3 = 5
	x"9C420002",	--         ADDI    R2,R2,0B10     ; R2 = 6
	x"9C210001",	--         ADDI    R1,R1,0B01     ; R1 = 2
	x"84810014",	--         LW      R4,R1,20    ; R4 = 2
	x"E0A11006",	--         MUL     R5,R1,R2    ; R5 = 12
	x"54000000",	--         NOP                 ; 
	x"18200001",	--         MOVHI   R1,1        ; R1 = 1
	x"18400001",	--         MOVHI   R2,1        ; R2 = 1
	x"E4011000",	--         SFEQ    R1,R2       ; F = 1
	x"18200002",	--         MOVHI   R1,2        ; R1 = 2
	x"54000000",	--         NOP                 ; 
	x"54000000",	--         NOP                 ; 
	x"E4011000",	--         SFEQ    R1,R2       ; F = 0
	x"54000000",	--         NOP                 ; 
	x"54000000",	--         NOP                 ; 
	x"54000000",	--         NOP                 ; 
	x"54000000",	--         NOP                 ; 
	x"18200005",	--         MOVHI   R1,5        ; R1 = 5
	x"E4230800",	--         SFNE    R3,R1       ; F = 1
	x"54000000",	--         NOP                 ;
	x"54000000",	--         NOP                 ;
	x"54000000",	--         NOP                 ;
	x"BC210005",	--         SFNEI   R1,5        ; F = 0
	x"D4060800"		--         SW      R6,R1,0     ;
 );

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (address <= 27) then
                data <= program_memory(to_integer(address));
            else
                data <= nop;
            end if;
        end if;
    end process;
end Behavioral;