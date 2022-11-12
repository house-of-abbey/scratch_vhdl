library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package risc_cpu_pkg is

  type reg_arr_t is array (0 to 7) of std_logic_vector(3 downto 0);

  function "+" (l, r : std_logic_vector)           return std_logic_vector;
  function "+" (l : std_logic_vector; r : signed)  return std_logic_vector;
  function "+" (l : std_logic_vector; r : integer) return std_logic_vector;
  function "-" (l, r : std_logic_vector)           return std_logic_vector;

  type code_t is array (natural range <>) of std_logic_vector(12 downto 0);

  impure function read_code_from_file(
    filename : string;
    arr_size : natural
  ) return code_t;

end package;


library std;
  use std.textio.all;

package body risc_cpu_pkg is

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
  
  function str2bin(s: string) return std_logic_vector is
    variable ret : std_logic_vector(s'range);
    
    function s2b(c : character) return std_logic is
    begin
      if c = '1' then
        return '1';
      else
        -- Any other character at all
        return '0';
      end if;
    end function;

  begin
    for i in s'range loop
      ret(i) := s2b(s(i));
    end loop;
    return ret;
  end function;

  impure function read_code_from_file(
    filename : string;
    arr_size : natural
  ) return code_t is
    file fh      : text open read_mode is filename;
    variable l   : line;
    variable s   : string(1 to 13);         -- Each line should be 13 characters long.
    variable ret : code_t(0 to arr_size-1); -- Get this passed down derived from the number of address bits driving the ROM.
    variable ln  : natural range 0 to arr_size-1 := 0;
  begin
    while not endfile(fh) loop 
      readline(fh, l);
      -- Cannot provide any file reading error checking, e.g. for lines less than 13
      -- characters, because "l.all" is not supported for synthesis, even when
      -- initialising a constant.
      read(l, s);
      ret(ln) := str2bin(s); -- Convert binary string to vector. Requires a function.
      ln := ln + 1;
    end loop;
    return ret;
  end function;

end package body;
