library ieee;
  use ieee.std_logic_1164.all;




architecture scratch of led4_button4 is

  constant button_tab_c : natural := 3;


  alias start is buttons(0);
  alias stop is buttons(1);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state <= 0;
        start_r <= '0';
        stop_r <= '0';
      else
        if start = '1' then
          start_r <= '1';
        end if;
        if stop = '1' then
          stop_r <= '1';
        end if;
        if incr = '1' then
          case state is
            when 0 =>
              leds <= "0001";
              if start_r = '1' then
                start_r <= '0';
                stop_r <= '0';
                state <= 1;
              end if;

            when 1 =>
              leds <= "0010";
              state <= 2;

            when 2 =>
              leds <= "0000";
              state <= 3;

            when 3 =>
              leds <= "0010";
              state <= 4;

            when 4 =>
              leds <= "0000";
              state <= 5;

            when 5 =>
              leds <= "0010";
              state <= 6;

            when 6 =>
              leds <= "0100";
              if stop_r = '1' then
                start_r <= '0';
                stop_r <= '0';
                state <= 7;
              end if;

            when 7 =>
              leds <= "0010";
              state <= 0;

            when others =>
              leds <= "0000";
              state <= 0;

          end case;
        end if;
      end if;
    end if;
  end process;

end architecture;
