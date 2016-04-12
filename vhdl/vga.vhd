library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga is
	port (  clk         : in std_logic;
            data        : in std_logic_vector(4 downto 0);
		    addr        : out std_logic_vector(11 downto 0);
            rst         : in std_logic;
            vgaRed      : out std_logic_vector(2 downto 0);
            vgaGreen    : out std_logic_vector(2 downto 0);
            vgaBlue     : out std_logic_vector(2 downto 1);
            Hsync       : out std_logic;
            Vsync       : out std_logic;
        );

end vga;

architecture Behavioral of vga is
    signal Xpixel       : unsigned(9 downto 0); -- Horizonatal pixel counter
    signal Ypixel       : unsigned(9 downto 0); -- Vertical pixel counter
    signal ClkDiv       : unsigned(1 downto 0); -- Clock divisor, to generate 25 MHz signal
    signal Clk25        : std_logic;            -- One pulse width 25 MHz signal
    signal tilePixel    : std_logic_vector(12 downto 0); -- Tile pixel data
    signal tileAddr     : unsigned(11 downto 0); -- Tile address
    signal transparent  : std_logic;
    -- Tile memory type
    type ram_t is array (0 to 8191) of std_logic_vector(7 downto 0);
    -- Sprite memory type
    type ram_s is array (0 to 511) of std_logic_vector(7 downto 0);

    signal tile_memory : ram_t := (others => '0');
    signal sprite_memory : ram_s := (others => '0');

begin
    -- Clock divisor
    -- Divide system clock (100 MHz) by 4
    process(clk)
    begin
        if rising_edge(clk) then
            if rst='1' then
                ClkDiv <= (others => '0');
            else
                ClkDiv <= ClkDiv + 1;
            end if;
        end if;
    end process;
    -- Only set Clk25 on every 4th clk
    Clk25 <= '1' when (ClkDiv = 3) else '0';

    -- ############# XPIXEL ############
    process(clk)
    begin
        if rising_edge(clk) then
            if Clk25 = '1' then
                if Xpixel = 799 then
                    Xpixel <= (others => '0');
                else
                    Xpixel <= Xpixel + 1;
                end if;
            end if;
        end if;
    end process;

    -- ############# Horizontal sync (HSYNC) ############
    Hsync <= '0' when (Xpixel <= 751) and (Xpixel >= 656) else '1';


    -- ############# YPIXEL ############
    process(clk)
    begin
        if rising_edge(clk) then
            if Clk25 = '1' and Xpixel = 799 then
                if Ypixel = 520 then
                    Ypixel <= (others => '0');
                else
                    Ypixel <= Ypixel + 1;
                end if;
            end if;
        end if;
    end  process;

    -- ############# Vertical sync (VSYNC) ############
    Vsync <= '0' when (Ypixel <= 491) and (Ypixel >= 490) else '1';

    -- TODO: Implement transparent pixeling logic


    -- Tile memory
    process(clk)
    begin
        if rising_edge(clk) then
            if (transparent = 0) then
                tilePixel <= tile_memory(to_integer(tileAddr));
            else
                tilePixel <= (others => '0'); -- won't work for multiple layers
            end if;
        end if;
    end process;
           
    -- TODO: finish writing vga
    -- tileAddr, addr


    -- VGA generation
    vgaRed(2) <= tilePixel(7);
    vgaRed(1) <= tilePixel(6);
    vgaRed(0) <= tilePixel(5);
    vgaGreen(2) <= tilePixel(4);
    vgaGreen(1) <= tilePixel(3);
    vgaGreen(0) <= tilePixel(2);
    vgaBlue(2) <= tilePixel(1);
    vgaBlue(1) <= tilePixel(0);

end Behavioral;
