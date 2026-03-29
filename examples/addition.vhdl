library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 2;

  signal a : std_logic_vector(1 downto 0) := "00";
  signal b : std_logic_vector(1 downto 0) := "00";
  signal c : std_logic := '0';


begin

  a <= buttons(3 downto 2);

  b <= buttons(1 downto 0);

  c <= a(0) and b(0);

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        -- No carry in
        leds(0) <= a(0) xor b(0);
        leds(1) <= (a(1) xor b(1)) xor c;
        -- Carry out
        leds(2) <= (a(1) and b(1)) or ((a(1) xor b(1)) and c);
        -- Top bit is always zero
        leds(3) <= '0';
      end if;
    end if;
  end process;

end architecture;
