library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 3;

  signal start_r : std_logic;
  signal stop_r : std_logic;
  signal state : natural range 0 to 7;

  alias start is buttons(0);
  alias stop is buttons(1);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        start_r <= '0';
        stop_r <= '0';
        state <= 0;
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
              state <= 1;

            when 1 =>
              if start_r = '1' then
                leds <= "0011";
                state <= 2;
                start_r <= '0';
                stop_r <= '0';
              end if;

            when 2 =>
              leds <= "0100";
              state <= 3;

            when 3 =>
              if stop_r = '1' then
                leds <= "0010";
                state <= 4;
                start_r <= '0';
                stop_r <= '0';
              end if;

            when 4 =>
              leds <= "1001";
              state <= 5;

            when 5 =>
              if start_r = '1' then
                leds <= "0011";
                state <= 6;
                start_r <= '0';
                stop_r <= '0';
              end if;

            when 6 =>
              leds <= "0100";
              state <= 7;

            when 7 =>
              if stop_r = '1' then
                leds <= "0010";
                state <= 0;
                start_r <= '0';
                stop_r <= '0';
              end if;

            when others =>
              leds <= "0000";

          end case;
        end if;
      end if;
    end if;
  end process;

end architecture;
