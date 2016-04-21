library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;    
                             

-- entity
entity ps2_tb is
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

	-- Test signals
	signal clk : std_logic := '0';
	signal ps2_clk : std_logic := '0';
	signal ps2_data : std_logic := '0';
	signal key_addr : std_logic_vector(1 downto 0) := "00";
	signal key_out : std_logic := '0';
	signal key_reg_out : std_logic_vector(3 downto 0) := "0000";
	signal rst : std_logic := '0';

	constant ps2_data_test : std_logic_vector(20 downto 0) 
	:= "111110001010010111111";
	signal data_count : integer := 0;

begin

	uut : ps2 port map(clk=>clk, rst=>rst, ps2_clk=>ps2_clk, ps2_data=>ps2_data,
						key_out=>key_out, key_reg_out=>key_reg_out, key_addr=>key_addr);
	
	clk <= not clk after 5 ns;

	ps2_clk <= not ps2_clk after 5 us;

	reset : process
	begin
		rst <= '1';
		wait for 10 us;
		rst <= '0';
		wait;
	end process;

	process(ps2_clk)
	begin
		if falling_edge(ps2_clk) then
			data_count <= data_count + 1;
		end if;
	end process;

	ps2_data <= ps2_data_test(data_count);

end Behavioral;

