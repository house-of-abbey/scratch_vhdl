library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 2;

  signal buttons_d : std_logic;


begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
        buttons_d <= '0';
      else
        buttons_d <= buttons(0);
        if incr = '1' then
          if buttons(0) = '1' and buttons_d = '0' then
            leds(0) <= '1';
          else
            leds(0) <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture;
