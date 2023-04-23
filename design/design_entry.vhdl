library ieee;
use ieee.std_logic_1164.all;

architecture scratch of led4_button4 is

  2CONSTANT button_tab_c : natural := 3;

  2SIGNAL start_r : std_logic;
  2SIGNAL stop_r  : std_logic;
  2SIGNAL state   : natural range 0 to 7;

  2ALIAS start is buttons(0);
  2ALIAS stop is buttons(1);

begin

  2PROCESS (clk)
  2BEGIN
  2  2IF rising_edge(clk) then
  2  2  2IF reset = '1' then
  2  2  2  2leds <= "0000";
  2  2  2ELSE
  2  2  2  2leds <= buttons;
  2  2  2END if;
  2  2END if;
  2END process;

end architecture;
