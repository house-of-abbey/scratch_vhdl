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

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        case a & b is
          when "0000" =>
            leds <= "0000";

          when "0001" =>
            leds <= "0001";

          when "0010" =>
            leds <= "0010";

          when "0011" =>
            leds <= "0011";

          when "0100" =>
            leds <= "0001";

          when "0101" =>
            leds <= "0010";

          when "0110" =>
            leds <= "0011";

          when "0111" =>
            leds <= "0100";

          when "1000" =>
            leds <= "0010";

          when "1001" =>
            leds <= "0011";

          when "1010" =>
            leds <= "0100";

          when "1011" =>
            leds <= "0101";

          when "1100" =>
            leds <= "0011";

          when "1101" =>
            leds <= "0100";

          when "1110" =>
            leds <= "0101";

          when "1111" =>
            leds <= "0110";

        end case;
      end if;
    end if;
  end process;

end architecture;
