library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator is
  port (
    clk_i        : in  std_logic;
    reset_n_i    : in  std_logic;
    pwm_tick_i   : in  std_logic;
    left_duty_i  : in  std_logic_vector(7 downto 0);
    right_duty_i : in  std_logic_vector(7 downto 0);
    left_pwm_o   : out std_logic;
    right_pwm_o  : out std_logic
  );
end entity;

architecture rtl of pwm_generator is
  signal counter : unsigned(7 downto 0) := (others => '0');
begin
  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if reset_n_i = '0' then
        counter <= (others => '0');
      elsif pwm_tick_i = '1' then
        counter <= counter + 1;
      end if;
    end if;
  end process;
  left_pwm_o <= '1' when left_duty_i = x"FF" or counter < unsigned(left_duty_i) else '0';
  right_pwm_o <= '1' when right_duty_i = x"FF" or counter < unsigned(right_duty_i) else '0';
end architecture;
