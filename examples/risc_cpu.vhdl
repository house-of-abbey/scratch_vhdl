library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.risc_cpu_pkg.all;

architecture scratch of led4_button4 is

  2CONSTANT button_tab_c : natural := 2;
  2CONSTANT code         : code_t  := read_code_from_file(filename => rom_file_g, arr_size => 512);

  2SIGNAL pc       : std_logic_vector(8 downto 0);
  2SIGNAL pc_value : work.risc_cpu_pkg.code_t'element;
  2SIGNAL pc_op    : std_logic_vector(3 downto 0);
  2SIGNAL pc_dest  : natural range 0 to 7;
  2SIGNAL pc_src1  : natural range 0 to 7;
  2SIGNAL pc_src2  : natural range 0 to 7;
  2SIGNAL wi       : unsigned(8 downto 0);
  2SIGNAL eif      : std_logic;
  2SIGNAL reg      : work.risc_cpu_pkg.reg_arr_t;

begin

  2leds <= reg(7);

  2pc_value <= code(to_integer(unsigned(pc)));

  2pc_op <= pc_value(12 downto 9);

  2pc_dest <= to_integer(unsigned(pc_value(8 downto 6)));

  2pc_src1 <= to_integer(unsigned(pc_value(5 downto 3)));

  2pc_src2 <= to_integer(unsigned(pc_value(2 downto 0)));

  2PROCESS (clk)
  2BEGIN
  2  2IF rising_edge(clk) then
  2  2  2IF reset = '1' then
  2  2  2  2pc  <= (others => '0');
  2  2  2  2reg <= (others => (others => '1'));
  2  2  2  2wi  <= (others => '0');
  2  2  2  2eif <= '0';
  2  2  2ELSE
  2  2  2  2-- The assembler will prevent assignments to reg(6). If the assembled
  2  2  2  2-- instruction code does manage to assign reg(6), it will be overwritten
  2  2  2  2-- on the next clock cycle.
  2  2  2  2-- This assignment is inside the clock process for convenience only.
  2  2  2  2-- The reset clause also resets reg(6) due to limits with Scratch VHDL
  2  2  2  2-- entry, hence this assignment cannot presently be a concurrent one.
  2  2  2  2reg(6) <= buttons;
  2  2  2  2IF incr = '1' then
  2  2  2  2  2IF wi > 0 then
  2  2  2  2  2  2wi <= wi - 1;
  2  2  2  2  2END if;
  2  2  2  2END if;
  2  2  2  2-- wi is all zeros
  2  2  2  2IF nor(wi) then
  2  2  2  2  2IF eif = '1' then
  2  2  2  2  2  2pc  <= pc + 2;
  2  2  2  2  2  2eif <= '0';
  2  2  2  2  2ELSE
  2  2  2  2  2  2pc <= pc + 1;
  2  2  2  2  2END if;
  2  2  2  2  2CASE pc_op is
  2  2  2  2  2  2WHEN "0001" =>
  2  2  2  2  2  2  2reg(pc_dest) <= pc_value(3 downto 0);

  2  2  2  2  2  2WHEN "0010" =>
  2  2  2  2  2  2  2reg(pc_dest) <= reg(pc_src1);

  2  2  2  2  2  2WHEN "0011" =>
  2  2  2  2  2  2  2reg(pc_dest) <= reg(pc_src1) and reg(pc_src1);

  2  2  2  2  2  2WHEN "0100" =>
  2  2  2  2  2  2  2reg(pc_dest) <= reg(pc_src1) or reg(pc_src1);

  2  2  2  2  2  2WHEN "0101" =>
  2  2  2  2  2  2  2reg(pc_dest) <= not reg(pc_src1);

  2  2  2  2  2  2WHEN "0110" =>
  2  2  2  2  2  2  2reg(pc_dest) <= reg(pc_src1) + reg(pc_src2);

  2  2  2  2  2  2WHEN "0111" =>
  2  2  2  2  2  2  2reg(pc_dest) <= reg(pc_src1) - reg(pc_src2);

  2  2  2  2  2  2WHEN "1000" =>
  2  2  2  2  2  2  2IF pc_value(1) = '0' then
  2  2  2  2  2  2  2  2reg(pc_dest) <= pc_value(0) & reg(pc_src1)(3 downto 1);
  2  2  2  2  2  2  2ELSE
  2  2  2  2  2  2  2  2reg(pc_dest) <= reg(pc_src1)(2 downto 0) & pc_value(0);
  2  2  2  2  2  2  2END if;

  2  2  2  2  2  2WHEN "1011" =>
  2  2  2  2  2  2  2IF reg(pc_src1) = reg(pc_src2) then
  2  2  2  2  2  2  2  2eif <= '1';
  2  2  2  2  2  2  2ELSE
  2  2  2  2  2  2  2  2pc <= pc + 2;
  2  2  2  2  2  2  2END if;

  2  2  2  2  2  2WHEN "1100" =>
  2  2  2  2  2  2  2IF reg(pc_src1) > reg(pc_src2) then
  2  2  2  2  2  2  2  2eif <= '1';
  2  2  2  2  2  2  2ELSE
  2  2  2  2  2  2  2  2pc <= pc + 2;
  2  2  2  2  2  2  2END if;

  2  2  2  2  2  2WHEN "1101" =>
  2  2  2  2  2  2  2IF reg(pc_src1) >= reg(pc_src2) then
  2  2  2  2  2  2  2  2eif <= '1';
  2  2  2  2  2  2  2ELSE
  2  2  2  2  2  2  2  2pc <= pc + 2;
  2  2  2  2  2  2  2END if;

  2  2  2  2  2  2WHEN "1110" =>
  2  2  2  2  2  2  2wi <= unsigned(pc_value(8 downto 0));

  2  2  2  2  2  2WHEN "1111" =>
  2  2  2  2  2  2  2pc  <= pc_value(8 downto 0);
  2  2  2  2  2  2  2eif <= '0';

  2  2  2  2  2  2WHEN others =>

  2  2  2  2  2END case;
  2  2  2  2END if;
  2  2  2END if;
  2  2END if;
  2END process;

end architecture;
