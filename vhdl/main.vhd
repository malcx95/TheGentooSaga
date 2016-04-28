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
		Led				: out std_logic_vector(7 downto 0);
		JA              : out std_logic_vector(7 downto 0)
        );
end main;

architecture behavioral of main is

	component cpu
		port (
		    clk			: in std_logic;
		    maddr		: out unsigned(15 downto 0);
		    mread_write	: out std_logic;
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
				rst : in std_logic
             );
	end component;

	component data_memory
	port (
			clk : in std_logic;
			address : in unsigned(15 downto 0);
			read_write : in std_logic;
			data_from : out std_logic_vector(31 downto 0);
			data_to : in std_logic_vector(31 downto 0);
			-- for communicating with ps2-unit:
			ps2_addr : out unsigned(1 downto 0);
			ps2_key : in std_logic;
			led_address : out unsigned(2 downto 0);
			led_write : out std_logic;
			led_data_in : out std_logic
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
            Vsync       : out std_logic
            );
	end component;

    component level_mem
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
    --signal dataEnable_s     : std_logic;
    signal dataWrite_s      : std_logic;
    -- signals between cpu and program memory
    signal pc               : unsigned(10 downto 0);
    signal newInstruction   : std_logic_vector(31 downto 0);
    -- signals between vga and level_mem
    signal pictData_s       : std_logic_vector(4 downto 0);
    signal pictAddr_s       : unsigned(11 downto 0);
    -- signals between music and music memory
    signal musAddr_s        : unsigned(6 downto 0);
    signal musData_s        : unsigned(7 downto 0);
	-- signals between data memory and ps2
	signal ps2_addr_s		: unsigned(1 downto 0);
	signal ps2_key_s		: std_logic;

    signal audio_out        : std_logic;

	signal led_data_in_s	: std_logic;
	signal led_address_s	: unsigned(2 downto 0);
	signal led_write_s		: std_logic;
	signal led_data_out_s	: std_logic_vector(7 downto 0);

begin
	cpu_c : cpu port map(clk=>clk, rst=>rst, maddr=>dataAddr_s,
                         mread_write=>dataWrite_s,
                         mdata_to=>dataTo_s, mdata_from=>dataFrom_s,
                         progc=>pc, pmem_in=>newInstruction);

    program_memory_c : program_memory port map(clk=>clk, address=>pc,
                                               data=>newInstruction);

    vga_c : vga port map(clk=>clk, rst=>rst, vgaRed=>vgaRed, vgaGreen=>vgaGreen,
                         vgaBlue=>vgaBlue, Hsync=>Hsync, Vsync=>Vsync,
                         pictData=>pictData_s, pictAddr=>pictAddr_s);

	data_memory_c : data_memory port map(clk=>clk, address=>dataAddr_s,
                                         read_write=>dataWrite_s,
                                         data_to=>dataTo_s, data_from=>dataFrom_s,
										 ps2_addr=>ps2_addr_s, ps2_key=>ps2_key_s,
										 led_address=>led_address_s,
										 led_write=>led_write_s,
										 led_data_in=>led_data_in_s);

    level_mem_c : level_mem port map(clk=>clk, addr=>pictAddr_s,
                                   data_out=>pictData_s);

    music_c : music port map(clk=>clk, rst=>rst, addr=>musAddr_s, data=>musData_s,
                             audio_out=>audio_out);

    music_mem_c : music_memory port map(clk=>clk, address=>musAddr_s,
                                        data=>musData_s);

	keyboard : ps2 port map(clk=>clk, ps2_clk=>PS2KeyboardClk, key_addr=>ps2_addr_s,
                            ps2_data=>PS2KeyboardData, rst=>rst,
							key_out=>ps2_key_s);

	led_c : led_control port map(clk=>clk,rst=>rst,address=>led_address_s,
						 led_data_in=>led_data_in_s,led_write=>led_write_s,
						 led_data_out=>led_data_out_s);

	JA <= "0000000" & audio_out;

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				Led <= (others => '0');
			else
				Led <= led_data_out_s;
			end if;
		end if;
	end process;

end behavioral;
