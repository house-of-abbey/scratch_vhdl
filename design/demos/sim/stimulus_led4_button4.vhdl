-------------------------------------------------------------------------------------
--
-- Distributed under MIT Licence
--   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
--
-------------------------------------------------------------------------------------
--
-- Test stimuli for the various different architectures implementing functions on 4
-- LEDs and 4 buttons. Configurations are used to stitch the correct test stimulus
-- for a given RTL architecture.
--
-- J D Abbey & P A Abbey, 14 October 2022
--
-------------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

entity stimulus_led4_button4 is
  port(
    clk     : in  std_logic;
    incr    : in  std_logic;
    reset   : out std_logic;
    buttons : out std_logic_vector(3 downto 0) := "0000"
  );
end entity;


library local;
  use local.testbench_pkg.all;

architecture button_driven of stimulus_led4_button4 is
begin

  stimulus : process
  begin
    reset   <= '1';
    buttons <= "0000";
    wait_nr_ticks(clk, 2);
    reset   <= '0';

    wait_nr_ticks(clk, 10);
    for i in buttons'range loop
      buttons(i) <= '1';
      wait_nr_ticks(clk, 1);
      buttons(i) <= '0';
      wait_nr_ticks(clk, 9);
    end loop;
    buttons(2) <= '1';
    wait_nr_ticks(clk, 1);
    buttons(2) <= '0';
    wait_nr_ticks(clk, 9);
    for i in buttons'reverse_range loop
      buttons(i) <= '1';
      wait_nr_ticks(clk, 1);
      buttons(i) <= '0';
      wait_nr_ticks(clk, 9);
    end loop;
    wait_nr_ticks(clk, 10);

    stop_clocks;
    wait;
  end process;

end architecture;

configuration test_button_driven of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(button_driven);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(button_driven);
    end for;

  end for;
end configuration;


library local;
  use local.testbench_pkg.all;

architecture logic_gates of stimulus_led4_button4 is
begin

  stimulus : process
  begin
    reset   <= '1';
    buttons <= "0000";
    wait_nr_ticks(clk, 2);
    reset   <= '0';

    wait_nr_ticks(clk, 10);
    buttons <= "0001";
    wait_nr_ticks(clk, 10);
    buttons <= "0011";
    wait_nr_ticks(clk, 10);
    buttons <= "0111";
    wait_nr_ticks(clk, 10);
    buttons <= "1111";
    wait_nr_ticks(clk, 10);
    buttons <= "1110";
    wait_nr_ticks(clk, 10);
    buttons <= "1100";
    wait_nr_ticks(clk, 10);
    buttons <= "1000";
    wait_nr_ticks(clk, 10);
    buttons <= "0000";
    wait_nr_ticks(clk, 10);

    stop_clocks;
    wait;
  end process;

end architecture;

configuration test_logic_gates of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(logic_gates);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(logic_gates);
    end for;

  end for;
end configuration;


library local;
  use local.testbench_pkg.all;

architecture shift_register of stimulus_led4_button4 is
begin

  stimulus : process
  begin
    reset   <= '1';
    buttons <= "0000";
    wait_nr_ticks(clk, 2);
    reset   <= '0';

    wait_nr_ticks(clk, 10);
    buttons(0) <= '1';
    wait_nr_ticks(clk, 10);
    buttons(0) <= '0';
    wait_nr_ticks(clk, 20);
    buttons(0) <= '1';
    wait_nr_ticks(clk, 10);
    buttons(0) <= '0';
    wait_nr_ticks(clk, 10);
    buttons(0) <= '1';
    wait_nr_ticks(clk, 20);
    buttons(0) <= '0';
    wait_nr_ticks(clk, 50);

    stop_clocks;
    wait;
  end process;

end architecture;

configuration test_shift_register of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(shift_register);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(shift_register);
    end for;

  end for;
end configuration;


library local;
  use local.testbench_pkg.all;

architecture binary_counter of stimulus_led4_button4 is

  alias start is buttons(0);
  alias stop  is buttons(1);

begin

  stimulus : process
  begin
    reset <= '1';
    start <= '0';
    stop  <= '0';
    wait_nr_ticks(clk, 2);
    reset <= '0';

    wait_nr_ticks(clk, 20);
    toggle_r(start, clk, 1);
    wait_nr_ticks(clk, 200);
    toggle_r(stop, clk, 1);
    wait_nr_ticks(clk, 100);
    toggle_r(start, clk, 1);
    wait_nr_ticks(clk, 50);
    toggle_r(stop, clk, 1);
    wait_nr_ticks(clk, 20);

    stop_clocks;
    wait;
  end process;

end architecture;

configuration test_binary_counter of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(binary_counter);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(binary_counter);
    end for;

  end for;
end configuration;


library ieee;
  use ieee.numeric_std_unsigned.all;
library local;
  use local.testbench_pkg.all;

