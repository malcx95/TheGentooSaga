library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity main_tb is
end main_tb;

architecture behaviour of main_tb is
    component main is
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            vgaRed          : out std_logic_vector(2 downto 0);
            vgaGreen        : out std_logic_vector(2 downto 0);
            vgaBlue         : out std_logic_vector(2 downto 1);
            Hsync           : out std_logic;
            Vsync           : out std_logic
            --PS2KeyboardData : in std_logic;
            --PS2KeyboardClk  : in std_logic;
            --JA              : out std_logic
            );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal vgaRed : std_logic_vector(2 downto 0);
    signal vgaGreen : std_logic_vector(2 downto 0);
    signal vgaBlue : std_logic_vector(2 downto 1);
    signal Hsync : std_logic;
    signal Vsync : std_logic;

    constant clk_period : time := 20 ns;
    constant frame_length : time := 8321120 ns;
begin
    uut : main port map (
        clk => clk,
        rst => rst,
        Hsync => Hsync,
        Vsync => Vsync,
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
        rst <= '0';
        wait for clk_period * 5;
        rst <= '1';
        wait for clk_period * 5;
        rst <= '0';
        wait;
    end process;
end behaviour;
