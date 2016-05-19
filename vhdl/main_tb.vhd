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
			Vsync           : out std_logic;
			PS2KeyboardData : in std_logic;
			PS2KeyboardClk  : in std_logic;
			rx				: in std_logic;
			uart_switch		: in std_logic;
			Led				: out std_logic_vector(7 downto 0);
			speaker			: out std_logic
            );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal vgaRed : std_logic_vector(2 downto 0);
    signal vgaGreen : std_logic_vector(2 downto 0);
    signal vgaBlue : std_logic_vector(2 downto 1);
    signal Hsync : std_logic;
    signal Vsync : std_logic;
	signal rx : std_logic;
	signal uart_switch : std_logic;
    signal PS2KeyboardData : std_logic;
    signal PS2KeyboardClk : std_logic;
    signal speaker : std_logic;

    constant clk_period : time := 20 ns;
    constant frame_length : time := 8321120 ns;
	constant PS2KeyboardClk_period : time := 2 us;
begin
    uut : main port map (
        clk => clk,
        rst => rst,
        Hsync => Hsync,
        Vsync => Vsync,
        vgaRed => vgaRed,
        vgaGreen => vgaGreen,
        vgaBlue => vgaBlue,
		rx => rx,
		uart_switch => uart_switch,
        PS2KeyboardData => PS2KeyboardData,
        PS2KeyboardClk => PS2KeyboardClk,
		speaker => speaker
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
		rx <= '1';
		uart_switch <= '0';
        rst <= '0';
        wait for clk_period * 5;
        rst <= '1';
        wait for clk_period * 5;
        rst <= '0';
        wait;
    end process;
	
	stim : process is 
		variable data : std_logic_vector(9 downto 0);
	begin
		-- spacebar press
		PS2KeyboardClk <= '1';
		PS2KeyboardData <= '1';
		wait for PS2KeyboardClk_period * 5;
		data := "0100101000";
		for i in data'range loop
			PS2KeyboardData <= data(i);
			wait for PS2KeyboardClk_period / 2;
			PS2KeyboardClk <= '0';
			wait for PS2KeyboardClk_period / 2;
			PS2KeyboardClk <= '1';
		end loop;
		PS2KeyboardData <= '1';
		wait for PS2KeyboardClk_period / 2;
		PS2KeyboardClk <= '0';
		wait for PS2KeyboardClk_period / 2;
		PS2KeyboardClk <= '1';

		-- spacebar release
		wait for PS2KeyboardClk_period * 10;
		data := "0000011110";
		for i in data'range loop
			PS2KeyboardData <= data(i);
			wait for PS2KeyboardClk_period / 2;
			PS2KeyboardClk <= '0';
			wait for PS2KeyboardClk_period / 2;
			PS2KeyboardClk <= '1';
		end loop;
		PS2KeyboardData <= '1';
		wait for PS2KeyboardClk_period / 2;
		PS2KeyboardClk <= '0';
		wait for PS2KeyboardClk_period / 2;
		PS2KeyboardClk <= '1';

		wait for PS2KeyboardClk_period * 5;
		data := "0100101000";
		for i in data'range loop
			PS2KeyboardData <= data(i);
			wait for PS2KeyboardClk_period / 2;
			PS2KeyboardClk <= '0';
			wait for PS2KeyboardClk_period / 2;
			PS2KeyboardClk <= '1';
		end loop;
		PS2KeyboardData <= '1';
		wait for PS2KeyboardClk_period / 2;
		PS2KeyboardClk <= '0';
		wait for PS2KeyboardClk_period / 2;
		PS2KeyboardClk <= '1';

		-- left arrow pressed
		wait for PS2KeyboardClk_period * 10;
		data := "0000001110";
		for i in data'range loop
			PS2KeyboardData <= data(i);
			wait for PS2KeyboardClk_period / 2;
			PS2KeyboardClk <= '0';
			wait for PS2KeyboardClk_period / 2;
			PS2KeyboardClk <= '1';
		end loop;
		PS2KeyboardData <= '1';
		wait for PS2KeyboardClk_period / 2;
		PS2KeyboardClk <= '0';
		wait for PS2KeyboardClk_period / 2;
		PS2KeyboardClk <= '1';

		wait for PS2KeyboardClk_period * 5;
		data := "0110101100";
		for i in data'range loop
			PS2KeyboardData <= data(i);
			wait for PS2KeyboardClk_period / 2;
			PS2KeyboardClk <= '0';
			wait for PS2KeyboardClk_period / 2;
			PS2KeyboardClk <= '1';
		end loop;
		PS2KeyboardData <= '1';
		wait for PS2KeyboardClk_period / 2;
		PS2KeyboardClk <= '0';
		wait for PS2KeyboardClk_period / 2;
		PS2KeyboardClk <= '1';


	end process;
end behaviour;
