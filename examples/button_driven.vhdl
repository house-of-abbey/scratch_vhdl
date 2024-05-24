library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;



begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        -- If any buttons are pressed, set leds to buttons.
        if or(buttons) then
          leds <= buttons;
        end if;
      end if;
    end if;
  end process;

end architecture;
