library ieee;
  use ieee.std_logic_1164.all;




architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;

  signal run : std_logic;

  alias start is buttons(0);
  alias stop is buttons(1);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        run <= '0';
        leds <= "1111";
      else
        if start = '1' then
          run <= '1';
        elsif stop = '1' then
          run <= '0';
        end if;
        if run = '1' and incr = '1' then
          leds <= leds(2 downto 0) & '0' xor leds(3) & ("00" & leds(3));
        end if;
      end if;
    end if;
  end process;

end architecture;
