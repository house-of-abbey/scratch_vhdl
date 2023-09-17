library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;

  signal run : std_logic;
  signal state : integer range 0 to 5 := 0;

  alias start is buttons(0);
  alias stop is buttons(1);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        run <= '0';
        state <= 0;
        leds <= "0000";
      else
        if start = '1' then
          run <= '1';
        elsif stop = '1' then
          run <= '0';
        end if;
        if run = '1' and incr = '1' then
          if state = 5 then
            state <= 0;
          else
            state <= state + 1;
          end if;
          case state is
            when 0 =>
              leds <= "0001";

            when 1 =>
              leds <= "0010";

            when 2 =>
              leds <= "0100";

            when 3 =>
              leds <= "1000";

            when 4 =>
              leds <= "0100";

            when 5 =>
              leds <= "0010";

          end case;
        end if;
      end if;
    end if;
  end process;

end architecture;
