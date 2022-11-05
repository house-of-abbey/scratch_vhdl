-------------------------------------------------------------------------------------
--
-- Distributed under MIT Licence
--   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
--
-------------------------------------------------------------------------------------
--
-- Standard 4 button input 4 LED output entity with a variety of different
-- architectures demonstrating different ways of controlling the LEDs.
--
-- J D Abbey & P A Abbey, 5 November 2022
--
-------------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package risc_pkg is

  type op_t is (
    noop,
    op_set,
    op_copy,
    op_and,
    op_or,
    op_not,
    op_add,
    op_sub,
    op_shft,
    op_ifeq,
    op_ifgt,
    op_ifge,
    op_wi, -- Wait for incr
    op_goto
  );

  function to_op_code(op_vec : std_logic_vector(3 downto 0)) return op_t;

  function "+" (l, r : std_logic_vector)           return std_logic_vector;
  function "+" (l : std_logic_vector; r : signed)  return std_logic_vector;
  function "+" (l : std_logic_vector; r : integer) return std_logic_vector;
  function "-" (l, r : std_logic_vector)           return std_logic_vector;

end package;

package body risc_pkg is

  function to_op_code(op_vec : std_logic_vector(3 downto 0)) return op_t is
  begin
    case op_vec is
      when x"1"   => return op_set;
      when x"2"   => return op_copy;

      when x"3"   => return op_and;
      when x"4"   => return op_or;
      when x"5"   => return op_not;

      when x"6"   => return op_add;
      when x"7"   => return op_sub;
      
      when x"8"   => return op_shft;

      when x"b"   => return op_ifeq;
      when x"c"   => return op_ifgt;
      when x"d"   => return op_ifge;

      when x"e"   => return op_wi;
      when x"f"   => return op_goto;
      when others => return noop;
    end case;
  end function;

  function "+" (l, r : std_logic_vector) return std_logic_vector is
  begin
    return std_logic_vector(signed(l) + signed(r));
  end function;

  function "+" (l : std_logic_vector; r : signed) return std_logic_vector is
  begin
    return std_logic_vector(signed(l) + r);
  end function;

  function "+" (l : std_logic_vector; r : integer) return std_logic_vector is
  begin
    return std_logic_vector(signed(l) + r);
  end function;

  function "-" (l, r : std_logic_vector) return std_logic_vector is
  begin
    return std_logic_vector(signed(l) - signed(r));
  end function;

end package body;
