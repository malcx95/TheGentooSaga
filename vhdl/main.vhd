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
		rx				: in std_logic;
		uart_switch		: in std_logic;
		Led				: out std_logic_vector(7 downto 0);
		speaker			: out std_logic
        );
end main;

architecture behavioral of main is

	component uart
	port(
		clk,rst,rx : in std_logic;
		pmem_addr : buffer unsigned(10 downto 0);
		data : out unsigned(31 downto 0);
		pmem_write : out std_logic
		);
	end component;

	component cpu
		port (
		    clk			: in std_logic;
		    maddr		: out unsigned(15 downto 0);
		    mread_write	: out std_logic;
		    menable     : out std_logic;
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
				key_addr : in unsigned(1 downto 0);
				key_out : out std_logic;
                key_reg_out : out std_logic_vector(3 downto 0);
				rst : in std_logic
             );
	end component;

	component data_memory
	port (
		clk : in std_logic;
        rst : in std_logic;
		address : in unsigned(15 downto 0);
		chip_enable : in std_logic;
		read_write : in std_logic;
		data_from : out std_logic_vector(31 downto 0);
		data_to : in std_logic_vector(31 downto 0);
		-- for communicating with ps2-unit:
		ps2_addr : out unsigned(1 downto 0);
		ps2_key : in std_logic;
		led_address : out unsigned(2 downto 0);
		led_write : out std_logic;
		led_data_in : out std_logic;

        new_frame : in std_logic;

        new_sprite_x : out unsigned(8 downto 0);
		sprite_index : out unsigned(2 downto 0);
        write_sprite_x : out std_logic;
        new_sprite_y : out unsigned(8 downto 0);
        write_sprite_y : out std_logic;

        new_scroll_offset : out unsigned(11 downto 0);
        write_scroll_offset : out std_logic;

		song_choice : out std_logic_vector(2 downto 0);
		music_reset : out std_logic;
		music_mute : out std_logic;

		query_addr : out unsigned(11 downto 0);
		query_result : in std_logic
		);
	end component;

    component program_memory
        port (
            clk         : in std_logic;
            address     : in unsigned(10 downto 0);
            data        : out std_logic_vector(31 downto 0);
			uart_data	: in unsigned(31 downto 0);
			uart_write	: in std_logic;
			uart_addr	: in unsigned(10 downto 0)
            );
    end component;

	component vga
		port (
            clk         : in std_logic;
            pictData    : in std_logic_vector(4 downto 0);
            levelAddr   : out unsigned(11 downto 0);
            rst         : in std_logic;
            vgaRed      : out std_logic_vector(2 downto 0);
            vgaGreen    : out std_logic_vector(2 downto 0);
            vgaBlue     : out std_logic_vector(2 downto 1);
            Hsync       : out std_logic;
            Vsync       : out std_logic;
            new_frame   : out std_logic;

			sprite_index : in unsigned(2 downto 0);
            new_sprite_x : in unsigned(8 downto 0);
            write_sprite_x : in std_logic;
            new_sprite_y : in unsigned(8 downto 0);
            write_sprite_y : in std_logic;

            new_scroll_offset : in unsigned(11 downto 0);
            write_scroll_offset : in std_logic
            );
	end component;

    component level_mem
        port (
            clk         : in std_logic;
            data_out    : out std_logic_vector(4 downto 0);
            addr        : in unsigned(11 downto 0);
			query_addr : in unsigned(11 downto 0);
			query_result : out std_logic
            );
    end component;

    component music
        port (clk       : in std_logic;
              rst       : in std_logic;
              data      : in unsigned(7 downto 0);
			  mute		: in std_logic;
              addr      : buffer unsigned(6 downto 0);
              audio_out : buffer std_logic);
    end component;

    component music_memory
        port (clk : in std_logic;
              address : in unsigned(6 downto 0);
              data : out unsigned(7 downto 0);
			  song_choice : in std_logic_vector(2 downto 0));
    end component;

	component led_control
		port (
		clk : in std_logic;
		rst : in std_logic;
		address : in unsigned(2 downto 0);
		led_data_in : in std_logic;
		led_write : in std_logic;
		led_data_out : out std_logic_vector(7 downto 0));
	end component;

    -- signals between cpu and data memory
    signal dataAddr_s       : unsigned(15 downto 0);
    signal dataFrom_s       : std_logic_vector(31 downto 0);
    signal dataTo_s         : std_logic_vector(31 downto 0);
    signal dataEnable_s     : std_logic;
    signal dataWrite_s      : std_logic;
    -- signals between cpu and program memory
    signal pc               : unsigned(10 downto 0);
    signal newInstruction   : std_logic_vector(31 downto 0);
    -- signals between vga and level_mem
    signal pictData_s       : std_logic_vector(4 downto 0);
    signal levelAddr_s       : unsigned(11 downto 0);
    -- signals between music and music memory
    signal musAddr_s        : unsigned(6 downto 0);
    signal musData_s        : unsigned(7 downto 0);
	-- signals between data memory and ps2
	signal ps2_addr_s		: unsigned(1 downto 0);
	signal ps2_key_s		: std_logic;
    signal key_reg_out      : std_logic_vector(3 downto 0);

    signal audio_out        : std_logic;

	signal led_data_in_s	: std_logic;
	signal led_address_s	: unsigned(2 downto 0);
	signal led_write_s		: std_logic;
	signal led_data_out_s	: std_logic_vector(7 downto 0);

    -- signals between vga and data memory
    signal new_frame        : std_logic;
    signal new_sprite_x    : unsigned(8 downto 0);
    signal write_sprite_x  : std_logic;
    signal new_sprite_y    : unsigned(8 downto 0);
    signal write_sprite_y  : std_logic;
	signal sprite_index		: unsigned(2 downto 0);
    signal new_scroll_offset : unsigned(11 downto 0);
    signal write_scroll_offset : std_logic;

	signal song_choice_s	: std_logic_vector(2 downto 0);
	signal music_mute_s		: std_logic;
	signal music_reset_raw	: std_logic;
	signal music_reset_s	: std_logic;

	signal query_addr_s		: unsigned(11 downto 0);
	signal query_result_s	: std_logic;

	signal pmem_addr_s		: unsigned(10 downto 0);
	signal uart_data_s		: unsigned(31 downto 0);
	signal pmem_write_s		: std_logic;

	signal reset			: std_logic;
	signal not_uart			: std_logic;

