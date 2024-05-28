library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 0;

  signal btn0_r : std_logic := '0';
  signal shift : std_logic := '0';


begin

  shift <= buttons(0) and not btn0_r;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
        btn0_r <= '0';
      else
        btn0_r <= buttons(0);
        if shift = '1' then
          leds <= (not leds(0)) & leds(3 downto 1);
        end if;
      end if;
    end if;
  end process;

end architecture;
