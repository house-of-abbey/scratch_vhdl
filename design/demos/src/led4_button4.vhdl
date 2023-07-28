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
  generic(
    -- Intended to be used for any ROM, e.g. the RISC CPU code
    rom_file_g : string := ""
  );
  port(
    clk     : in  std_logic;
    reset   : in  std_logic;
    incr    : in  std_logic;
    buttons : in  std_logic_vector(3 downto 0);
    leds    : out std_logic_vector(3 downto 0) := "0000"
  );
end entity;


architecture toggle_driven of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 2;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        leds <= "0000";
      else
        leds <= buttons;
      end if;
    end if;
  end process;

end architecture;


architecture button_driven of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 1;

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
  constant button_tab_c : natural := 2;

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


architecture pulse_gen of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 2;

  signal buttons_d : std_logic_vector(3 downto 0);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        buttons_d <= "0000";
        leds      <= "0000";
      else

        if incr = '1' then
          buttons_d <= buttons;
          leds      <= buttons and not buttons_d;
        end if;

      end if;
    end if;
  end process;

end architecture;


architecture shift_register of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 1;

  signal button_d : std_logic := '0';

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        button_d <= '0';
        leds     <= "0000";
      else
        if incr = '1' then
          button_d <= buttons(0);
          -- Could use "leds'high-1" as the upper bound here
          leds <= leds(2 downto 0) & (buttons(0) and not button_d);
        end if;
      end if;
    end if;
  end process;

end architecture;


architecture bishift_register of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 1;

  alias dir_rl is buttons(0);
  alias dir_lr is buttons(3);

  signal dir_rl_d : std_logic := '0';
  signal dir_lr_d : std_logic := '0';
  signal dir_rl_p : std_logic := '0';
  signal dir_lr_p : std_logic := '0';
  signal rl       : std_logic := '0';

begin

  dir_rl_p <= dir_rl and not dir_rl_d;
  dir_lr_p <= dir_lr and not dir_lr_d;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        dir_rl_d <= '0';
        dir_lr_d <= '0';
        rl       <= '0';
        leds     <= "0000";
      else
        if incr = '1' then

          dir_rl_d <= buttons(0);
          dir_lr_d <= buttons(3);

          if dir_rl = '1' and dir_rl_d = '0' then
            rl <= '1';
          elsif dir_lr = '1' and dir_lr_d = '0' then
            rl <= '0';
          end if;

          -- The "all in one" 'i' clause solution is a bit complicated:
          -- if dir_lr_p = '0' and (rl = '1' or dir_rl_p = '1') then
          --   -- Could use "leds'high-1" as the upper bound here
          --   leds <= leds(2 downto 0) & dir_rl_p;
          -- elsif dir_rl_p = '0' and (rl = '0' or dir_lr_p = '1') then
          --   leds <= dir_lr_p & leds(3 downto 1);
          -- end if;

          -- Separating the parts out we get the basic shift action,
          -- followed by what to do to poke a '1' in either end of
          -- the shift register.
          if rl = '1' then
            -- Could use "leds'high-1" as the upper bound here
            leds <= leds(2 downto 0) & '0';
          else
            leds <= dir_lr_p & leds(3 downto 1);
          end if;

          -- Assignments in the above 'if' clause are overwritten by any
          -- that might follow. NB. The tests for both direction pulses are
          -- necessary because and 'if' statement has a priority encoding.
          -- The additional tests ensure exclusivity.
          if dir_rl_p = '1' and dir_lr_p = '0' then
            leds <= leds(2 downto 0) & '1';
          elsif dir_lr_p = '1' and dir_rl_p = '0' then
            leds <= '1' & leds(3 downto 1);
          end if;

        end if;
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
  constant button_tab_c : natural := 1;

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


architecture adder_onehot of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 2;

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
  constant button_tab_c : natural := 2;

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


