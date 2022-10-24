library ieee;
  use ieee.std_logic_1164.all;

entity pulse_gen is
  port(
    clk : in std_logic;
    reset : in std_logic;
    incr : in std_logic;
    buttons : in std_logic_vector(3 downto 0);
    leds : out std_logic_vector(3 downto 0)
  );
end entity;


architecture scratch of pulse_gen is

  constant button_tab_c : positive := 1;

  signal buttons_d : std_logic_vector(3 downto 0);


begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
        buttons_d <= "0000";
      else
        if incr = '1' then
          buttons_d <= buttons;
          leds <= buttons and not buttons_d;
        end if;
      end if;
    end if;
  end process;

end architecture;
