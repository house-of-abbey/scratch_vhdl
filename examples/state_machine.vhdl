library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;

  signal state : natural range 0 to 7 := 0;

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
        -- Default value.
        leds <= "0000";
        case state is
          when 0 =>
            if buttons(0) = '1' then
              state <= 1;
            end if;

          when 1 =>
            -- Moore - outputs depend only on the state variable.
            leds <= "0001";
            if buttons(1) = '1' then
              state <= 2;
            end if;

          when 2 =>
            if buttons(2) = '1' then
              -- Mealy - outputs depend on both the state variable and the inputs.
              leds <= "0010";
              state <= 3;
            end if;

          when 3 =>
            if buttons(3) = '1' then
              leds <= "0100";
              state <= 4;
            end if;

          when 4 =>
            leds <= "0100";
            if buttons(2) = '1' then
              leds <= "0000";
              state <= 0;
            end if;

          when others =>
            state <= 0;

        end case;
      end if;
    end if;
  end process;

end architecture;
