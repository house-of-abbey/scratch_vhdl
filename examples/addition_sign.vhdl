library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;

  signal a : unsigned(2 downto 0) := "000";
  signal b : unsigned(2 downto 0) := "000";
  signal sum : unsigned(2 downto 0) := "000";


begin

  a <= unsigned('0' & buttons(3 downto 2));

  b <= unsigned('0' & buttons(1 downto 0));

  sum <= a + b;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        leds <= '0' & ieee.std_logic_1164.std_logic_vector(sum);
      end if;
    end if;
  end process;

end architecture;
