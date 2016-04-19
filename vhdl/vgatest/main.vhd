library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity main is
	port (
		clk             : in std_logic;
		rst             : in std_logic;
		vgaRed          : out std_logic_vector(2 downto 0);
		vgaGreen        : out std_logic_vector(2 downto 0);
		vgaBlue         : out std_logic_vector(2 downto 1);
		Hsync           : out std_logic;
		Vsync           : out std_logic;
		PS2KeyboardData : in std_logic;
		PS2KeyboardClk  : in std_logic;
		JA              : out std_logic
		 );
end main;

architecture behavioral of main is

--	component cpu
--		port (
--		    clk			: in std_logic;
--		    maddr		: out std_logic_vector(15 downto 0);
--		    mread_write	: out std_logic;
--		    ce			: out std_logic;
--		    mdata_to	: out std_logic_vector(31 downto 0);
--		    mdata_from	: in std_logic_vector(31 downto 0);
--		    pc			: buffer std_logic_vector(10 downto 0);
--		    pmem_in		: in std_logic_vector(31 downto 0);
--		    rst         : in std_logic
--             );
--	end component;
	
--	component ps2
--		port (
--			clk      : in std_logic;
--			ps2_clk  : in std_logic;
--			ps2_data : in std_logic;
--			--key_addr : in std_logic_vector(1 downto 0);
--			key_out  : out std_logic;
--			rst      : in std_logic
--             );
--	end component;

	component data_memory
		port (
			-- TODO not complete
			clk         : in std_logic;
			address     : in std_logic_vector(15 downto 0);
			chip_enable : in std_logic;
			read_write  : in std_logic;
			data        : inout std_logic_vector(31 downto 0)
             );
	end component;

	component vga
		port (
			      clk         : in std_logic;
            pictData    : in std_logic_vector(4 downto 0);
		        pictAddr    : out unsigned(11 downto 0);
            rst         : in std_logic;
            vgaRed      : out std_logic_vector(2 downto 0);
            vgaGreen    : out std_logic_vector(2 downto 0);
            vgaBlue     : out std_logic_vector(2 downto 1);
            Hsync       : out std_logic;
            Vsync       : out std_logic;
            tileAddr    : out unsigned(12 downto 0);
            tilePixel   : in std_logic_vector(7 downto 0)
             );
	end component;

    component tile_and_sprite_memory
        port (
            clk     : in std_logic;
            addr    : in unsigned(12 downto 0);
            pixel   : out std_logic_vector(7 downto 0)
             );
    end component;

    component pict_mem
        port (
            clk         : in std_logic;
            data_out    : out std_logic_vector(4 downto 0);
            addr        : in unsigned(11 downto 0)
             );
    end component;

    component music
        port (
            clk       : in std_logic;
            data      : in std_logic_vector(7 downto 0);
            addr      : out std_logic_vector(6 downto 0);
            audio_out : buffer std_logic
             );
    end component;

    -- signals between vga and tile_and_sprite_memory
    signal tileAddr_s       : unsigned(12 downto 0);
    signal tilePixel_s      : std_logic_vector(7 downto 0);
    -- signals between vga and pict_mem
    signal pictData_s       : std_logic_vector(4 downto 0);
    signal pictAddr_s       : unsigned(11 downto 0);



begin
	--U0 : cpu port map(clk=>clk, rst=>rst);
--	U0 : ps2 port map(clk=>clk, ps2_clk=>PS2KeyboardClk, ps2_data=>PS2KeyboardData, rst=>rst);
    -- TODO: Add mapping for spites
    U0 : vga port map(clk=>clk, rst=>rst, vgaRed=>vgaRed, vgaGreen=>vgaGreen, vgaBlue=>vgaBlue,
                      Hsync=>Hsync, Vsync=>Vsync, tileAddr=>tileAddr_s, tilePixel=>tilePixel_s,
                      pictData=>pictData_s, pictAddr=>pictAddr_s);
	--U2 : data_memory port map();
    U1 : tile_and_sprite_memory port map(clk=>clk, addr=>tileAddr_s, pixel=>tilePixel_s);
    U2 : pict_mem port map(clk=>clk, addr=>pictAddr_s, data_out=>pictData_s);
end behavioral;
