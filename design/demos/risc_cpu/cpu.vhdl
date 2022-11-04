library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity risc_cpu is

    port(
        signal clk   : in  std_logic;
        signal i     : in  std_logic_vector(3 downto 0);
        signal o     : out std_logic_vector(3 downto 0);
        signal reset : in  std_logic
    );

end entity;

architecture rtl of risc_cpu is

    type t_code is array (0 to 4) of std_logic_vector(15 downto 0);
    constant code : t_code := (
        x"1030",
        x"3100",
        x"7201",
        x"4200",
        x"e001"
    );
    signal cnt  : signed(11 downto 0) := (others => '0');

    type t_mem is array (0 to 3) of std_logic_vector(3 downto 0);
    signal mem : t_mem;

begin

    process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                cnt <= (others => '0');
                mem <= (others => (others => '0'));
            else
                cnt <= cnt + 1;

                case code(to_integer(cnt))(15 downto 12) is
                    when x"1"   => mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= code(to_integer(cnt))(7 downto 4); -- set
                    when x"2"   => mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= mem(to_integer(unsigned(code(to_integer(cnt))(7 downto 4)))); -- cpy
                    when x"3"   => mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= i; -- in
                    when x"4"   => o <= mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))); -- out
                    when x"5"   => mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= code(to_integer(cnt))(7 downto 4) and code(to_integer(cnt))(3 downto 0); -- and
                    when x"6"   => mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= code(to_integer(cnt))(7 downto 4) or  code(to_integer(cnt))(3 downto 0); -- or
                    when x"7"   => mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= std_logic_vector(signed(mem(to_integer(unsigned(code(to_integer(cnt))(7 downto 4))))) + signed(mem(to_integer(unsigned(code(to_integer(cnt))(3 downto 0)))))); -- add
                    when x"8"   => mem(to_integer(unsigned(code(to_integer(cnt))(11 downto 8)))) <= std_logic_vector(signed(mem(to_integer(unsigned(code(to_integer(cnt))(7 downto 4))))) - signed(mem(to_integer(unsigned(code(to_integer(cnt))(3 downto 0)))))); -- sub

                    when x"e"   => cnt <=       signed(code(to_integer(cnt))(11 downto 0)); -- goto
                    when x"f"   => cnt <= cnt + signed(code(to_integer(cnt))(11 downto 0)); -- move

                    when x"0"   =>                     -- noop
                    when others =>                     -- noop
                end case;
            end if;
        end if;
    end process;

end architecture;
