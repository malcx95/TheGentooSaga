library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type

entity colors is
  port ( clk			: in std_logic;
	 rst			: in std_logic;
	 vgaRed		        : out std_logic_vector(2 downto 0);
	 vgaGreen	        : out std_logic_vector(2 downto 0);
	 vgaBlue		: out std_logic_vector(2 downto 1);
	 Hsync		        : out std_logic;
	 Vsync		        : out std_logic);
end colors;

-- architecture
architecture Behavioral of colors is
  signal	Xpixel	        : unsigned(9 downto 0);         -- Horizontal pixel counter
  signal	Ypixel	        : unsigned(9 downto 0);		-- Vertical pixel counter
  signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	Clk25		: std_logic;			-- One pulse width 25 MHz signal

  signal 	tilePixel       : std_logic_vector(7 downto 0);	-- Tile pixel data
  signal addr : unsigned(10 downto 0);

  signal        blank           : std_logic;                    -- blanking signal
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

  -- 25 MHz clock (one system clock pulse width)
  Clk25 <= '1' when (ClkDiv = 3) else '0';

  -- Horizontal pixel counter
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

  -- Horizontal sync
    Hsync <= '0' when (Xpixel <= 751) and (Xpixel >= 655) else '1';

  -- Vertical pixel counter
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


  -- Vertical sync
    Vsync <= '0' when (Ypixel <= 491) and (Ypixel >= 489) else '1';

  -- Video blanking signal
  blank <= '0' when (Xpixel <= 639) and (Ypixel <= 479) else '1';

  -- Tile memory
  process(clk)
  begin
    if rising_edge(clk) then
      if (blank = '0') then
        tilePixel <= std_logic_vector(addr(7 downto 0));
      else
        tilePixel <= (others => '0');
      end if;
    end if;
  end process;
  -- Picture memory address composite
  addr <= to_unsigned(20, 7) * Ypixel(8 downto 5) + Xpixel(9 downto 5);

  -- VGA generation
  vgaRed(2) 	<= tilePixel(7);
  vgaRed(1) 	<= tilePixel(6);
  vgaRed(0) 	<= tilePixel(5);
  vgaGreen(2)   <= tilePixel(4);
  vgaGreen(1)   <= tilePixel(3);
  vgaGreen(0)   <= tilePixel(2);
  vgaBlue(2) 	<= tilePixel(1);
  vgaBlue(1) 	<= tilePixel(0);

end Behavioral;

