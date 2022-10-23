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
-- J D Abbey & P A Abbey, 18 October 2022
--
-------------------------------------------------------------------------------------

-- References:
--  * https://digilent.com/reference/programmable-logic/zybo-z7/reference-manual
--  * https://digilent.com/reference/programmable-logic/zybo-z7/start
--  * https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-vitis

library ieee;
  use ieee.std_logic_1164.all;

entity zybo_z7_10 is
  generic(
    sim_g : boolean := false
  );
  port(
    clk_port : in  std_logic; -- 125 MHz External Clock
    sw       : in  std_logic_vector(3 downto 0);
    btn      : in  std_logic_vector(3 downto 0);
    leds     : out std_logic_vector(3 downto 0) := "0000"
  );
end entity;


architecture rtl of zybo_z7_10 is

  function divide(sim : boolean) return positive is
  begin
    if sim then
      return 10;
    else
      -- 500 ms / 8 ns, but Vivado is unable to perform this calculation even when the result
      -- is assigned to a constant.
      return 625000000;
    end if;
  end function;

  constant divide_c : positive := divide(sim_g);

  signal clk     : std_logic                    := '0';
  signal reset   : std_logic                    := '0';
  signal locked  : std_logic;
  signal rst_reg : std_logic_vector(3 downto 0) := (others => '1');
  signal sw_r    : std_logic_vector(sw'range)   := (others => '0');
  signal btn_r   : std_logic_vector(btn'range)  := (others => '0');
  signal buttons : std_logic_vector(btn'range)  := (others => '0');
  signal incr    : std_logic                    := '0';
  signal count   : natural range 0 to divide_c  := 0;

begin

  pll_i : entity work.pll
    port map (
      -- Clock in ports
      clk_in => clk_port,
      -- Clock out ports
      clk_out => clk,
      -- Status and control signals
      locked => locked
    );


  -- Take advantage of initial values set GSR to generate the reset. It's not obvious
  -- how to tap GSR directly and discouraged too. 'locked' goes high earlier than GSR
  -- allows 'rst_reg' to start shifting, so this is belt & braces to ensure that reset
  -- cannot preceed the PLL entering the locked state.
  process(clk)
  begin
    if rising_edge(clk) then
      (reset, rst_reg) <= rst_reg(rst_reg'high downto 0) & not locked;
    end if;
  end process;

  -- Double retime buttons and switches
  retime_sw : entity work.retime
    generic map (
      num_bits => sw'length
    )
    port map (
      clk       => clk,
      reset     => reset,
      flags_in  => sw,
      flags_out => sw_r
    );

  -- Double retime buttons and switches
  retime_btn : entity work.retime
    generic map (
      num_bits => btn'length
    )
    port map (
      clk       => clk,
      reset     => reset,
      flags_in  => btn,
      flags_out => btn_r
    );

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        incr    <= '0';
        count   <= 0;
        buttons <= "0000";
      else
        -- Arbitrate between buttons and switches
        buttons <= btn_r or sw_r;

        incr    <= '0';
        if count = divide_c-1 then
          incr  <= '1';
          count <= 0;
        else
          count <= count + 1;
        end if;
      end if;
    end if;
  end process;

  led4_button4_i : entity work.led4_button4(pulse_gen)
    port map (
      clk     => clk,
      reset   => reset,
      incr    => incr,
      buttons => buttons,
      leds    => leds
    );

end architecture;
