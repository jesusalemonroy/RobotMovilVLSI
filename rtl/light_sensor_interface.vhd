library ieee;
use ieee.std_logic_1164.all;

-- TODO: Replace this adapter after selecting the final light-sensor hardware.
-- Contract used by the controller: strong_i=goal reached, cmp_i(0)=light ahead.
entity light_sensor_interface is
  port (
    cmp_i          : in  std_logic_vector(3 downto 0);
    strong_i       : in  std_logic;
    goal_reached_o : out std_logic;
    light_ahead_o  : out std_logic
  );
end entity;

architecture placeholder of light_sensor_interface is
begin
  goal_reached_o <= strong_i;
  light_ahead_o  <= cmp_i(0);
end architecture;
