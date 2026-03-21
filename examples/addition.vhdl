library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 2;


  alias start is buttons(0);
  alias stop is buttons(1);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        leds(0) <= buttons(0) xor buttons(2);
        leds(1) <= (buttons(0) and buttons(2)) xor (buttons(1) xor buttons(3));
        -- One of the XOR and OR logic gates can be interchanged.
        leds(2) <= (buttons(3) and buttons(1)) or ((buttons(3) or buttons(1)) and (buttons(2) and buttons(0)));
      end if;
    end if;
  end process;

end architecture;
