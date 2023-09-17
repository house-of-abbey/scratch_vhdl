library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;

  signal button_d : std_logic;


begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        button_d <= '0';
        leds <= "0000";
      else
        if incr = '1' then
          button_d <= buttons(0);
          -- Could use "leds'high-1" as upper bound here
          leds <= leds(2 downto 0) & (buttons(0) and not button_d);
        end if;
      end if;
    end if;
  end process;

end architecture;
