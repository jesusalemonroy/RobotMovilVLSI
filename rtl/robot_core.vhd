library ieee;
use ieee.std_logic_1164.all;

-- Hierarchical integration block instantiated by the Quartus schematic.
entity robot_core is
  generic (
    CLK_HZ      : positive := 50_000_000;
    JAM_SECONDS : positive := 5
  );
  port (
    clk_i          : in  std_logic;
    reset_n_i      : in  std_logic;
    light_cmp_i    : in  std_logic_vector(3 downto 0);
    light_strong_i : in  std_logic;
    echo_i         : in  std_logic_vector(3 downto 0);
    progress_i     : in  std_logic;
    trig_o         : out std_logic_vector(3 downto 0);
    motor_dir_o    : out std_logic_vector(3 downto 0); -- L_IN1,L_IN2,R_IN1,R_IN2
    motor_pwm_o    : out std_logic_vector(1 downto 0); -- bit0 left, bit1 right
    hex0_o         : out std_logic_vector(6 downto 0);
    hex1_o         : out std_logic_vector(6 downto 0);
    led_o          : out std_logic_vector(9 downto 0)
  );
end entity;

architecture structural of robot_core is
  signal pwm_tick, ms_tick : std_logic;
  signal goal_reached, light_ahead : std_logic;
  signal obstacles : std_logic_vector(3 downto 0);
  signal front_obstacle, jam, moving : std_logic;
  signal current_state : std_logic_vector(2 downto 0);
  signal left_in1, left_in2, right_in1, right_in2 : std_logic;
  signal left_duty, right_duty : std_logic_vector(7 downto 0);
  signal left_pwm, right_pwm : std_logic;
begin
  u_clock_divider : entity work.clock_divider
    generic map (CLK_HZ => CLK_HZ)
    port map (clk_i, reset_n_i, pwm_tick, ms_tick);

  u_light_sensor_interface : entity work.light_sensor_interface
    port map (light_cmp_i, light_strong_i, goal_reached, light_ahead);

  u_ultrasonic_control : entity work.ultrasonic_control
    generic map (CLK_HZ => CLK_HZ)
    port map (clk_i, reset_n_i, echo_i, trig_o, obstacles, front_obstacle);

  u_jam_timer : entity work.jam_timer
    generic map (CLK_HZ => CLK_HZ, JAM_SECONDS => JAM_SECONDS)
    port map (clk_i, reset_n_i, moving, progress_i, jam);

  u_robot_fsm : entity work.robot_fsm
    port map (clk_i, reset_n_i, goal_reached, light_ahead,
              front_obstacle, jam, current_state);

  u_motor_control : entity work.motor_control
    port map (current_state, left_in1, left_in2, right_in1, right_in2,
              left_duty, right_duty, moving);

  u_pwm_generator : entity work.pwm_generator
    port map (clk_i, reset_n_i, pwm_tick, left_duty, right_duty,
              left_pwm, right_pwm);

  u_status_display : entity work.status_display
    port map (current_state, goal_reached, light_ahead, front_obstacle,
              jam, hex0_o, hex1_o, led_o);

  motor_dir_o <= left_in1 & left_in2 & right_in1 & right_in2;
  motor_pwm_o <= right_pwm & left_pwm;
end architecture;
