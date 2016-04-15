library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb is
end tb;

architecture behaviour of tb is
    component vga
        port (clk, rst : in std_logic;
                Hsync, Vsync : out std_logic;
                data : in std_logic_vector(7 downto 0);
                addr : out unsigned(11 downto 0);
                vgaRed, vgaGreen : out std_logic_vector(2 downto 0);
                vgaBlue : out std_logic_vector(2 downto 1));
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal Hsync : std_logic := '0';
    signal Vsync : std_logic := '0';
    signal data : std_logic_vector(7 downto 0);
    signal addr : unsigned(11 downto 0);
    signal vgaRed : std_logic_vector(2 downto 0);
    signal vgaGreen : std_logic_vector(2 downto 0);
    signal vgaBlue : std_logic_vector(2 downto 1);

    constant clk_period : time := 20 ns;
    constant frame_length : time := 8321120 ns;
begin
    uut : vga port map (
        clk => clk,
        rst => rst,
        Hsync => Hsync,
        Vsync => Vsync,
        data => data,
        addr => addr,
        vgaRed => vgaRed,
        vgaGreen => vgaGreen,
        vgaBlue => vgaBlue
        );

        clk_process : process
        begin
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end process;
        
        rst_process : process
        begin
          wait for clk_period * 5;
          rst <= '1';
          wait for clk_period * 5;
          rst <= '0';
          wait;
        end process;
            
    process(clk)
        file file_pointer : text is out "/edu/robsl733/write.txt";
        variable line_el : line;
    begin
        if rising_edge(clk) then
            -- Write the time
            write(line_el, now); -- write the line
            write(line_el, string'(":")); -- write the line

            -- write hsync
            write(line_el, string'(" "));
            write(line_el, hsync); -- write the line

            -- write vhsync
            write(line_el, string'(" "));
            write(line_el, vsync); -- write the line

            -- write red
            write(line_el, string'(" "));
            write(line_el, vgaRed); -- write the line

            -- write green
            write(line_el, string'(" "));
            write(line_el, vgaGreen); -- write the line

            -- write blue
            write(line_el, string'(" "));
            write(line_el, vgablue); -- write the line
            
            writeline(file_pointer, line_el); -- write the contents into the file

        end if;
    end process;
end architecture;
