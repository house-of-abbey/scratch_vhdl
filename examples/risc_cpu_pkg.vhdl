library ieee;
  use ieee.std_logic_1164.all;

package risc_cpu_pkg is

  type t_code is array (0 to 4) of std_logic_vector(15 downto 0);
  type t_mem is array (0 to 3) of std_logic_vector(3 downto 0);

end package;
