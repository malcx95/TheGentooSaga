library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;    
                             

-- entity
entity ps2_tb is
	port(
		clk : in std_logic;
		rst : in std_logic;
		PS2KeyboardClk : in std_logic;
		PS2KeyboardData : in std_logic;
		Led : out std_logic_vector(5 downto 0)
		);	
end ps2_tb;


-- architecture
architecture Behavioral of ps2_tb is

  component ps2
	port(
		clk : in std_logic;
		ps2_clk : in std_logic;
		ps2_data : in std_logic;
		key_addr : in std_logic_vector(1 downto 0);
		key_out : out std_logic;
		key_reg_out : out std_logic_vector(3 downto 0);
		rst : in std_logic
		);
  end component;

  signal fake_addr : std_logic_vector(1 downto 0) := "00";
  signal time_counter : std_logic_vector(20 downto 0) := (others => '0');
  signal fake_clk : std_logic;

begin

	U0 : ps2 port map(clk=>clk, rst=>rst, ps2_clk=>PS2KeyboardClk,
					ps2_data=>PS2KeyboardData, key_reg_out=>Led(3 downto 0),
					key_addr=>fake_addr, key_out=>Led(4));
	

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' or time_counter = "111111111111111111111" then
				time_counter <= (others => '1');
				fake_addr <= fake_addr + 1;
				fake_clk <= not fake_clk;
			else
				time_counter <= time_counter + 1;
			end if;
		end if;
	end process;

	Led(5) <= fake_clk;

end Behavioral;

