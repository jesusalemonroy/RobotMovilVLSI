library ieee;
use ieee.std_logic_1164.all;

entity jam_timer is
  generic (
    CLK_HZ       : positive := 50_000_000;
    JAM_SECONDS  : positive := 5
  );
  port (
    clk_i       : in  std_logic;
    reset_n_i   : in  std_logic;
    active_i    : in  std_logic;
    progress_i  : in  std_logic; -- Encoder/progress pulse; hardware sensor is TBD.
    jam_o       : out std_logic
  );
end entity;

architecture rtl of jam_timer is
  constant LIMIT : positive := CLK_HZ * JAM_SECONDS;
  signal count   : natural range 0 to LIMIT := 0;
  signal jam     : std_logic := '0';
begin
  jam_o <= jam;
  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if reset_n_i = '0' then
        count <= 0;
        jam <= '0';
      elsif active_i = '0' or progress_i = '1' then
        count <= 0;
        jam <= '0';
      elsif jam = '0' then
        if count >= LIMIT - 1 then
          jam <= '1';
        else
          count <= count + 1;
        end if;
      end if;
    end if;
  end process;
end architecture;
