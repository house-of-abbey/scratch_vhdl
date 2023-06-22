library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library work;
  use work.risc_cpu_pkg.all;




architecture scratch of led4_button4 is

  constant button_tab_c : natural := 2;
  constant code : code_t := read_code_from_file(filename => rom_file_g, arr_size => 512);

  signal pc : std_logic_vector(8 downto 0) := (others => '0');
  signal pc_value : work.risc_cpu_pkg.code_t'element := (others => '0');
  signal pc_op : std_logic_vector(3 downto 0) := (others => '0');
  signal pc_dest : natural range 0 to 7;
  signal pc_src1 : natural range 0 to 7;
  signal pc_src2 : natural range 0 to 7;
  signal wi : unsigned(8 downto 0) := (others => '0');
  signal eif : std_logic;
  signal reg : work.risc_cpu_pkg.reg_arr_t := (others => (others => '0'));


begin

  leds <= reg(7);

  pc_value <= code(to_integer(unsigned(pc)));

  pc_op <= pc_value(12 downto 9);

  pc_dest <= to_integer(unsigned(pc_value(8 downto 6)));

  pc_src1 <= to_integer(unsigned(pc_value(5 downto 3)));

  pc_src2 <= to_integer(unsigned(pc_value(2 downto 0)));

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pc <= (others => '0');
        reg <= (others => (others => '1'));
        wi <= (others => '0');
        eif <= '0';
      else
        -- The assembler will prevent assignments to reg(6). If the assembled
        -- instruction code does manage to assign reg(6), it will be overwritten
        -- on the next clock cycle.
        -- This assignment is inside the clock process for convenience only.
        -- The reset clause also resets reg(6) due to limits with Scratch VHDL
        -- entry, hence this assignment cannot presently be a concurrent one.
        reg(6) <= buttons;
        if incr = '1' then
          if wi > 0 then
            wi <= wi - 1;
          end if;
        end if;
        -- wi is all zeros
        if nor(wi) then
          -- Update the program counter
          if eif = '1' then
            pc <= pc + 2;
            eif <= '0';
          else
            pc <= pc + 1;
          end if;
          case pc_op is
            -- op_set
            when "0001" =>
              reg(pc_dest) <= pc_value(3 downto 0);

            -- op_copy
            when "0010" =>
              reg(pc_dest) <= reg(pc_src1);

            -- op_and
            when "0011" =>
              reg(pc_dest) <= reg(pc_src1) and reg(pc_src1);

            -- op_or
            when "0100" =>
              reg(pc_dest) <= reg(pc_src1) or reg(pc_src1);

            -- op_not
            when "0101" =>
              reg(pc_dest) <= not reg(pc_src1);

            -- op_add
            when "0110" =>
              reg(pc_dest) <= reg(pc_src1) + reg(pc_src2);

            -- op_sub
            when "0111" =>
              reg(pc_dest) <= reg(pc_src1) - reg(pc_src2);

            -- op_shft
            when "1000" =>
              if pc_value(1) = '0' then
                -- Shift right
                reg(pc_dest) <= pc_value(0) & reg(pc_src1)(3 downto 1);
              else
                -- Shit left
                reg(pc_dest) <= reg(pc_src1)(2 downto 0) & pc_value(0);
              end if;

            -- op_ifbit
            when "1010" =>
              if reg(pc_src1)(to_integer(unsigned(pc_value(1 downto 0)))) = '1' then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            -- op_ifeq
            when "1011" =>
              if reg(pc_src1) = reg(pc_src2) then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            -- op_ifgt
            when "1100" =>
              if reg(pc_src1) > reg(pc_src2) then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            -- op_ifge
            when "1101" =>
              if reg(pc_src1) >= reg(pc_src2) then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            -- op_wi
            when "1110" =>
              wi <= unsigned(pc_value(8 downto 0));

            -- op_goto
            when "1111" =>
              pc <= pc_value(8 downto 0);
              eif <= '0';

            when others =>

          end case;
        end if;
      end if;
    end if;
  end process;

end architecture;
