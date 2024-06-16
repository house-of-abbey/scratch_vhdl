architecture verilog of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 1;

begin

  led4_button4_v : entity work.led4_button4_verilog
    port map (
      clk     => clk,
      reset   => reset,
      incr    => incr,
      buttons => buttons,
      leds    => leds
    );

end architecture;


configuration zybo_circuitverse of zybo_z7_10 is
  for rtl
    for led4_button4_i : led4_button4
      use entity work.led4_button4(verilog);
    end for;
  end for;
end configuration;
