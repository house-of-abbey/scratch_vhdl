library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 3;

  signal start_r : std_logic := '0';
  signal stop_r : std_logic := '0';
  signal reg : std_logic_vector(5 downto 0) := "000000";

  alias start is buttons(0);
  alias stop is buttons(1);

begin
-- Solution contributed by A. Sutton.

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "1000";
        reg <= "100000";
      else
        if incr = '1' then
          reg <= reg(0) & reg(5 downto 1);
        end if;
        leds(3) <= reg(5);
        leds(2) <= reg(4) or reg(0);
        leds(1) <= reg(3) or reg(1);
        leds(0) <= reg(2);
      end if;
    end if;
  end process;

end architecture;
