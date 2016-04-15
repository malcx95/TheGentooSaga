library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main
	port(
		clk : in std_logic;
		rst : in std_logic;
		vgaRed : out std_logic_vector(2 downto 0);
		vgaGreen : out std_logic_vector(2 downto 0);
		vgaBlue : out std_logic_vector(2 downto 0);
		Hsynch : out std_logic;
		Vsynch : out std_logic;
		PS2KeyboardData : in std_logic;
		PS2KeyboardClk : in std_logic;
		JA : out std_logic
		);
end main;

architecture behavioral of main is

	component cpu
		port (
		clk			: in std_logic;
		maddr		: out std_logic_vector(15 downto 0);
		mread_write	: out std_logic;
		ce			: out std_logic;
		mdata_to	: out std_logic_vector(31 downto 0);
		mdata_from	: in std_logic_vector(31 downto 0);
		pc			: buffer std_logic_vector(10 downto 0);
		pmem_in		: in std_logic_vector(31 downto 0);
		rst : in std_logic);
	end component;
	
	component ps2
		port (
			clk : in std_logic;
			ps2_clk : in std_logic;
			ps2_data : in std_logic;
			key_addr : in std_logic_vector(1 downto 0);
			key_out : out std_logic;
			rst : in std_logic);
	end component;

	component vga
		port (
			clk         : in std_logic;
            data        : in std_logic_vector(7 downto 0);
		    addr        : out std_logic_vector(11 downto 0);
            rst         : in std_logic;
            vgaRed      : out std_logic_vector(2 downto 0);
            vgaGreen    : out std_logic_vector(2 downto 0);
            vgaBlue     : out std_logic_vector(2 downto 1);
            Hsync       : out std_logic;
            Vsync       : out std_logic);
	end component;

	component data_memory
		port (
			-- TODO not complete
			clk : in std_logic
			address : in std_logic_vector(15 downto 0);
			chip_enable : in std_logic;
			read_write : in std_logic;
			data : inout std_logic_vector(31 downto 0));
	end component;
	
	-- TODO add music

begin
	-- TODO map the shit
	U0 : cpu port map();
	U1 : ps2 port map();
	U2 : vga port map();
	U3 : data_memory port map();
end behavioral;
