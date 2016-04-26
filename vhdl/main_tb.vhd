library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;    

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
			Led				: out std_logic_vector(7 downto 0);
			JA              : out std_logic_vector(7 downto 0)
            );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal vgaRed : std_logic_vector(2 downto 0);
    signal vgaGreen : std_logic_vector(2 downto 0);
    signal vgaBlue : std_logic_vector(2 downto 1);
    signal Hsync : std_logic;
    signal Vsync : std_logic;
    signal PS2KeyboardData : std_logic;
    signal PS2KeyboardClk : std_logic;
	signal Led : std_logic_vector(7 downto 0);
    signal JA : std_logic_vector(7 downto 0);

    constant clk_period : time := 20 ns;
    constant frame_length : time := 8321120 ns;
	constant ps2_clk_period : time := 10 us;
	constant ps2_data_test : std_logic_vector(20 downto 0) 
	:= "111110001010010111111";
	
	signal data_count : integer := 0;
begin
    uut : main port map (
        clk => clk,
        rst => rst,
        Hsync => Hsync,
        Vsync => Vsync,
        vgaRed => vgaRed,
        vgaGreen => vgaGreen,
        vgaBlue => vgaBlue,
        PS2KeyboardData => PS2KeyboardData,
        PS2KeyboardClk => PS2KeyboardClk,
        JA => JA
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

	stim : process is 
		variable data : std_logic_vector(9 downto 0);
	begin
		-- spacebar press
		PS2KeyboardClk <= '1';
		PS2KeyboardData <= '1';
		wait for ps2_clk_period * 5;
		data := "0100101000";
		for i in data'range loop
			PS2KeyboardData <= data(i);
			wait for ps2_clk_period / 2;
			PS2KeyboardClk <= '0';
			wait for ps2_clk_period / 2;
			PS2KeyboardClk <= '1';
		end loop;
		PS2KeyboardData <= '1';
		wait for ps2_clk_period / 2;
		PS2KeyboardClk <= '0';
		wait for ps2_clk_period / 2;
		PS2KeyboardClk <= '1';

		-- spacebar release
		wait for ps2_clk_period * 10;
		data := "0000011110";
		for i in data'range loop
			PS2KeyboardData <= data(i);
			wait for ps2_clk_period / 2;
			PS2KeyboardClk <= '0';
			wait for ps2_clk_period / 2;
			PS2KeyboardClk <= '1';
		end loop;
		PS2KeyboardData <= '1';
		wait for ps2_clk_period / 2;
		PS2KeyboardClk <= '0';
		wait for ps2_clk_period / 2;
		PS2KeyboardClk <= '1';

		wait for ps2_clk_period * 5;
		data := "0100101000";
		for i in data'range loop
			PS2KeyboardData <= data(i);
			wait for ps2_clk_period / 2;
			PS2KeyboardClk <= '0';
			wait for ps2_clk_period / 2;
			PS2KeyboardClk <= '1';
		end loop;
		PS2KeyboardData <= '1';
		wait for ps2_clk_period / 2;
		PS2KeyboardClk <= '0';
		wait for ps2_clk_period / 2;
		PS2KeyboardClk <= '1';

		-- left arrow pressed
		wait for ps2_clk_period * 10;
		data := "0000001110";
		for i in data'range loop
			PS2KeyboardData <= data(i);
			wait for ps2_clk_period / 2;
			PS2KeyboardClk <= '0';
			wait for ps2_clk_period / 2;
			PS2KeyboardClk <= '1';
		end loop;
		PS2KeyboardData <= '1';
		wait for ps2_clk_period / 2;
		PS2KeyboardClk <= '0';
		wait for ps2_clk_period / 2;
		PS2KeyboardClk <= '1';

		wait for ps2_clk_period * 5;
		data := "0110101100";
		for i in data'range loop
			PS2KeyboardData <= data(i);
			wait for ps2_clk_period / 2;
			PS2KeyboardClk <= '0';
			wait for ps2_clk_period / 2;
			PS2KeyboardClk <= '1';
		end loop;
		PS2KeyboardData <= '1';
		wait for ps2_clk_period / 2;
		PS2KeyboardClk <= '0';
		wait for ps2_clk_period / 2;
		PS2KeyboardClk <= '1';
	end process;

end behaviour;
