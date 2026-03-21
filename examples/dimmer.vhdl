library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;

  signal state : natural range 0 to 4 := 0;

  alias start is buttons(0);
  alias stop is buttons(1);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
        state <= 0;
      else
        if incr = '1' then
          case state is
            when 0 =>
              leds <= "0000";
              if buttons(0) = '1' then
                state <= 1;
              end if;

            when 1 =>
              leds <= "1000";
              if buttons(0) = '1' then
                state <= 2;
              elsif buttons(3) = '1' then
                state <= 0;
              end if;
              when 2 =>
                leds <= "1100";
                if buttons(0) = '1' then
                  state <= 3;
                elsif buttons(3) = '1' then
                  state <= 1;
                end if;
                when 3 =>
                  leds <= "1110";
                  if buttons(0) = '1' then
                    state <= 4;
                  elsif buttons(3) = '1' then
                    state <= 2;
                  end if;

                when 4 =>
                  leds <= "1111";
                  if buttons(3) = '1' then
                    state <= 3;
                  end if;



          end case;
        end if;
      end if;
    end if;
  end process;

end architecture;