begin
	cpu_c : cpu port map(clk=>clk, rst=>reset, maddr=>dataAddr_s,
                         menable=>dataEnable_s,
                         mread_write=>dataWrite_s,
                         mdata_to=>dataTo_s, mdata_from=>dataFrom_s,
                         progc=>pc, pmem_in=>newInstruction);

    program_memory_c : program_memory port map(clk=>clk, address=>pc,
                                               data=>newInstruction,
											   uart_data=>uart_data_s,
											   uart_addr=>pmem_addr_s,
											   uart_write=>pmem_write_s);

    vga_c : vga port map(clk=>clk, rst=>reset, vgaRed=>vgaRed, vgaGreen=>vgaGreen,
                         vgaBlue=>vgaBlue, Hsync=>Hsync, Vsync=>Vsync,
                         pictData=>pictData_s, levelAddr=>levelAddr_s,
                         new_frame=>new_frame,
                         new_sprite_x=>new_sprite_x,
                         write_sprite_x=>write_sprite_x,
                         new_sprite_y=>new_sprite_y,
                         write_sprite_y=>write_sprite_y,
						 sprite_index=>sprite_index,
                         new_scroll_offset=>new_scroll_offset,
                         write_scroll_offset=>write_scroll_offset);

	data_memory_c : data_memory port map(clk=>clk, address=>dataAddr_s,
                                         rst=>reset,
                                         chip_enable=>dataEnable_s,
                                         read_write=>dataWrite_s,
                                         data_to=>dataTo_s, data_from=>dataFrom_s,
										 ps2_addr=>ps2_addr_s, ps2_key=>ps2_key_s,
										 led_address=>led_address_s,
										 led_write=>led_write_s,
										 led_data_in=>led_data_in_s,
                                         new_frame=>new_frame,
                                         new_sprite_x=>new_sprite_x,
                                         write_sprite_x=>write_sprite_x,
                                         new_sprite_y=>new_sprite_y,
                                         write_sprite_y=>write_sprite_y,
										 sprite_index=>sprite_index,
                                         new_scroll_offset=>new_scroll_offset,
                                         write_scroll_offset=>write_scroll_offset,
										 song_choice=>song_choice_s,
										 music_reset=>music_reset_raw,
										 music_mute=>music_mute_s,
										 query_addr=>query_addr_s,
										 query_result=>query_result_s);

    level_mem_c : level_mem port map(clk=>clk, addr=>levelAddr_s,
                                   data_out=>pictData_s,query_addr=>query_addr_s,
									query_result=>query_result_s);

    music_c : music port map(clk=>clk, rst=>music_reset_s,
							 addr=>musAddr_s, data=>musData_s,
							 mute=>music_mute_s,
                             audio_out=>audio_out);

    music_mem_c : music_memory port map(clk=>clk, address=>musAddr_s,
                                        data=>musData_s,song_choice=>song_choice_s);

	keyboard : ps2 port map(clk=>clk, ps2_clk=>PS2KeyboardClk, key_addr=>ps2_addr_s,
                            ps2_data=>PS2KeyboardData, rst=>reset,
							key_out=>ps2_key_s, key_reg_out=>key_reg_out);

	led_c : led_control port map(clk=>clk,rst=>reset,address=>led_address_s,
						 led_data_in=>led_data_in_s,led_write=>led_write_s,
						 led_data_out=>led_data_out_s);
	
	uart_c : uart port map(clk=>clk,rst=>not_uart,rx=>rx,data=>uart_data_s,
						   pmem_write=>pmem_write_s,pmem_addr=>pmem_addr_s);

	speaker <= audio_out;
	
	reset <= rst or uart_switch;

	music_reset_s <= music_reset_raw or reset;

	not_uart <= not uart_switch;

	Led <= led_data_out_s when rst = '0' else (others => '1');

end behavioral;
