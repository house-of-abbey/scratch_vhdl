library ieee;
  use ieee.std_logic_1164.all;


architecture risc_cpu of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 2;

begin

  cpu_i : entity work.risc_cpu
    port map (
      clk     => clk,
      reset   => reset,
      i       => buttons,
      o       => leds
    );

end architecture;
