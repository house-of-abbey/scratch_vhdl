-------------------------------------------------------------------------------------
--
-- Distributed under MIT Licence
--   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
--
-------------------------------------------------------------------------------------
--
-- IO for the Standard 4 button input 4 LED output entity, including synchronisers
-- for the buttons. The four switches and buttons are OR'ed together respectively,
-- so ensure the switches are off when using the buttons.
--
-- J D Abbey & P A Abbey, 20 October 2022
--
-------------------------------------------------------------------------------------

entity test_zybo_z7_10 is
end entity;


library ieee;
  use ieee.std_logic_1164.all;
library std;
library local;
  use local.testbench_pkg.all;

architecture test of test_zybo_z7_10 is

  signal clk  : std_logic                    := '0';
  signal sw   : std_logic_vector(3 downto 0) := "0000";
  signal btn  : std_logic_vector(3 downto 0) := "0000";
  signal leds : std_logic_vector(3 downto 0) := "0000";

begin

  clkgen : clock(clk, 8 ns);

  dut : entity work.zybo_z7_10
    port map (
      clk_port => clk,
      sw       => sw,
      btn      => btn,
      leds     => leds
    );

  process
  begin
    sw  <= "0000";
    btn <= "0000";
    wait_nr_ticks(clk, 10);

    sw  <= "1010";
    wait_nr_ticks(clk, 400);
    btn <= "0101";
    wait_nr_ticks(clk, 400);

    sw  <= "0000";
    btn <= "0000";
    wait_nr_ticks(clk, 400);

    wait_nr_ticks(clk, 500);

    --stop_clocks;
    -- PLL IP Core won't stop creating events, must use 'stop' instead of 'stop_clocks'.
    std.env.stop;
    wait;
  end process;

end architecture;
