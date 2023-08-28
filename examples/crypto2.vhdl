library ieee;
  use ieee.std_logic_1164.all;




architecture scratch of led4_button4 is

  constant button_tab_c : natural := 2;
  constant key_tx_c : std_logic_vector(7 downto 0) := "10100101";
  constant key_rx_c : std_logic_vector(7 downto 0) := "10100101";

  signal run : std_logic;
  signal run_d : std_logic;
  signal cipher_text_tx : std_logic;
  signal cipher_text_rx : std_logic;
  signal plain_text : std_logic;
  signal cipher_hist_tx : std_logic_vector(7 downto 0);
  signal cipher_hist_rx : std_logic_vector(7 downto 0);
  signal key_material_tx : std_logic;
  signal key_material_rx : std_logic;

  alias start is buttons(0);
  alias stop is buttons(1);

begin

  cipher_text_rx <= cipher_hist_tx(7) xor buttons(0);

  key_material_tx <= xor(cipher_hist_tx xor key_tx_c) and run;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        cipher_hist_rx <= "00000000";
      else
        if incr = '1' then
          cipher_hist_rx <= cipher_text_rx & cipher_hist_rx(7 downto 1);
        end if;
      end if;
    end if;
  end process;

  cipher_text_tx <= buttons(3) xor key_material_tx;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        cipher_hist_tx <= "00000000";
      else
        if incr = '1' then
          cipher_hist_tx <= cipher_text_tx & cipher_hist_tx(7 downto 1);
        end if;
      end if;
    end if;
  end process;

  key_material_rx <= xor(cipher_hist_rx xor key_rx_c) and run_d;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        plain_text <= '0';
      else
        if incr = '1' then
          plain_text <= cipher_text_rx xor key_material_rx;
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
        leds <= (buttons(3) & run) & (cipher_text_tx & plain_text);
      end if;
    end if;
  end process;

end architecture;
