library ieee;
use ieee.std_logic_1164.all;

entity status_display is
  port (
    state_i     : in  std_logic_vector(2 downto 0);
    goal_i      : in  std_logic;
    light_i     : in  std_logic;
    obstacle_i  : in  std_logic;
    jam_i       : in  std_logic;
    hex0_o      : out std_logic_vector(6 downto 0);
    hex1_o      : out std_logic_vector(6 downto 0);
    led_o       : out std_logic_vector(9 downto 0)
  );
end entity;

architecture rtl of status_display is
begin
  -- Active-low seven-segment encoding for DE10-Lite HEX displays.
  process (all)
  begin
    case state_i is
      when "000" => hex0_o <= "1000000"; -- 0 SEARCH
      when "001" => hex0_o <= "1111001"; -- 1 FOLLOW
      when "010" => hex0_o <= "0100100"; -- 2 AVOID
      when "011" => hex0_o <= "0110000"; -- 3 EDGE
      when "100" => hex0_o <= "0011001"; -- 4 JAM
      when "101" => hex0_o <= "0010010"; -- 5 GOAL
      when others => hex0_o <= "1111111";
    end case;
  end process;
  hex1_o <= "1111111";
  led_o <= "000" & jam_i & obstacle_i & light_i & goal_i & state_i;
end architecture;
