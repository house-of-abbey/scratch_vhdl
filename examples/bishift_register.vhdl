library ieee;
  use ieee.std_logic_1164.all;




architecture scratch of led4_button4 is

  constant button_tab_c : natural := 1;

  signal dir_lr_d : std_logic;
  signal dir_rl_d : std_logic;
  signal dir_lr_p : std_logic;
  signal dir_rl_p : std_logic;
  signal rl : std_logic;

  alias dir_rl is buttons(0);
  alias dir_lr is buttons(3);

begin

  dir_rl_p <= dir_rl and not dir_rl_d;

  dir_lr_p <= dir_lr and not dir_lr_d;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        dir_rl_d <= '0';
        dir_rl_d <= '0';
        rl <= '0';
        leds <= "0000";
      else
        if incr = '1' then
          dir_rl_d <= buttons(0);
          dir_lr_d <= buttons(3);
          if dir_rl = '1' and dir_rl_d = '0' then
            rl <= '1';
          elsif dir_lr = '1' and dir_lr_d = '0' then
            rl <= '0';
          end if;
          -- Separating the parts out we get the basic shift action,
          -- followed by what to do to poke a '1' in either end of
          -- the shift register.
          if rl = '1' then
            -- Could use "leds'high-1" as the upper bound here
            leds <= leds(2 downto 0) & '0';
          else
            leds <= dir_lr_p & leds(3 downto 1);
          end if;
          -- Assignments in the above 'if' clause are overwritten by any
          -- that might follow. NB. The tests for both direction pulses are
          -- necessary because and 'if' statement has a priority encoding.
          -- The additional tests ensure exclusivity.
          if dir_rl_p = '1' and dir_lr_p = '0' then
            leds <= leds(2 downto 0) & '1';
          elsif dir_lr_p = '1' and dir_rl_p = '0' then
            leds <= '1' & leds(3 downto 1);
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture;
