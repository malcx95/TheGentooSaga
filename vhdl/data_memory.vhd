library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_memory is
    port (clk : in std_logic
          address : in std_logic_vector(15 downto 0);
          chip_enable : in std_logic;
          read_write : in std_logic;
          data : inout std_logic_vector(31 downto 0));
end data_memory;

architecture Behavioral of data_memory is

    -- memory consists of 512 32-bit words
    type ram_t is array (0 to 512) of
        std_logic_vector(31 downto 0);

    signal ram : ram_t := (others => (others => '0'));

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (chip_enable = '1') then
                if (read_write = '1') then
                    -- If the address is inside memory, write to the specified
                    -- position
                    if (address < 512) then
                        ram(conv_integer(addres)) <= data;
                    end if;
                    -- TODO: implement memory mapped I/O
                else
                    if (address < 512) then
                        data <= ram(conv_integer(address));
                    else
                        data <= (others => '0');
                        -- TODO: implement memory mapped I/O
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;

