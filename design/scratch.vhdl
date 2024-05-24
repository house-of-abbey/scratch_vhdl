library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 3;

  signal start_r : std_logic := '0';
  signal stop_r : std_logic := '0';
  signal state : natural range 0 to 7 := 0;


begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
      end if;
    end if;
  end process;

end architecture;
