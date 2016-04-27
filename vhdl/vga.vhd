library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity vga is
	port (  clk, rst     : in std_logic;
            pictData     : in std_logic_vector(4 downto 0);
            pictAddr     : out unsigned(11 downto 0);
            vgaRed       : out std_logic_vector(2 downto 0);
            vgaGreen     : out std_logic_vector(2 downto 0);
            vgaBlue      : out std_logic_vector(2 downto 1);
            Hsync, Vsync : out std_logic
        );
end vga;

architecture Behavioral of vga is

    component tile_and_sprite_memory
        port (
            clk          : in std_logic;
            addr         : in unsigned(12 downto 0);
            pixel        : out std_logic_vector(7 downto 0);
            sprite1_addr : in unsigned(7 downto 0);
            sprite1_data : out std_logic_vector(7 downto 0)
            );
    end component;

    signal Xpixel        : unsigned(9 downto 0) := "0000000000"; 
    signal Ypixel        : unsigned(9 downto 0) := "0000000000"; 
    signal ClkDiv        : unsigned(1 downto 0); -- Clock divisor, to generate 25 MHz signal
    signal Clk25         : std_logic;            -- One pulse width 25 MHz signal
    signal blank         : std_logic := '0';
    signal toOut         : std_logic_vector(7 downto 0);
    signal current_pixel : std_logic_vector(7 downto 0);
    constant transparent : std_logic_vector(7 downto 0) := x"e0";
    -- Sprite 1 signals
    signal sprite1_x    : unsigned(9 downto 0) := "0000000000";
    signal sprite1_y    : unsigned(9 downto 0) := "0000000000";
    signal P1x           : unsigned(9 downto 0);
    signal P1y           : unsigned(9 downto 0);

    -- Signals to tile and sprite memory
    signal tilePixel    : std_logic_vector(7 downto 0); -- Tilepixel data
    signal tileAddr     : unsigned (12 downto 0); -- Tile adress
    signal sprite1_addr : unsigned(7 downto 0);
    signal sprite1_data : std_logic_vector(7 downto 0);
    signal sprite1_on_pixel : std_logic;

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
                    sprite1_x <= sprite1_x + 1;
                    sprite1_y <= sprite1_y + 1;
                    Ypixel <= (others => '0');
                else
                    Ypixel <= Ypixel + 1;
                end if;
            end if;
        end if;
    end  process;

    -- ############# Vertical sync (VSYNC) ############
    Vsync <= '0' when (Ypixel <= 491) and (Ypixel >= 490) else '1';

    -- Tile memory adress composite
    tileAddr <= unsigned(pictData) & Ypixel(4 downto 1) & Xpixel(4 downto 1);
    tile_mem : tile_and_sprite_memory port map(clk=>clk, addr=>tileAddr, pixel=>tilePixel,
                                               sprite1_addr=>sprite1_addr, sprite1_data=>sprite1_data);

    P1x <= Xpixel-sprite1_x;
    P1y <= Ypixel-sprite1_y;

    sprite1_on_pixel <= '1' when (Xpixel >= sprite1_x and Xpixel <= (sprite1_x + 32)) and
(Ypixel >= sprite1_y and Ypixel <= (sprite1_y + 32)) else '0';

    sprite1_addr <= P1y(4 downto 1) & P1x(4 downto 1); 

    -- Picture memory address composite
    pictAddr <=  to_unsigned(20, 8) * Ypixel(8 downto 5) + Xpixel(9 downto 5);

    blank <= '1' when ((Ypixel >= 480) or (Xpixel >= 640)) else '0';
    
    current_pixel <= sprite1_data when (sprite1_data /= transparent and
                                        sprite1_on_pixel = '1') else tilePixel;
    toOut <= current_pixel when (blank = '0') else (others => '0');
    --toOut <= tilePixel when (blank = '0') else (others => '0');



    -- VGA generation
    vgaRed(2)   <= toOut(7);
    vgaRed(1)   <= toOut(6);
    vgaRed(0)   <= toOut(5);
    vgaGreen(2) <= toOut(4);
    vgaGreen(1) <= toOut(3);
    vgaGreen(0) <= toOut(2);
    vgaBlue(2)  <= toOut(1);
    vgaBlue(1)  <= toOut(0);

end Behavioral;
