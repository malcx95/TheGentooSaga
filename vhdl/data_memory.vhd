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
		ps2_addr : out std_logic_vector(1 downto 0);
		ps2_key : in std_logic;
		led_address : out std_logic_vector(2 downto 0);
		led_write : out std_logic;
		led_data_in : out std_logic
		);
end data_memory;

architecture Behavioral of data_memory is

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
					led_data_in <= data_to(0);
					led_address <= std_logic_vector(address(2 downto 0));
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
                else
                    data_from <= (others => '0');
                    -- TODO: implement memory mapped I/O
                end if;
            end if;
        end if;
    end process;

    with address select ps2_addr  <=
                "00" when x"8000", -- left 
                "01" when x"8001", -- right
                "10" when x"8002", -- space
				"11" when others;
end Behavioral;

