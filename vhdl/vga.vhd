library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga is
	port (
		clk	: in std_logic;
		maddr : out std_logic_vector(11 downto 0);
		 );
