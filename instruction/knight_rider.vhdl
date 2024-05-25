library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;

  signal state : natural range 0 to 7 := 0;
  signal run : std_logic := '0';

  alias start is buttons(0);
  alias stop is buttons(1);
  alias test is buttons(1);

begin
if start = '1' then
  run <= '1';
end if;
if stop = '1' then
  run <= '0';
end if;
if run = '1' then
end if;


  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        case state is
        end case;
      end if;
    end if;
  end process;
when 0 =>
  leds <= "0001";
  if incr = '1' then
    state <= 1;
  end if;


when 1 =>
  leds <= "0010";
  if incr = '1' then
    state <= 2;
  end if;

when 2 =>
  leds <= "0100";
  if incr = '1' then
    state <= 3;
  end if;

when 3 =>
  leds <= "1000";
  if incr = '1' then
    state <= 4;
  end if;

when 4 =>
  leds <= "0100";
  if incr = '1' then
    state <= 5;
  end if;

when 5 =>
  leds <= "0010";
  if incr = '1' then
    state <= 0;
  end if;

when others =>
  state <= 0;


end architecture;
