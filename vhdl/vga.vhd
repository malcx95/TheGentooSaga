library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity vga is
	port (  clk, rst      : in std_logic;
            pictData      : in std_logic_vector(4 downto 0);
            levelAddr     : out unsigned(11 downto 0);
            vgaRed        : out std_logic_vector(2 downto 0);
            vgaGreen      : out std_logic_vector(2 downto 0);
            vgaBlue       : out std_logic_vector(2 downto 1);
            Hsync, Vsync  : out std_logic;

            new_frame     : out std_logic;

            sprite_index : in unsigned(2 downto 0);
            new_sprite_x : in unsigned(8 downto 0);
            new_sprite_y : in unsigned(8 downto 0);
            write_sprite_x : in std_logic;
            write_sprite_y : in std_logic;

            new_scroll_offset : in unsigned(11 downto 0);
            write_scroll_offset : in std_logic
        );
end vga;

architecture Behavioral of vga is

    type sprite_pos_mem is array(0 to 5) of unsigned(8 downto 0);

    component tile_and_sprite_memory
        port (
            clk          : in std_logic;
            addr         : in unsigned(12 downto 0);
            pixel        : out std_logic_vector(7 downto 0);
            sprite_addr : in unsigned(10 downto 0);
            sprite_data : out std_logic_vector(7 downto 0)
            );
    end component;

    component background_memory
        port (
             clk         : in std_logic;
             addr        : in unsigned(12 downto 0);
             pixel       : out std_logic_vector(7 downto 0);
             data_out    : out std_logic_vector(4 downto 0);
             bg_picture_addr : in unsigned(11 downto 0)
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
    signal scroll_offset : unsigned(11 downto 0) := (others => '0');

    -- Sprite signals
    signal sprite_x      : sprite_pos_mem := (others => (others => '0'));
    signal sprite_y      : sprite_pos_mem := (others => (others => '0'));
    signal x_local_sprite1 : unsigned(8 downto 0);
    signal y_local_sprite1 : unsigned(8 downto 0);
    signal x_local_sprite2 : unsigned(8 downto 0);
    signal y_local_sprite2 : unsigned(8 downto 0);
    signal x_local_sprite3 : unsigned(8 downto 0);
    signal y_local_sprite3 : unsigned(8 downto 0);
    signal x_local_sprite4 : unsigned(8 downto 0);
    signal y_local_sprite4 : unsigned(8 downto 0);
    signal x_local_sprite5 : unsigned(8 downto 0);
    signal y_local_sprite5 : unsigned(8 downto 0);
    signal x_local_sprite6 : unsigned(8 downto 0);
    signal y_local_sprite6 : unsigned(8 downto 0);
    signal sprite1_addr  : unsigned(10 downto 0);
    signal sprite2_addr  : unsigned(10 downto 0);
    signal sprite3_addr  : unsigned(10 downto 0);
    signal sprite4_addr  : unsigned(10 downto 0);
    signal sprite5_addr  : unsigned(10 downto 0);
    signal sprite6_addr  : unsigned(10 downto 0);

    -- Signals to tile and sprite memory
    signal tilePixel    : std_logic_vector(7 downto 0); -- Tilepixel data
    signal tileAddr     : unsigned (12 downto 0); -- Tile adress
    signal sprite_addr  : unsigned(10 downto 0);
    signal sprite_data  : std_logic_vector(7 downto 0);
    signal sprite1_on_pixel : std_logic;
    signal sprite2_on_pixel : std_logic;
    signal sprite3_on_pixel : std_logic;
    signal sprite4_on_pixel : std_logic;
    signal sprite5_on_pixel : std_logic;
    signal sprite6_on_pixel : std_logic;
    signal any_sprite_on_pixel : std_logic;

    -- Signals to background_memory
    signal bg_pixel     : std_logic_vector(7 downto 0);
    signal bg_addr      : unsigned(12 downto 0);
    signal bg_pict_addr : unsigned(11 downto 0);
    signal bg_data      : std_logic_vector(4 downto 0);


    signal bigX         : unsigned(8 downto 0);
    signal bigY         : unsigned(8 downto 0);

    signal offsetX      : unsigned(11 downto 0);
    signal half_offsetX : unsigned(10 downto 0);


begin
    -- Clock divisor
    -- Divide system clock (100 MHz) by 4
    process(clk)
    begin
        if rising_edge(clk) then
			ClkDiv <= ClkDiv + 1;
        end if;
    end process;
    -- Only set Clk25 on every 4th clk
    Clk25 <= '1' when (ClkDiv = 1) else '0';

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
    end process;

    -- new_sprite_x
    process(clk, rst)
    begin
        if rst = '1' then
            sprite_x <= (others => (others => '0'));
            sprite_y <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if write_sprite_x = '1' then
                sprite_x(to_integer(sprite_index)) <= new_sprite_x;
            end if;
            if write_sprite_y = '1' then
                sprite_y(to_integer(sprite_index)) <= new_sprite_y;
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            scroll_offset <= x"000";
        elsif rising_edge(clk) then
            if write_scroll_offset = '1' then
                scroll_offset <= new_scroll_offset;
            end if;
        end if;
    end process;

    -- ############# Vertical sync (VSYNC) ############
    Vsync <= '0' when (Ypixel <= 491) and (Ypixel >= 490) else '1';

    new_frame <= '1' when Xpixel = 0 and Ypixel = 0 and clk25 = '1' else '0';

    -- Memory address calculation
    sprite1_addr <= "000" & y_local_sprite1(3 downto 0) & x_local_sprite1(3 downto 0);
    sprite2_addr <= "000" & y_local_sprite2(3 downto 0) & x_local_sprite2(3 downto 0) + 256;
    sprite3_addr <= "000" & y_local_sprite3(3 downto 0) & x_local_sprite3(3 downto 0) + 512;
    sprite4_addr <= "000" & y_local_sprite4(3 downto 0) & x_local_sprite4(3 downto 0) + 768;
    sprite5_addr <= "000" & y_local_sprite5(3 downto 0) & x_local_sprite5(3 downto 0) + 1024;
    sprite6_addr <= "000" & y_local_sprite6(3 downto 0) & x_local_sprite6(3 downto 0) + 1280;

    sprite_addr <= sprite1_addr when sprite1_on_pixel = '1' else
                   sprite2_addr when sprite2_on_pixel = '1' else
                   sprite3_addr when sprite3_on_pixel = '1' else
                   sprite4_addr when sprite4_on_pixel = '1' else
                   sprite5_addr when sprite5_on_pixel = '1' else
                   sprite6_addr when sprite6_on_pixel = '1' else
                   (others => '0');

    levelAddr <= to_unsigned(15, 4) * offsetX(11 downto 4) + bigY(8 downto 4) ;
    tileAddr <= unsigned(pictData) & bigY(3 downto 0) & offsetX(3 downto 0);
    bg_pict_addr <= to_unsigned(15, 5) * half_offsetX(10 downto 4) + bigY(8 downto 4) ;
    bg_addr <= unsigned(bg_data) & bigY(3 downto 0) & half_offsetX(3 downto 0);

    tile_mem : tile_and_sprite_memory port map(clk=>clk, addr=>tileAddr, pixel=>tilePixel,
                                               sprite_addr=>sprite_addr,
                                               sprite_data=>sprite_data);
    background_mem : background_memory port map(clk=>clk, addr=>bg_addr, pixel=>bg_pixel, data_out=>bg_data, bg_picture_addr=>bg_pict_addr);

    bigX <= Xpixel(9 downto 1)+16;
    bigY <= Ypixel(9 downto 1);
    offsetX <= bigX+scroll_offset;
    half_offsetX <= bigX + scroll_offset(11 downto 1);

    x_local_sprite1 <= bigX - sprite_x(0);
    y_local_sprite1 <= bigY - sprite_y(0);
    x_local_sprite2 <= bigX - sprite_x(1);
    y_local_sprite2 <= bigY - sprite_y(1);
    x_local_sprite3 <= bigX - sprite_x(2);
    y_local_sprite3 <= bigY - sprite_y(2);
    x_local_sprite4 <= bigX - sprite_x(3);
    y_local_sprite4 <= bigY - sprite_y(3);
    x_local_sprite5 <= bigX - sprite_x(4);
    y_local_sprite5 <= bigY - sprite_y(4);
    x_local_sprite6 <= bigX - sprite_x(5);
    y_local_sprite6 <= bigY - sprite_y(5);

    sprite1_on_pixel <= '1' when (bigX >= sprite_x(0)) and bigX < (sprite_x(0) + 16) and
                        (bigY >= sprite_y(0)) and bigY < (sprite_y(0) + 16) else '0';
    sprite2_on_pixel <= '1' when (bigX >= sprite_x(1)) and bigX < (sprite_x(1) + 16) and
                        (bigY >= sprite_y(1)) and bigY < (sprite_y(1) + 16) else '0';
    sprite3_on_pixel <= '1' when (bigX >= sprite_x(2)) and bigX < (sprite_x(2) + 16) and
                        (bigY >= sprite_y(2)) and bigY < (sprite_y(2) + 16) else '0';
    sprite4_on_pixel <= '1' when (bigX >= sprite_x(3)) and bigX < (sprite_x(3) + 16) and
                        (bigY >= sprite_y(3)) and bigY < (sprite_y(3) + 16) else '0';
    sprite5_on_pixel <= '1' when (bigX >= sprite_x(4)) and bigX < (sprite_x(4) + 16) and
                        (bigY >= sprite_y(4)) and bigY < (sprite_y(4) + 16) else '0';
    sprite6_on_pixel <= '1' when (bigX >= sprite_x(5)) and bigX < (sprite_x(5) + 16) and
                        (bigY >= sprite_y(5)) and bigY < (sprite_y(5) + 16) else '0';

    any_sprite_on_pixel <= sprite1_on_pixel or sprite2_on_pixel or sprite3_on_pixel or
                           sprite4_on_pixel or sprite5_on_pixel or sprite6_on_pixel;

    current_pixel <= sprite_data when (sprite_data /= transparent and
                                       any_sprite_on_pixel = '1') else
                     tilePixel when (tilePixel /= transparent)
                     else bg_pixel;

    blank <= '1' when ((Ypixel >= 480) or (Xpixel >= 640)) else '0';
    toOut <= current_pixel when (blank = '0') else (others => '0');

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
