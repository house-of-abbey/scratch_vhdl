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
  signal op : std_logic_vector(3 downto 0) := (others => '0');
  signal o : natural range 0 to 7;
  signal a : natural range 0 to 7;
  signal b : natural range 0 to 7;
  signal wi : unsigned(8 downto 0) := (others => '0');
  signal eif : std_logic;
  signal reg : work.risc_cpu_pkg.reg_arr_t := (others => (others => '0'));
  signal rnd : std_logic_vector(7 downto 0) := "00000001";


begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        rnd <= "00000001";
      else
        rnd <= ((rnd(7) xor rnd(5)) xor (rnd(4) xor (rnd(3) xor rnd(0)))) & rnd(7 downto 1);
      end if;
    end if;
  end process;

  leds <= reg(7);

  pc_value <= code(to_integer(unsigned(pc)));

  op <= pc_value(12 downto 9);

  o <= to_integer(unsigned(pc_value(8 downto 6)));

  a <= to_integer(unsigned(pc_value(5 downto 3)));

  b <= to_integer(unsigned(pc_value(2 downto 0)));

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pc <= (others => '0');
        reg <= (others => (others => '0'));
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
          -- Update the program counter.
          -- In the true branch of a conditional branch 'eif'
          -- will be high in order to skip an extra instruction.
          if eif = '1' then
            pc <= pc + 2;
            eif <= '0';
          else
            pc <= pc + 1;
          end if;
          case op is
            -- op_set
            when "0001" =>
              reg(o) <= pc_value(3 downto 0);

            -- op_copy
            when "0010" =>
              reg(o) <= reg(a);

            -- op_and
            when "0011" =>
              reg(o) <= reg(a) and reg(b);

            -- op_or
            when "0100" =>
              reg(o) <= reg(a) or reg(b);

            -- op_not
            when "0101" =>
              reg(o) <= not reg(a);

            -- op_add
            when "0110" =>
              reg(o) <= reg(a) + reg(b);

            -- op_sub
            when "0111" =>
              reg(o) <= reg(a) - reg(b);

            -- op_shft
            when "1000" =>
              if pc_value(1) = '0' then
                -- Shift right
                reg(o) <= pc_value(0) & reg(a)(3 downto 1);
              else
                -- Shit left
                reg(o) <= reg(a)(2 downto 0) & pc_value(0);
              end if;

            -- op_sub
            when "1001" =>
              reg(o) <= rnd(3 downto 0);

            -- op_ifbit
            when "1010" =>
              if reg(a)(to_integer(unsigned(pc_value(1 downto 0)))) = '1' then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            -- op_ifeq
            when "1011" =>
              if reg(a) = reg(b) then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            -- op_ifgt
            when "1100" =>
              if reg(a) > reg(b) then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            -- op_ifge
            when "1101" =>
              if reg(a) >= reg(b) then
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
