library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
	port (
		clk : in std_logic;
		address : in unsigned(15 downto 0);
		--chip_enable : in std_logic;
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
        rst_new_frame : out std_logic;

        sprite1_x : out unsigned(8 downto 0);
        write_sprite1_x : out std_logic;
        sprite1_y : out unsigned(8 downto 0);
        write_sprite1_y : out std_logic
		);
end data_memory;

architecture Behavioral of data_memory is

    signal data_is_not_zero : std_logic;

    -- memory consists of 512 32-bit words
    type ram_t is array (0 to 511) of
        std_logic_vector(31 downto 0);

    signal ram : ram_t := (32 => x"00000001",
                           33 => x"00000002",
                           34 => x"00000003",
                           35 => x"00000004",
                           36 => x"00000005",
                           37 => x"00000006",
                           38 => x"00000007",
                           39 => x"00000008",

                           64 => x"00000001",
                           65 => x"00000002",
                           66 => x"00000003",
                           67 => x"00000004",
                           68 => x"00000005",
                           69 => x"00000006",
                           70 => x"00000007",
                           71 => x"00000008",
                           others => (others => '0'));

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (read_write = '1') then
                -- If the address is inside memory, write to the specified
                -- position
                if (address < 512) then
                    ram(to_integer(address)) <= data_to;
				elsif address >= x"4000" and address <= x"4007" then
					-- LED:s
					led_data_in <= data_is_not_zero;
					led_address <= address(2 downto 0);
                end if;

				if address >= x"4000" and address <= x"4007" then
					led_write <= '1';
				else
					led_write <= '0';
                end if;
            else
				led_write <= '0';
                if (address < 512) then
                    data_from <= ram(to_integer(address));
				elsif address >= x"8000" and address <= x"8002" then
					-- keyboard
					data_from <= (others => ps2_key);
                elsif address = x"4008" then
                    data_from <= (others => new_frame);
                else
                    data_from <= (others => '0');
                end if;

                if address = x"4008" then
                    rst_new_frame <= '1';
                else
                    rst_new_frame <= '0';
                end if;
            end if;
        end if;
    end process;

    ps2_addr <= address(1 downto 0);
    data_is_not_zero <= '1' when data_to /= x"00000000" else '0';

    -- Sprite 1 position
    sprite1_x <= unsigned(data_to(8 downto 0));
    sprite1_y <= unsigned(data_to(8 downto 0));
    write_sprite1_x <= '1' when address = x"4009" else '0';
    write_sprite1_y <= '1' when address = x"400A" else '0';

    --sprite1_y <= "011100000";
    --write_sprite1_y <= '1';
end Behavioral;

