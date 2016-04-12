--------------------------------------------------------------------------------
-- VGA lab
-- Anders Nilsson
-- 16-dec-2015
-- Version 1.0


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

-- entity
entity VGA_lab is
  port ( clk	                : in std_logic;                         -- system clock
	 rst                    : in std_logic;                         -- reset
	 Hsync	                : out std_logic;                        -- horizontal sync
	 Vsync	                : out std_logic;                        -- vertical sync
	 vgaRed	                : out	std_logic_vector(2 downto 0);   -- VGA red
	 vgaGreen               : out std_logic_vector(2 downto 0);     -- VGA green
	 vgaBlue	        : out std_logic_vector(2 downto 1));     -- VGA blue
end VGA_lab;


-- architecture
architecture Behavioral of VGA_lab is

  -- VGA motor component
  component colors
    port ( clk			: in std_logic;                         -- system clock
           rst			: in std_logic;                         -- reset
           vgaRed		: out std_logic_vector(2 downto 0);     -- VGA red
           vgaGreen	        : out std_logic_vector(2 downto 0);     -- VGA green
           vgaBlue		: out std_logic_vector(2 downto 1);     -- VGA blue
           Hsync		: out std_logic;                        -- horizontal sync
           Vsync		: out std_logic);                       -- vertical sync
  end component;

begin

  -- VGA motor component connection
  U2 : colors port map(clk=>clk, rst=>rst, vgaRed=>vgaRed, vgaGreen=>vgaGreen, vgaBlue=>vgaBlue, Hsync=>Hsync, Vsync=>Vsync);

end Behavioral;

