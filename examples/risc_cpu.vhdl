library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;




architecture scratch of led4_button4 is

  constant button_tab_c : natural := 2;
  constant code : work.risc_cpu_pkg.t_code := (x"1030",x"3100",x"7201",x"4200",x"e001");

  signal cnt : signed(11 downto 0);
  signal mem : work.risc_cpu_pkg.t_mem;


begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
        cnt <= (others => '0');
        mem <= (others => (others => '0'));
      else
        cnt <= cnt + 1;
        case code(to_integer(cnt))(15 downto 12) is
          when "0001" =>
            mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= code(to_integer(cnt))(7 downto 4);

          when "0010" =>
            mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= mem(to_integer(unsigned(code(to_integer(cnt))(7 downto 4))));

          when "0011" =>
            mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= buttons;

          when "0100" =>
            leds <= mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8))));

          when "0101" =>
            mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= mem(to_integer(unsigned(code(to_integer(cnt))(7 downto 4)))) and mem(to_integer(unsigned(code(to_integer(cnt))(3 downto 0))));

          when "0110" =>
            mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= mem(to_integer(unsigned(code(to_integer(cnt))(7 downto 4)))) or mem(to_integer(unsigned(code(to_integer(cnt))(3 downto 0))));

          when "0111" =>
            mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= mem(to_integer(unsigned(code(to_integer(cnt))(7 downto 4))));

          when "1000" =>
            mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= mem(to_integer(unsigned(code(to_integer(cnt))(7 downto 4))));

          when "1110" =>
            cnt <= signed(code(to_integer(cnt)))(11 downto 0);

          when "1111" =>
            cnt <= cnt + signed(code(to_integer(cnt)))(11 downto 0);

          when "0000" =>

          when others =>

        end case;
      end if;
    end if;
  end process;

end architecture;
