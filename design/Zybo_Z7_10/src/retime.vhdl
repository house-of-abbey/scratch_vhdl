-------------------------------------------------------------------------------------
--
-- Distributed under MIT Licence
--   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
--
-------------------------------------------------------------------------------------
--
-- Clock synchroniser used for the asynchronous button inputs, and double retimes
-- them to the internal clock.
--
-- J D Abbey & P A Abbey, 14 October 2022
--
-------------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

entity retime is
  generic (
    num_bits : positive := 2
  );
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    flags_in  : in  std_logic_vector(num_bits-1 downto 0);
    flags_out : out std_logic_vector(num_bits-1 downto 0) := (others => '0')
  );
end entity;


architecture rtl of retime is

  signal reg_retime : std_logic_vector(num_bits-1 downto 0) := (others => '0');

  -- Could be placed in a constraints file
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of reg_retime : signal is "TRUE";
  attribute ASYNC_REG of flags_out  : signal is "TRUE";

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        reg_retime <= (others => '0');
        flags_out  <= (others => '0');
      else
        reg_retime <= flags_in;
        flags_out  <= reg_retime;
      end if;
    end if;
  end process;

end architecture;
