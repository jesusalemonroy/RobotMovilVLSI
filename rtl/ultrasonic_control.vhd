library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ultrasonic_control is
  generic (
    CLK_HZ          : positive := 50_000_000;
    TRIGGER_US      : positive := 10;
    ECHO_TIMEOUT_US : positive := 30_000;
    OBSTACLE_CM     : positive := 10
  );
  port (
    clk_i         : in  std_logic;
    reset_n_i     : in  std_logic;
    echo_i        : in  std_logic_vector(3 downto 0); -- 0=front,1=left,2=right,3=rear
    trig_o        : out std_logic_vector(3 downto 0);
    obstacle_o    : out std_logic_vector(3 downto 0);
    front_block_o : out std_logic
  );
end entity;

architecture rtl of ultrasonic_control is
  type state_t is (TRIG_HIGH, WAIT_ECHO_HIGH, MEASURE_ECHO, WAIT_ECHO_LOW);
  signal state       : state_t := TRIG_HIGH;
  signal sensor      : natural range 0 to 3 := 0;
  signal timer       : natural := 0;
  signal echo_width  : natural := 0;
  signal trig        : std_logic_vector(3 downto 0) := (others => '0');
  signal obstacles  : std_logic_vector(3 downto 0) := (others => '0');
  signal echo_sync1  : std_logic := '0';
  signal echo_sync2  : std_logic := '0';
  signal echo_prev   : std_logic := '0';
  constant US_TICKS  : positive := CLK_HZ / 1_000_000;
  constant TRIG_TICKS: positive := (CLK_HZ / 1_000_000) * TRIGGER_US;
  constant TIMEOUT_TICKS : positive := (CLK_HZ / 1_000_000) * ECHO_TIMEOUT_US;
  constant OBSTACLE_TICKS: positive := (CLK_HZ / 1_000_000) * 58 * OBSTACLE_CM;
begin
  trig_o <= trig;
  obstacle_o <= obstacles;
  front_block_o <= obstacles(0);

  process (clk_i)
    variable echo_now : std_logic;
  begin
    if rising_edge(clk_i) then
      if reset_n_i = '0' then
        state <= TRIG_HIGH;
        sensor <= 0;
        timer <= 0;
        echo_width <= 0;
        trig <= (others => '0');
        obstacles <= (others => '0');
        echo_sync1 <= '0';
        echo_sync2 <= '0';
        echo_prev <= '0';
      else
        echo_sync1 <= echo_i(sensor);
        echo_sync2 <= echo_sync1;
        echo_prev <= echo_sync2;
        echo_now := echo_sync2;
        trig <= (others => '0');

        case state is
          when TRIG_HIGH =>
            trig(sensor) <= '1';
            if timer >= TRIG_TICKS - 1 then
              timer <= 0;
              state <= WAIT_ECHO_HIGH;
            else
              timer <= timer + 1;
            end if;
          when WAIT_ECHO_HIGH =>
            if echo_now = '1' and echo_prev = '0' then
              timer <= 0;
              echo_width <= 0;
              state <= MEASURE_ECHO;
            elsif timer >= TIMEOUT_TICKS - 1 then
              obstacles(sensor) <= '0';
              timer <= 0;
              state <= WAIT_ECHO_LOW;
            else
              timer <= timer + 1;
            end if;
          when MEASURE_ECHO =>
            if echo_now = '1' then
              if echo_width < TIMEOUT_TICKS then
                echo_width <= echo_width + 1;
              end if;
              if timer >= TIMEOUT_TICKS - 1 then
                obstacles(sensor) <= '0';
                timer <= 0;
                state <= WAIT_ECHO_LOW;
              else
                timer <= timer + 1;
              end if;
            else
              if echo_width > 0 and echo_width <= OBSTACLE_TICKS then
                obstacles(sensor) <= '1';
              else
                obstacles(sensor) <= '0';
              end if;
              timer <= 0;
              state <= WAIT_ECHO_LOW;
            end if;
          when WAIT_ECHO_LOW =>
            if echo_now = '0' then
              if sensor = 3 then
                sensor <= 0;
              else
                sensor <= sensor + 1;
              end if;
              timer <= 0;
              state <= TRIG_HIGH;
            elsif timer >= TIMEOUT_TICKS - 1 then
              if sensor = 3 then
                sensor <= 0;
              else
                sensor <= sensor + 1;
              end if;
              timer <= 0;
              state <= TRIG_HIGH;
            else
              timer <= timer + 1;
            end if;
        end case;
      end if;
    end if;
  end process;
end architecture;