--
-- Bonnet (hood) lights on 'Kitt', the car from Knight Rider (1982–1986), and subsequent sequels.
-- KITT = "Knight Industries Two Thousand"
-- https://www.youtube.com/watch?v=oNyXYPhnUIs&ab_channel=NBCClassics
--
architecture knight_rider of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 1;

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
  constant button_tab_c : natural := 3;

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
  constant button_tab_c : natural := 3;

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


-- Linear-Feedback Shift Register
--
-- In computing, a linear-feedback shift register (LFSR) is a shift register whose input
-- bit is a linear function of its previous state.
--
-- Applications of LFSRs include generating pseudo-random numbers, pseudo-noise sequences,
-- fast digital counters, and whitening sequences. Both hardware and software implementations
-- of LFSRs are common.
--
-- https://en.wikipedia.org/wiki/Linear-feedback_shift_register#Example_polynomials_for_maximal_LFSRs
--
-- Usually the number of bits in the LFSR is much larger than 4; this is for demonstration
-- purposes only.
--
-- Polynomial for maximal 4-bit LFSR
--          Taps x^ 4321 0
-- x^4 + x^3 + 1 => 1100(1)
--
-- Period (2^n - 1) = 15
--
-- Implementation Reference: https://www.eng.auburn.edu/~strouce/class/elec6250/LFSRs.pdf
--
-- External Feedback Implementation
-- ================================
--
--                  ++------+
--     +------------>\\      \  (x^4 + x^3)
--     |              || XOR  |---------------+
--     |          +->//      /                |
--     |          | ++------+                 |
--     |          |                           |
--     |          |                           |
--     |          |  LED bits(3:0)            |
--     |   +---+  | +---+    +---+    +---+   |
--     |   |   |  | |   |    |   |    |   |   |
-- <---+---+ 3 |<-+-| 2 |<---| 1 |<---| 0 |<--+
--         |   |    |   |    |   |    |   |
--         +---+    +---+    +---+    +---+
--      x^4      x^3      x^2      x^1      x^0
--
architecture lfsr_external of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 1;

  alias start is buttons(0);
  alias stop  is buttons(1);

  signal run : std_logic := '0';

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        run  <= '0';
        -- Must not start as "0000", or it never changes!
        leds <= "1111";
      else

        if start = '1' then
          run <= '1';
        elsif stop = '1' then
          run <= '0';
        end if;

        if run = '1' and incr = '1' then
          -- External Feedback
          leds <= leds(2 downto 0) & (leds(3) xor leds(2));
        end if;

      end if;
    end if;
  end process;

end architecture;


-- Internal Feedback Implementation
-- ================================
--
--     +------------------------+-----------------------------------------+
--     |                        |       LED bits(3:0)                     |
--     |   +---+      +------++ |  +---+    +---+    +---+     +------++  |
--     |   |   |     /      //<-+  |   |    |   |    |   |    /      //<--+
-- <---+---+ 3 |<---|  XOR ||      | 2 |<---| 1 |<---| 0 |<--|  XOR ||
--         |   |     \      \\<----|   |    |   |    |   |    \      \\<-- '0'
--         +---+      +------++    +---+    +---+    +---+     +------++
--      x^4                     x^3      x^2      x^1      x^0
--
--                                                         NB. A XOR '0' = A
--                                                         So this XOR gate is to
--                                                         illustrate the code below only
--
architecture lfsr_internal of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 1;

  alias start is buttons(0);
  alias stop  is buttons(1);

  signal run : std_logic := '0';

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        run  <= '0';
        -- Must not start as "0000", or it never changes!
        leds <= "1111";
      else

        if start = '1' then
          run <= '1';
        elsif stop = '1' then
          run <= '0';
        end if;

        if run = '1' and incr = '1' then
          leds <= (leds(2 downto 0) & '0') xor (leds(3) & "00" & leds(3));
        end if;

      end if;
    end if;
  end process;

end architecture;


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.risc_pkg.all;

