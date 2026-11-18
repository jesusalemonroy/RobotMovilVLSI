library ieee;
use ieee.std_logic_1164.all;

entity motor_control is
  port (
    state_i       : in  std_logic_vector(2 downto 0);
    left_in1_o    : out std_logic;
    left_in2_o    : out std_logic;
    right_in1_o   : out std_logic;
    right_in2_o   : out std_logic;
    left_duty_o   : out std_logic_vector(7 downto 0);
    right_duty_o  : out std_logic_vector(7 downto 0);
    moving_o      : out std_logic
  );
end entity;

architecture rtl of motor_control is
begin
  process (all)
  begin
    -- Defaults: both motors stopped.
    left_in1_o <= '0'; left_in2_o <= '0';
    right_in1_o <= '0'; right_in2_o <= '0';
    left_duty_o <= x"00"; right_duty_o <= x"00";
    moving_o <= '0';
    case state_i is
      when "000" => -- SEARCH: left reverse, right forward
        left_in1_o <= '0'; left_in2_o <= '1';
        right_in1_o <= '1'; right_in2_o <= '0';
        left_duty_o <= x"FF"; right_duty_o <= x"FF"; moving_o <= '1';
      when "001" => -- FOLLOW: forward
        left_in1_o <= '1'; left_in2_o <= '0';
        right_in1_o <= '1'; right_in2_o <= '0';
        left_duty_o <= x"FF"; right_duty_o <= x"FF"; moving_o <= '1';
      when "010" => -- AVOID: opposite pivot
        left_in1_o <= '1'; left_in2_o <= '0';
        right_in1_o <= '0'; right_in2_o <= '1';
        left_duty_o <= x"FF"; right_duty_o <= x"FF"; moving_o <= '1';
      when "011" => -- EDGE: left at 50%, right at 100%
        left_in1_o <= '1'; left_in2_o <= '0';
        right_in1_o <= '1'; right_in2_o <= '0';
        left_duty_o <= x"80"; right_duty_o <= x"FF"; moving_o <= '1';
      when "100" => -- JAM_ESCAPE: reverse
        left_in1_o <= '0'; left_in2_o <= '1';
        right_in1_o <= '0'; right_in2_o <= '1';
        left_duty_o <= x"FF"; right_duty_o <= x"FF"; moving_o <= '1';
      when others => null; -- GOAL and invalid states: brake/coast with EN low
    end case;
  end process;
end architecture;
