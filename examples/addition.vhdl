library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 2;

  signal start_r : std_logic := '0';
  signal stop_r : std_logic := '0';
  signal state : natural range 0 to 7 := 0;
  signal buttons_d : std_logic_vector(3 downto 0);

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
        leds(2) <= ((buttons(0) and buttons(2)) and buttons(1)) or (((buttons(0) and buttons(2)) and buttons(3)) or (buttons(3) and buttons(1)));
      end if;
    end if;
  end process;

end architecture;
