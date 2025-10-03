library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;

  signal state : integer range 0 to 5 := 0;

  alias start is buttons(0);
  alias stop is buttons(1);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state <= 0;
        leds <= "0000";
      else
        if incr = '1' then
          case state is
            when 0 =>
              leds <= "0001";
              state <= 1;

            when 1 =>
              leds <= "0010";
              state <= 2;

            when 2 =>
              leds <= "0100";
              state <= 3;

            when 3 =>
              leds <= "1000";
              state <= 4;

            when 4 =>
              leds <= "0100";
              state <= 5;

            when 5 =>
              leds <= "0010";
              state <= 0;

          end case;
        end if;
      end if;
    end if;
  end process;

end architecture;
