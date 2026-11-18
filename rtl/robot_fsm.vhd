library ieee;
use ieee.std_logic_1164.all;

entity robot_fsm is
  port (
    clk_i          : in  std_logic;
    reset_n_i      : in  std_logic;
    goal_i         : in  std_logic;
    light_ahead_i  : in  std_logic;
    obstacle_i     : in  std_logic;
    jam_i          : in  std_logic;
    state_o        : out std_logic_vector(2 downto 0)
  );
end entity;

architecture rtl of robot_fsm is
  type state_t is (SEARCH, FOLLOW, AVOID, EDGE, JAM_ESCAPE, GOAL);
  signal state, next_state : state_t := SEARCH;
begin
  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if reset_n_i = '0' then
        state <= SEARCH;
      else
        state <= next_state;
      end if;
    end if;
  end process;

  process (all)
  begin
    next_state <= state;
    case state is
      when SEARCH =>
        if goal_i = '1' then next_state <= GOAL;
        elsif light_ahead_i = '1' then next_state <= FOLLOW;
        else next_state <= SEARCH;
        end if;
      when FOLLOW =>
        if goal_i = '1' then next_state <= GOAL;
        elsif obstacle_i = '1' then next_state <= AVOID;
        elsif light_ahead_i = '0' then next_state <= SEARCH;
        else next_state <= FOLLOW;
        end if;
      when AVOID =>
        if goal_i = '1' then next_state <= GOAL;
        elsif obstacle_i = '0' then next_state <= EDGE;
        else next_state <= AVOID;
        end if;
      when EDGE =>
        if goal_i = '1' then next_state <= GOAL;
        elsif jam_i = '1' then next_state <= JAM_ESCAPE;
        elsif obstacle_i = '1' then next_state <= AVOID;
        elsif light_ahead_i = '1' then next_state <= FOLLOW;
        else next_state <= EDGE;
        end if;
      when JAM_ESCAPE =>
        next_state <= SEARCH;
      when GOAL =>
        next_state <= GOAL;
    end case;
  end process;

  process (all)
  begin
    case state is
      when SEARCH     => state_o <= "000";
      when FOLLOW     => state_o <= "001";
      when AVOID      => state_o <= "010";
      when EDGE       => state_o <= "011";
      when JAM_ESCAPE => state_o <= "100";
      when GOAL       => state_o <= "101";
    end case;
  end process;
end architecture;
