library ieee;
  use ieee.std_logic_1164.all;

entity button_driven is
  port(
    clk : in std_logic;
    reset : in std_logic;
    incr : in std_logic;
    buttons : in std_logic_vector(3 downto 0);
    leds : out std_logic_vector(3 downto 0)
  );
end entity;


architecture scratch of button_driven is

  constant button_tab_c : natural := 1;



begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        -- If any buttons are pressed, set leds to buttons.
        if or(buttons) then
          leds <= buttons;
        end if;
      end if;
    end if;
  end process;

end architecture;
