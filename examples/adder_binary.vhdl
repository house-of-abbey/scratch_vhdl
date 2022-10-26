library ieee;
  use ieee.std_logic_1164.all;

entity adder_binary is
  port(
    clk : in std_logic;
    reset : in std_logic;
    incr : in std_logic;
    buttons : in std_logic_vector(3 downto 0);
    leds : out std_logic_vector(3 downto 0)
  );
end entity;


architecture scratch of adder_binary is

  constant button_tab_c : positive := 2;



begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        case buttons is
          when "0000" =>
            leds <= "0000";

          when "0001" | "0010" | "0100" | "1000" =>
            leds <= "0001";

          when "0011" | "0101" | "0110" | "1010" | "1100" | "1001" =>
            leds <= "0010";

          when "0111" | "1011" | "1101" | "111" =>
            leds <= "0011";

          when "1111" =>
            leds <= "0100";

          -- Cover the other bit values: 'U', 'X', 'Z', 'W', 'L' & 'H'
          when others =>
            leds <= "1111";


        end case;end if;
    end if;
  end process;

end architecture;
