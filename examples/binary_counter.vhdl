library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std_unsigned.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;

  signal cnt : integer range 0 to 15;
  signal run : std_logic;

  alias start is buttons(0);
  alias stop is buttons(1);

begin

  leds <= to_stdulogicvector(cnt, 4);

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        run <= '0';
        cnt <= 0;
      else
        if start = '1' then
          run <= '1';
        elsif stop = '1' then
          run <= '0';
        end if;
        if run = '1' and incr = '1' then
          -- to prevent natural overflow
          if cnt = 15 then
            cnt <= 0;
          else
            cnt <= cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture;