architecture adder of stimulus_led4_button4 is
begin

  stimulus : process
  begin
    reset   <= '1';
    buttons <= "0000";
    wait_nr_ticks(clk, 2);
    reset   <= '0';

    wait_nr_ticks(clk, 10);
    for i in 0 to 2**buttons'length-1 loop
      buttons <= to_stdulogicvector(i, buttons'length);
      wait_nr_ticks(clk, 10);
    end loop;
    buttons <= "0000";
    wait_nr_ticks(clk, 10);

    stop_clocks;
    wait;
  end process;

end architecture;

configuration test_adder_onehot of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(adder_onehot);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(adder);
    end for;

  end for;
end configuration;

configuration test_adder_binary of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(adder_binary);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(adder);
    end for;

  end for;
end configuration;


library local;
  use local.testbench_pkg.all;

architecture knight_rider of stimulus_led4_button4 is

  alias start is buttons(0);
  alias stop  is buttons(1);

begin

  stimulus : process
  begin
    reset <= '1';
    start <= '0';
    stop  <= '0';
    wait_nr_ticks(clk, 2);
    reset <= '0';

    wait_nr_ticks(clk, 20);
    toggle_r(start, clk, 1);
    wait_nr_ticks(clk, 200);
    toggle_r(stop, clk, 1);
    wait_nr_ticks(clk, 100);
    toggle_r(start, clk, 1);
    wait_nr_ticks(clk, 50);
    toggle_r(stop, clk, 1);
    wait_nr_ticks(clk, 20);

    stop_clocks;
    wait;
  end process;

end architecture;

configuration test_knight_rider of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(knight_rider);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(knight_rider);
    end for;

  end for;
end configuration;


library local;
  use local.testbench_pkg.all;

architecture traffic_lights of stimulus_led4_button4 is

  alias start is buttons(0);
  alias stop  is buttons(1);

begin

  stimulus : process
  begin
    reset <= '1';
    start <= '0';
    stop  <= '0';
    wait_nr_ticks(clk, 2);
    reset <= '0';

    wait_nr_ticks(clk, 20);
    toggle_r(start, clk, 1);
    wait_nr_ticks(clk, 200);
    toggle_r(stop, clk, 1);
    wait_nr_ticks(clk, 100);
    toggle_r(start, clk, 1);
    wait_nr_ticks(clk, 50);
    toggle_r(stop, clk, 1);
    wait_nr_ticks(clk, 40);

    stop_clocks;
    wait;
  end process;

end architecture;

configuration test_traffic_lights of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(traffic_lights);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(traffic_lights);
    end for;

  end for;
end configuration;


library local;
  use local.testbench_pkg.all;

architecture pelicon_crossing of stimulus_led4_button4 is

  alias start is buttons(0);
  alias stop  is buttons(1);

begin

  stimulus : process
  begin
    reset <= '1';
    start <= '0';
    stop  <= '0';
    wait_nr_ticks(clk, 2);
    reset <= '0';

    wait_nr_ticks(clk, 20);
    toggle_r(start, clk, 1);
    wait_nr_ticks(clk, 200);
    toggle_r(stop, clk, 1);
    wait_nr_ticks(clk, 40);

    stop_clocks;
    wait;
  end process;

end architecture;

configuration test_pelicon_crossing of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(pelicon_crossing);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(pelicon_crossing);
    end for;

  end for;
end configuration;


library local;
  use local.testbench_pkg.all;

architecture lfsr_counter of stimulus_led4_button4 is

  alias start is buttons(0);
  alias stop  is buttons(1);

begin

  stimulus : process
  begin
    reset <= '1';
    start <= '0';
    stop  <= '0';
    wait_nr_ticks(clk, 2);
    reset <= '0';

    wait_nr_ticks(clk, 20);
    toggle_r(start, clk, 1);
    wait_nr_ticks(clk, 200);
    toggle_r(stop, clk, 1);
    wait_nr_ticks(clk, 100);
    toggle_r(start, clk, 1);
    wait_nr_ticks(clk, 50);
    toggle_r(stop, clk, 1);
    wait_nr_ticks(clk, 20);

    stop_clocks;
    wait;
  end process;

end architecture;

configuration test_lfsr_external of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(lfsr_external);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(lfsr_counter);
    end for;

  end for;
end configuration;

configuration test_lfsr_internal of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(lfsr_internal);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(lfsr_counter);
    end for;

  end for;
end configuration;


library local;

architecture interactive of stimulus_led4_button4 is
begin

  stimulus : process
  begin
    reset   <= '1';
    buttons <= "0000";
    local.testbench_pkg.wait_nr_ticks(clk, 2);
    reset <= '0';
    wait;
  end process;

end architecture;

--
-- Edit the architecture used for 'led4_button4_i' to suit the interactive demonstration
--
configuration test_interactive of test_led4_button4 is
  for test

    for led4_button4_i : led4_button4
      use entity work.led4_button4(traffic_lights);
    end for;

    for stimulus_led4_button4_i : stimulus_led4_button4
      use entity work.stimulus_led4_button4(interactive);
    end for;

  end for;
end configuration;
