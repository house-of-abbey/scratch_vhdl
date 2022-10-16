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
-- J D Abbey & P A Abbey, 14 October 2022
--
-------------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

entity led4_button4 is
  port(
    clk     : in  std_logic;
    reset   : in  std_logic;
    incr    : in  std_logic;
    buttons : in  std_logic_vector(3 downto 0);
    leds    : out std_logic_vector(3 downto 0) := "0000"
  );
end entity;


architecture button_driven of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : positive := 1;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else

        -- When any button is pressed, update the LEDs.
        -- i.e. When no button pressed, do not change.
        -- This will therefore fail with toggle switches, needs push switch only.
        if or(buttons) then
          leds <= buttons;
        end if;

      end if;
    end if;
  end process;

end architecture;


architecture logic_gates of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : positive := 2;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        leds(0) <= and(buttons);
        leds(1) <=  or(buttons);
        leds(2) <= xor(buttons);
        leds(3) <= nor(buttons);
      end if;
    end if;
  end process;

end architecture;


library ieee;
  use ieee.numeric_std.all;

architecture adder_onehot of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : positive := 2;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else

        case buttons is
          when "0000"                                              => leds <= "0000";
          when "0001" | "0010" | "0100" | "1000"                   => leds <= "0001";
          when "0011" | "0101" | "0110" | "1010" | "1100" | "1001" => leds <= "0010";
          when "0111" | "1011" | "1101" | "1110"                   => leds <= "0100";
          when "1111"                                              => leds <= "1000";
          -- Cover the other bit values: 'U', 'X', 'Z', 'W', 'L' & 'H'
          when others                                              => leds <= "1111";
        end case;

      end if;
    end if;
  end process;

end architecture;


architecture adder_binary of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : positive := 2;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else

        case buttons is
          when "0000"                                              => leds <= "0000";
          when "0001" | "0010" | "0100" | "1000"                   => leds <= "0001";
          when "0011" | "0101" | "0110" | "1010" | "1100" | "1001" => leds <= "0010";
          when "0111" | "1011" | "1101" | "1110"                   => leds <= "0011";
          when "1111"                                              => leds <= "0100";
          -- Cover the other bit values: 'U', 'X', 'Z', 'W', 'L' & 'H'
          when others                                              => leds <= "1111";
        end case;

      end if;
    end if;
  end process;

end architecture;



library ieee;
  use ieee.numeric_std_unsigned.all;

architecture binary_counter of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : positive := 1;

  alias start is buttons(0);
  alias stop  is buttons(1);

  signal run : std_logic             := '0';
  signal cnt : integer range 0 to 15 := 0;

begin

  leds <= to_stdulogicvector(cnt, leds'length);

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        run <= '0';
        cnt <= 0;
      else

        if start = '1' then
          run <= '1';
        elsif stop = '1' then
          run <= '0';
        end if;

        if run = '1' and incr = '1' then
          if cnt = 15 then
            cnt <= 0;
          else
            cnt <= cnt + 1;
          end if;
        end if;

      end if;
    end if;
  end process;

end architecture;


--
-- Bonnet (hood) lights on 'Kitt', the car from Knight Rider (1982–1986), and subsequent sequels.
-- KITT = "Knight Industries Two Thousand"
-- https://www.youtube.com/watch?v=oNyXYPhnUIs&ab_channel=NBCClassics
--
architecture knight_rider of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : positive := 1;

  alias start is buttons(0);
  alias stop  is buttons(1);

  signal run   : std_logic            := '0';
  signal state : integer range 0 to 5 := 0;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        run   <= '0';
        state <= 0;
        leds  <= "0000";
      else

        if start = '1' then
          run <= '1';
        elsif stop = '1' then
          run <= '0';
        end if;

        if run = '1' and incr = '1' then

          if state = 5 then
            state <= 0;
          else
            state <= state + 1;
          end if;

          case state is
            when 0 => leds <= "0001";
            when 1 => leds <= "0010";
            when 2 => leds <= "0100";
            when 3 => leds <= "1000";
            when 4 => leds <= "0100";
            when 5 => leds <= "0010";
          end case;

        end if;

      end if;
    end if;
  end process;

end architecture;


--
-- https://www.gov.uk/guidance/the-highway-code/light-signals-controlling-traffic
-- https://www.intensive-driving-school.co.uk/traffic-lights-explained
-- https://www.booklearnpass.co.uk/learning-to-drive/beginner/traffic-light-sequence/
--
architecture traffic_lights of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : positive := 3;

  alias start is buttons(0);
  alias stop  is buttons(1);

  signal start_r : std_logic;
  signal stop_r  : std_logic;
  -- Avoiding the need for an enumerated type
  signal state   : integer range 0 to 7 := 0;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        start_r <= '0';
        stop_r  <= '0';
        state   <= 0;
        leds    <= "0000";
      else

        if start = '1' then
          start_r <= '1';
        end if;

        if stop = '1' then
          stop_r <= '1';
        end if;

        if incr = '1' then

          case state is
            when 0 =>
              --       FGAR
              leds <= "0001";
              if start_r = '1' then
                state   <= 1;
                -- Reset both in case start/stop have been pressed in the wrong order
                start_r <= '0';
                stop_r  <= '0';
              end if;
            when 1 =>
              leds  <= "0011";
              state <= 2;
            when 2 =>
              leds <= "0100";
              if stop_r = '1' then
                state   <= 3;
                start_r <= '0';
                stop_r  <= '0';
              end if;
            when 3 =>
              leds  <= "0010";
              state <= 4;
            when 4 =>
              leds <= "1001"; -- Left filter this time
              if start_r = '1' then
                state   <= 5;
                start_r <= '0';
                stop_r  <= '0';
              end if;
            when 5 =>
              leds  <= "0011";
              state <= 6;
            when 6 =>
              leds <= "0100";
              if stop_r = '1' then
                state   <= 7;
                start_r <= '0';
                stop_r  <= '0';
              end if;
            when 7 =>
              leds  <= "0010";
              state <= 0;
          end case;

        end if;

      end if;
    end if;
  end process;

end architecture;


--
-- https://www.passmefast.co.uk/resources/driving-advice/traffic-light-sequence-guide
--
architecture pelicon_crossing of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : positive := 3;

  alias start is buttons(0);
  alias stop  is buttons(1);

  signal start_r : std_logic;
  signal stop_r  : std_logic;
  -- Avoiding the need for an enumerated type
  signal state   : integer range 0 to 7 := 0;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        start_r <= '0';
        stop_r  <= '0';
        state   <= 0;
        leds    <= "0000";
      else

        if start = '1' then
          start_r <= '1';
        end if;

        if stop = '1' then
          stop_r <= '1';
        end if;

        if incr = '1' then

          case state is
            when 0 =>
              --        FGAR
              leds  <= "0001";
              if start_r = '1' then
                state   <= 1;
                -- Reset both in case start/stop have been pressed in the wrong order
                start_r <= '0';
                stop_r  <= '0';
              end if;
            when 1 =>
              leds  <= "0010";
              state <= 2;
            when 2 =>
              leds  <= "0000";
              state <= 3;
            when 3 =>
              leds  <= "0010";
              state <= 4;
            when 4 =>
              leds  <= "0000"; -- Left filter this time
              state <= 5;
            when 5 =>
              leds  <= "0010";
              state <= 6;
            when 6 =>
              leds  <= "0100";
              if stop_r = '1' then
                state   <= 7;
                start_r <= '0';
                stop_r  <= '0';
              end if;
            when 7 =>
              leds  <= "0010";
              state <= 0;
          end case;

        end if;

      end if;
    end if;
  end process;

end architecture;

