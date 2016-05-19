library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
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

		song_choice : out std_logic_vector(1 downto 0);
		music_reset : out std_logic;
		music_mute : out std_logic;

		query_addr : out unsigned(11 downto 0);
		query_result : in std_logic
		);
end data_memory;

architecture Behavioral of data_memory is

    signal data_is_not_zero : std_logic;
    signal new_frame_flag : std_logic;
	signal query_x : unsigned(7 downto 0);
	signal query_y : unsigned(4 downto 0);
	signal music_reset_q : std_logic;

    constant led0 : unsigned(15 downto 0) := x"4000";
    constant led7 : unsigned(15 downto 0) := x"4007";
	constant song_choice_addr : unsigned(15 downto 0) := x"3FFF";
	constant music_reset_addr : unsigned(15 downto 0) := x"3FFE";
	constant music_mute_addr : unsigned(15 downto 0) := x"3FFD";
    constant new_frame_address : unsigned(15 downto 0) := x"4008";
    constant sprite1_x : unsigned(15 downto 0) := x"5000";
    constant sprite1_y : unsigned(15 downto 0) := x"5010";
	constant sprite6_x : unsigned(15 downto 0) := x"5005";
	constant sprite6_y : unsigned(15 downto 0) := x"5015";
    constant scroll_offset : unsigned(15 downto 0) := x"400B";
	constant query_x_addr : unsigned(15 downto 0) := x"400C";
	constant query_y_addr : unsigned(15 downto 0) := x"400D";
	constant query_result_addr : unsigned(15 downto 0) := x"400E";

    -- memory consists of 512 32-bit words
    type ram_t is array (0 to 511) of
        std_logic_vector(31 downto 0);

    signal ram : ram_t := (others => (others => '0'));

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if chip_enable = '1' then
                if (read_write = '1') then
                    -- If the address is inside memory, write to the specified
                    -- position
                    if (address < 512) then
                        ram(to_integer(address)) <= data_to;
                    elsif address = song_choice_addr then
                        song_choice <= data_to(1 downto 0);
					elsif address = music_mute_addr then
						music_mute <= data_to(0);
                    elsif address = query_x_addr then
                        query_x <= unsigned(data_to(11 downto 4));
                    elsif address = query_y_addr then
                        query_y <= unsigned(data_to(8 downto 4));
                    end if;
                else
                    if (address < 512) then
                        data_from <= ram(to_integer(address));
                    elsif address >= x"8000" and address <= x"8002" then
                        -- keyboard
                        data_from <= (others => ps2_key);
                    elsif address = query_result_addr then
                        data_from <= (others => query_result);
                    elsif address = new_frame_address then
                        data_from <= (others => new_frame_flag);
                    else
                        data_from <= (others => '0');
                    end if;
                end if;
            end if;
        end if;
    end process;

	-- process music restart, one pulse
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				music_reset_q <= '1';
			elsif address = music_reset_addr and read_write = '1' then
				music_reset_q <= data_to(0);
			end if;
		end if;
	end process;

	music_reset <= (not music_reset_q) and data_to(0);

    process(clk, rst)
    begin
        if rst = '1' then
            new_frame_flag <= '0';
        elsif rising_edge(clk) then
            if new_frame = '1' then
                new_frame_flag <= '1';
            elsif chip_enable = '1' and address = new_frame_address then
                new_frame_flag <= '0';
            end if;
        end if;
    end process;

    ps2_addr <= address(1 downto 0);
    data_is_not_zero <= '1' when data_to /= x"00000000" else '0';

	query_addr <= to_unsigned(15, 4) * query_x + query_y;

    -- LED:s
    led_write <= '1' when address >= led0 and address <= led7 and
                 read_write = '1' else '0';
    led_data_in <= data_is_not_zero;
    led_address <= address(2 downto 0);

    -- Sprite position
    new_sprite_x <= unsigned(data_to(8 downto 0));
    new_sprite_y <= unsigned(data_to(8 downto 0));
    new_scroll_offset <= unsigned(data_to(11 downto 0));
	sprite_index <= address(2 downto 0);
    write_sprite_x <= '1' when address >= sprite1_x and
					  address <= sprite6_x and read_write = '1' else '0';
    write_sprite_y <= '1' when address >= sprite1_y and
					  address <= sprite6_y and read_write = '1' else '0';
    write_scroll_offset <= '1' when address = scroll_offset and read_write = '1' else '0';
end Behavioral;

