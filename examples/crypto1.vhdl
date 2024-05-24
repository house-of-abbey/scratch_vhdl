library ieee;
  use ieee.std_logic_1164.all;


architecture scratch of led4_button4 is

  constant button_tab_c : natural := 2;

  signal run : std_logic;
  signal key_src : std_logic_vector(3 downto 0);
  signal key_dest : std_logic_vector(3 downto 0);
  signal cipher_text : std_logic;
  signal plain_text : std_logic;
  signal run_d : std_logic;

  alias start is buttons(0);
  alias stop is buttons(1);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        cipher_text <= '0';
      else
        if incr = '1' then
          cipher_text <= buttons(3) xor (key_src(0) and run);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        plain_text <= '0';
      else
        if incr = '1' then
          plain_text <= cipher_text xor (key_dest(0) and run_d);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        run <= '0';
        run_d <= '0';
      else
        if incr = '1' then
          -- buttons(1) is crypto key enable
          if buttons(2) = '1' then
            run <= '1';
          elsif buttons(1) = '0' then
            run <= '0';
          end if;
          run_d <= run;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        leds <= (buttons(3) & run) & (cipher_text & plain_text);
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        key_src <= "1111";
      else
        if run = '1' and incr = '1' then
          key_src <= key_src(2 downto 0) & '0' xor key_src(3) & ("00" & key_src(3));
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        key_dest <= "1111";
      else
        if run_d = '1' and incr = '1' then
          key_dest <= key_dest(2 downto 0) & '0' xor key_dest(3) & ("00" & key_dest(3));
        end if;
      end if;
    end if;
  end process;

end architecture;