architecture risc_cpu of led4_button4 is

  -- 1 - Push Switch tab
  -- 2 - Toggle Switch tab
  -- 3 - Traffic Lights tab
  constant button_tab_c : natural := 2;

  type reg_arr_t is array (0 to 7) of std_logic_vector(3 downto 0);
  signal reg : reg_arr_t := (others => (others => '0'));

  -- Program Counter
  signal pc       : std_logic_vector(8 downto 0) := (others => '0');
  signal pc_value : code_t'element               := (others => '0');
  signal op       : op_t;
  signal o        : natural range 0 to 7;
  signal a        : natural range 0 to 7;
  signal b        : natural range 0 to 7;
  signal wi       : unsigned(8 downto 0);                -- Wait for 'incr'
  signal eif      : std_logic                    := '0'; -- skiping due to if

  -- This ROM method is not ideal as it uses a large multiplexer to select the
  -- instruction. We ought to use a clocked ROM, but we've enough slack on timing
  -- we don't need the grief from an additional clock cycle delay.
  --
  -- A Xilinx IP Core could be made with 13-bit data and a depth of 512 words
  -- from one 18k BlockRAM if required. Or we could use an unregistered LUT RAM
  -- Both can be initialised from a file (MIF format). The LUT RAM's slack is worse.
  --  * LUT RAM:        0.599 ns slack
  --  * constant code : 1.767 ns slack (might be code length dependent)
  --
  constant code : code_t := read_code_from_file(
    filename => rom_file_g,
    arr_size => 2**pc'length
  );

begin

  leds <= reg(7);

  -- Use signals here rather than variable inside the process for ease of
  -- displaying their values in simulation.
  pc_value <= code(to_integer(unsigned(pc)));
  op       <= to_op_code(pc_value(12 downto 9));
  -- Register indexes
  o        <= to_integer(unsigned(pc_value(8 downto 6)));
  a        <= to_integer(unsigned(pc_value(5 downto 3)));
  b        <= to_integer(unsigned(pc_value(2 downto 0)));

  process(clk) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pc  <= (others => '0');
        reg <= (others => (others => '0'));
        wi  <= (others => '0');
        eif <= '0';
      else
        -- The assembler will prevent assignments to reg(6). If the assembled
        -- instruction code does manage to assign reg(6), it will be overwritten
        -- on the next clock cycle.
        reg(6) <= buttons;

        if incr = '1' then
          if wi > 0 then
            wi <= wi - 1;
          end if;
        end if;

        if nor(wi) then -- 'wi' is all zeros
          if eif = '1' then
            pc <= pc + 2;
            eif <= '0';
          else
            pc <= pc + 1;
          end if;

          case op is
            when op_set  => reg(o) <= pc_value(3 downto 0);
            when op_copy => reg(o) <= reg(a);
            when op_and  => reg(o) <= reg(a) and reg(b);
            when op_or   => reg(o) <= reg(a) or  reg(b);
            when op_not  => reg(o) <= not reg(a);
            when op_add  => reg(o) <= reg(a)  +  reg(b);
            when op_sub  => reg(o) <= reg(a)  -  reg(b);

            when op_shft =>
              if pc_value(1) = '0' then
                reg(o) <= pc_value(0) & reg(a)(3 downto 1);
              else
                reg(o) <= reg(a)(2 downto 0) & pc_value(0);
              end if;

            when op_ifbit =>
              if reg(a)(to_integer(unsigned(pc_value(1 downto 0)))) = '1' then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            when op_ifeq =>
              if reg(a) = reg(b) then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            when op_ifgt =>
              if reg(a) > reg(b) then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            when op_ifge =>
              if reg(a) >= reg(b) then
                eif <= '1';
              else
                pc <= pc + 2;
              end if;

            when op_wi   =>
                wi <= unsigned(pc_value(8 downto 0));

            when op_goto =>
                pc  <= pc_value(8 downto 0);
                eif <= '0';

            when others  => null;
          end case;
        end if;

      end if;
    end if;
  end process;

end architecture;
