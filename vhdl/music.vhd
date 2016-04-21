library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity music is
    port (
        clk : in std_logic;
        data : in unsigned(7 downto 0);
        addr : buffer unsigned(6 downto 0);
        audio_out : buffer std_logic
        );
end music;

architecture behaviour of music is
    signal get_next_note : std_logic;
    signal length_counter : unsigned(27 downto 0);
    signal pulse_counter : unsigned(23 downto 0);

    alias note_length : unsigned(1 downto 0) is data(7 downto 6);
    alias note_pitch : unsigned(5 downto 0) is data(5 downto 0);

    type freq_t is array(0 to 63) of unsigned(23 downto 0);
    signal freq_mem : freq_t := (
      x"175447", x"160514", x"14C8B1", x"139E11", x"128433",
      x"117A27", x"107F09", x"0F9204", x"0EB24C", x"0DDF23",
      x"0D17D4", x"0C5BB4", x"0BAA23", x"0B028A", x"0A6459",
      x"09CF08", x"094219", x"08BD13", x"083F85", x"07C902",
      x"075926", x"06EF91", x"068BEA", x"062DDA", x"05D512",
      x"058145", x"05322C", x"04E784", x"04A10D", x"045E8A",
      x"041FC2", x"03E481", x"03AC93", x"0377C9", x"0345F5",
      x"0316ED", x"02EA89", x"02C0A2", x"029916", x"0273C2",
      x"025086", x"022F45", x"020FE1", x"01F241", x"01D64A",
      x"01BBE4", x"01A2FA", x"018B76", x"017544", x"016051",
      x"014C8B", x"0139E1", x"012843", x"0117A2", x"0107F1",
      x"00F920", x"00EB25", x"00DDF2", x"00D17D", x"00C5BB",
      x"00BAA2", x"00B029", x"00A646", x"009CF1");
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if get_next_note = '1' then
                addr <= addr + 1;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if length_counter = 0 then
                -- Shortest note is 0.1 seconds
                if note_length = "11" then
                    length_counter <= x"4C4B400";
                elsif note_length = "10" then
                    length_counter <= x"2625A00";
                elsif note_length = "01" then
                    length_counter <= x"1312D00";
                else
                    length_counter <= x"0989680";
                end if;
            else
                length_counter <= length_counter - 1;
            end if;
        end if;
    end process;

    -- Prepare for loading new note, get the next one
    get_next_note <= '1' when length_counter = 1 else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            if pulse_counter = 0 then
                pulse_counter <= freq_mem(to_integer(note_pitch));
                audio_out <= not audio_out;
            else
                pulse_counter <= pulse_counter - 1;
            end if;
        end if;
    end process;

end behaviour;
