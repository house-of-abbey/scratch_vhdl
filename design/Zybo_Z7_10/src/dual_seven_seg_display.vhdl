-------------------------------------------------------------------------------------
--
-- Distributed under MIT Licence
--   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
--
-------------------------------------------------------------------------------------
--
-- The PmodSSD is a two-digit seven-segment display. Users can toggle through GPIO
-- signals which digit is currently on at a rate of 50Hz or greater to achieve
-- persistence-of-vision to give the effect of both digits being lit up
-- simultaneously. The purpose of this component is to abstract the user from the
-- nausea of the digit switching and provide a clean abstraction of the dual seven
-- segment display driver.
--
-- References:
--  * https://digilent.com/reference/pmod/pmodssd/start
--  * https://digilent.com/reference/pmod/pmodssd/reference-manual
--  * https://digilent.com/reference/_media/reference/pmod/pmodssd/pmodssd_rm.pdf
--
-- J D Abbey & P A Abbey, 18 October 2022
--
-------------------------------------------------------------------------------------
--
-- Display: 0              1
--
--          a              a
--        #####          #####
--       #     #        #     #
--     f #     # b    f #     # b
--       #  g  #        #  g  #
--        #####          #####
--       #     #        #     #
--     e #     # c    e #     # c
--       #  d  #        #  d  #
--        #####  h       #####  h
--
-- The decimal points 'h' do not have a driver pin and should be ignored.
--

library ieee;
  use ieee.std_logic_1164.all;

entity dual_seven_seg_display is
  generic(
    sim_g         : boolean                  := false;
    -- <= 20 ms (50 Hz). Ideally this would be of type 'time', but Vivado is a pain.
    switch_rate_g : real range 0.0 to 2.0e-3 := 2.0e-3
  );
  port(
    clk      : in  std_logic;
    reset    : in  std_logic;
    sevseg0  : in  std_logic_vector(6 downto 0) := "0000000"; -- left
    sevseg1  : in  std_logic_vector(6 downto 0) := "0000000"; -- right
    -- Outputs to the PmodSSD is a two-digit seven-segment display
    disp_sel : out std_logic                    := '0';
    sevseg   : out std_logic_vector(6 downto 0) := "0000000"
  );
end entity;


architecture rtl of dual_seven_seg_display is

  function divide(sim : boolean) return positive is
  begin
    if sim then
      return 2; -- incr is 10, so make this sufficiently responsive
    else
      -- ERROR: [Synth 8-27] Division of physical type values not supported
      -- return positive(2 ms / 8 ns);
      -- Vivado does not support division of physical quantites, even when the result is
      -- assigned to a constant. You can't even convert to real by dividing by "1 ns".
      -- Using real literals instead.
      return positive(switch_rate_g / 8.0e-9);
    end if;
  end function;

  constant divide_c : positive := divide(sim_g);

  signal count : natural range 0 to divide_c-1 := 0;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        count    <= 0;
        disp_sel <= '0';
        sevseg   <= (others => '0');
      else
        if count = divide_c-1 then
          disp_sel <= not disp_sel;

          -- Alternate driving the displays from the inputs, the switching rate is
          -- governed by 'switch_rate_g'.
          if disp_sel = '1' then
            sevseg <= sevseg1;
          else
            sevseg <= sevseg0;
          end if;

          count <= 0;
        else
          count <= count + 1;
        end if;
      end if;
    end if;
  end process;

end architecture;
