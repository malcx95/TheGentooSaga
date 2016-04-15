library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity vga is
	port (  clk, rst     : in std_logic;
            data         : in std_logic_vector(7 downto 0);
		    addr         : out unsigned(11 downto 0);
            vgaRed       : out std_logic_vector(2 downto 0);
            vgaGreen     : out std_logic_vector(2 downto 0);
            vgaBlue      : out std_logic_vector(2 downto 1);
            Hsync, Vsync : out std_logic
            tilePixel    : in std_logic_vector(7 downto 0); -- Tilepixel data
            tileAddr     : out unsigned (13 downto 0); -- Tile adress
        );
end vga;

architecture Behavioral of vga is
    signal Xpixel       : unsigned(9 downto 0) := "0000000000"; -- Horizonatal pixel counter
    signal Ypixel       : unsigned(9 downto 0) := "0000000000"; -- Vertical pixel counter
    signal ClkDiv       : unsigned(1 downto 0); -- Clock divisor, to generate 25 MHz signal
    signal Clk25        : std_logic;            -- One pulse width 25 MHz signal
    signal transparent  : std_logic := '0';


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

    -- Tile memory adress composite
    --tileAddr <= unsigned(data(5 downto 0)) & Ypixel(4 downto 1) & Xpixel(4 downto 1);
    tileAddr <= "000000" & Ypixel(4 downto 1) & Xpixel(4 downto 1);

    -- Picture memory address composite
    addr <=  to_unsigned(20, 7) * Ypixel(8 downto 4) + Xpixel(9 downto 4);

    -- VGA generation
    vgaRed(2)   <= tilePixel(7);
    vgaRed(1)   <= tilePixel(6);
    vgaRed(0)   <= tilePixel(5);
    vgaGreen(2) <= tilePixel(4);
    vgaGreen(1) <= tilePixel(3);
    vgaGreen(0) <= tilePixel(2);
    vgaBlue(2)  <= tilePixel(1);
    vgaBlue(1)  <= tilePixel(0);

end Behavioral;
