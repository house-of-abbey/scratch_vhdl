library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 3;

  signal start_r : std_logic := '0';
  signal stop_r : std_logic := '0';
  signal state : natural range 0 to 7 := 0;
  signal dir : std_logic := '0';

  alias start is buttons(0);
  alias stop is buttons(1);

begin
-- Solution contributed by A. Sutton.

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0001";
        dir <= '1';
      else
        if incr = '1' then
          if leds(1) = '1' and dir = '0' then
            dir <= '1';
          elsif leds(2) = '1' and dir = '1' then
            dir <= '0';
          end if;
          if dir = '0' then
            leds <= '0' & leds(3 downto 1);
          elsif dir = '1' then
            leds <= leds(2 downto 0) & '0';
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture;
