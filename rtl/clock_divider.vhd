library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
  generic (
    CLK_HZ       : positive := 50_000_000;
    PWM_HZ       : positive := 18_000;
    PWM_BITS     : positive := 8;
    MS_TICK_HZ   : positive := 1_000
  );
  port (
    clk_i       : in  std_logic;
    reset_n_i   : in  std_logic;
    pwm_tick_o  : out std_logic;
    ms_tick_o   : out std_logic
  );
end entity;

architecture rtl of clock_divider is
  constant PWM_STEP : natural := PWM_HZ * (2 ** PWM_BITS);
  signal phase_acc : natural range 0 to CLK_HZ - 1 := 0;
  signal ms_count  : natural range 0 to (CLK_HZ / MS_TICK_HZ) - 1 := 0;
  signal pwm_tick  : std_logic := '0';
  signal ms_tick   : std_logic := '0';
begin
  assert CLK_HZ > PWM_STEP
    report "CLK_HZ must exceed PWM_HZ * 2**PWM_BITS" severity failure;
  assert CLK_HZ mod MS_TICK_HZ = 0
    report "CLK_HZ must be divisible by MS_TICK_HZ" severity warning;

  pwm_tick_o <= pwm_tick;
  ms_tick_o  <= ms_tick;

  process (clk_i)
    variable phase_next : natural;
  begin
    if rising_edge(clk_i) then
      pwm_tick <= '0';
      ms_tick  <= '0';
      if reset_n_i = '0' then
        phase_acc <= 0;
        ms_count  <= 0;
      else
        phase_next := phase_acc + PWM_STEP;
        if phase_next >= CLK_HZ then
          phase_acc <= phase_next - CLK_HZ;
          pwm_tick <= '1';
        else
          phase_acc <= phase_next;
        end if;

        if ms_count = (CLK_HZ / MS_TICK_HZ) - 1 then
          ms_count <= 0;
          ms_tick <= '1';
        else
          ms_count <= ms_count + 1;
        end if;
      end if;
    end if;
  end process;
end architecture;
