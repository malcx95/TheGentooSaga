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
		Led				: buffer std_logic_vector(3 downto 0);
		JA              : out std_logic_vector(7 downto 0)
        );
end main;

architecture behavioral of main is

	component cpu
		port (
		    clk			: in std_logic;
		    maddr		: out std_logic_vector(15 downto 0);
		    mread_write	: out std_logic;
		    --ce			: out std_logic;
		    mdata_to	: out std_logic_vector(31 downto 0);
		    mdata_from	: in std_logic_vector(31 downto 0);
		    progc		: out unsigned(10 downto 0);
		    pmem_in		: in std_logic_vector(31 downto 0);
		    rst         : in std_logic
            );
	end component;

	component ps2
		port (
				clk : in std_logic;
				ps2_clk : in std_logic;
				ps2_data : in std_logic;
				key_addr : in std_logic_vector(1 downto 0);
				key_out : out std_logic;
				key_reg_out : out std_logic_vector(3 downto 0);
				rst : in std_logic
             );
	end component;

	component data_memory
		port (
			-- TODO not complete
			clk         : in std_logic;
			address     : in std_logic_vector(15 downto 0);
			--chip_enable : in std_logic;
			read_write  : in std_logic;
			data_to     : in std_logic_vector(31 downto 0);
			data_from   : out std_logic_vector(31 downto 0)
            );
	end component;

    component program_memory
        port (
            clk         : in std_logic;
            address     : in unsigned(10 downto 0);
            data        : out std_logic_vector(31 downto 0)
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
            tilePixel   : in std_logic_vector(7 downto 0);
            keyreg      : in std_logic_vector(3 downto 0)
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
        port (clk       : in std_logic;
              rst       : in std_logic;
              data      : in unsigned(7 downto 0);
              addr      : buffer unsigned(6 downto 0);
              audio_out : buffer std_logic);
    end component;

    component music_memory
        port (clk : in std_logic;
              address : in unsigned(6 downto 0);
              data : out unsigned(7 downto 0));
    end component;

    -- signals between cpu and data memory
    signal dataAddr_s       : std_logic_vector(15 downto 0);
    signal dataFrom_s       : std_logic_vector(31 downto 0);
    signal dataTo_s         : std_logic_vector(31 downto 0);
    --signal dataEnable_s     : std_logic;
    signal dataWrite_s      : std_logic;
    -- signals between cpu and program memory
    signal pc               : unsigned(10 downto 0);
    signal newInstruction   : std_logic_vector(31 downto 0);
    -- signals between vga and tile_and_sprite_memory
    signal tileAddr_s       : unsigned(12 downto 0);
    signal tilePixel_s      : std_logic_vector(7 downto 0);
    -- signals between vga and pict_mem
    signal pictData_s       : std_logic_vector(4 downto 0);
    signal pictAddr_s       : unsigned(11 downto 0);
    -- signals between music and music memory
    signal musAddr_s        : unsigned(6 downto 0);
    signal musData_s        : unsigned(7 downto 0);

    signal audio_out        : std_logic;


    -- signals between keyboard and vga
    signal keyreg_s         : std_logic_vector(3 downto 0);

begin
	cpu_c : cpu port map(clk=>clk, rst=>rst, maddr=>dataAddr_s,
                         mread_write=>dataWrite_s,
                         mdata_to=>dataTo_s, mdata_from=>dataFrom_s,
                         progc=>pc, pmem_in=>newInstruction);
    program_memory_c : program_memory port map(clk=>clk, address=>pc,
                                               data=>newInstruction);
    -- TODO: Add mapping for spites
    vga_c : vga port map(clk=>clk, rst=>rst, vgaRed=>vgaRed, vgaGreen=>vgaGreen,
                         vgaBlue=>vgaBlue, Hsync=>Hsync, Vsync=>Vsync,
                         tileAddr=>tileAddr_s, tilePixel=>tilePixel_s,
                         pictData=>pictData_s, pictAddr=>pictAddr_s,
                         keyreg=>keyreg_s);

	data_memory_c : data_memory port map(clk=>clk, address=>dataAddr_s,
                                         read_write=>dataWrite_s,
                                         data_to=>dataTo_s, data_from=>dataFrom_s);

    tile_mem_c : tile_and_sprite_memory port map(clk=>clk, addr=>tileAddr_s,
                                                 pixel=>tilePixel_s);

    pict_mem_c : pict_mem port map(clk=>clk, addr=>pictAddr_s,
                                   data_out=>pictData_s);

    music_c : music port map(clk=>clk, rst=>rst, addr=>musAddr_s, data=>musData_s,
                             audio_out=>audio_out);

    music_mem_c : music_memory port map(clk=>clk, address=>musAddr_s,
                                        data=>musData_s);

	keyboard : ps2 port map(clk=>clk, ps2_clk=>PS2KeyboardClk, key_addr=>"00",
                            ps2_data=>PS2KeyboardData, rst=>rst, key_reg_out=>keyreg_s);

    JA <= "0000000" & audio_out when keyreg_s = "0000" else (others => '0');
end behavioral;
