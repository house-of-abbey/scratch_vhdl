-------------------------------------------------------------------------------------
--
-- Distributed under MIT Licence
--   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
--
-------------------------------------------------------------------------------------
--
-- Generic test bench to be used by all the various different architectures
-- implementing functions on 4 LEDs and 4 buttons.
--
-- J D Abbey & P A Abbey, 14 October 2022
--
-------------------------------------------------------------------------------------

entity test_led4_button4 is
end entity;


library ieee;
  use ieee.std_logic_1164.all;
library local;
  use local.testbench_pkg.all;

architecture test of test_led4_button4 is

  signal clk     : std_logic := '0';
  signal reset   : std_logic := '0';
  signal incr    : std_logic := '0';
  signal buttons : std_logic_vector(3 downto 0) := "0000";
  signal leds    : std_logic_vector(3 downto 0);

  -- Component declarations must be used when configurations are also used.
  component led4_button4 is
    port(
      clk     : in  std_logic;
      reset   : in  std_logic;
      incr    : in  std_logic;
      buttons : in  std_logic_vector(3 downto 0);
      leds    : out std_logic_vector(3 downto 0)
    );
  end component;

  component stimulus_led4_button4 is
    port(
      clk     : in  std_logic;
      reset   : out std_logic;
      buttons : out std_logic_vector(3 downto 0)
    );
  end component;

begin

  clkgen : clock(clk, 8 ns);

  incr_pulse : process
  begin
    incr <= '0';
    wait_nr_ticks(clk, 10);
    while true loop
      incr <= '1';
      wait_nr_ticks(clk, 1);
      incr <= '0';
      wait_nr_ticks(clk, 9);
    end loop;

    -- Keep the compiler quiet
    wait;
  end process;

  led4_button4_i : led4_button4
    port map (
      clk     => clk,
      reset   => reset,
      incr    => incr,
      buttons => buttons,
      leds    => leds
    );

  stimulus_led4_button4_i : stimulus_led4_button4
    port map (
      clk     => clk,
      reset   => reset,
      buttons => buttons
    );

end architecture;
