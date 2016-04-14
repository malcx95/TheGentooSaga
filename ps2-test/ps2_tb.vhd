library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;    
                             

-- entity
entity ps2_tb is
	port(
		clk : in std_logic;
		PS2KeyboardClk : in std_logic;
		PS2KeyboardData : in std_logic;
		Led : out std_logic_vector(3 downto 0);
		);	
end VGA_lab;


-- architecture
architecture Behavioral of ps2_tb is

  component ps2
	port(
		clk : in std_logic;
		ps2_clk : in std_logic;
		ps2_data : in std_logic;
		key_addr : in std_logic_vector(1 downto 0);
		key_out : out std_logic;
		key_reg : buffer std_logic_vector(3 downto 0);
		rst : in std_logic
		);
  end component;

begin

  U0 : ps2 port map(clk=>clk, rst=>rst, ps2_clk=>PS2KeyboardClk,
					ps2_data=>PS2KeyboardData, key_reg=>Led);

end Behavioral;

