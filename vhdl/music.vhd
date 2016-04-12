library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity music is
    port (
        clk : in std_logic;
        data : in std_logic_vector(7 downto 0);
        addr : out std_logic_vector(6 downto 0);
        audio_out : buffer std_logic
        );
end music;

architecture behaviour of music is
    signal get_next_note : std_logic;
    signal current_note : std_logic_vector(7 downto 0);
    signal length_counter : std_logic_vector; -- TODO choose size
    signal pulse_counter : std_logic_vector; -- TODO choose size

    -- One bit of data is unused
    alias note_length : std_logic_vector(1 downto 0) is current_note(6 downto 5);
    alias note_pitch : std_logic_vector(4 downto 0) is current_note(4 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if get_next_note = '1' then
                addr = addr + 1;
            end if;

            current_note <= data;
        end if;
    end process;

    get_next_note = '1' when note_length_counter = 0 else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            if pulse_counter = '0' then
                pulse_counter <= freq_mem(to_integer(note_pitch));
                audio_out <= not audio_out;
            else
                pulse_counter <= pulse_counter + 1;
            end if;
        end if;
    end process;

end behaviour;
