library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SensorUltra is
    Port (
        -- Reloj y entradas
        CLK_50M    : in  STD_LOGIC;  -- Reloj de 50 MHz (PIN_P11)
        SW_ENABLE  : in  STD_LOGIC;  -- SW[0]: '1' = Activo, '0' = Paro maestro
        SENSOR_LUZ : in  STD_LOGIC;  -- LM339 ('0' = Hay luz, '1' = Tapado/Oscuridad)
        US_ECHO    : in  STD_LOGIC;  -- ECHO del HC-SR04 (con divisor de voltaje o LM339)
        
        -- Salida hacia el HC-SR04
        US_TRIG    : out STD_LOGIC;  -- TRIG del HC-SR04
        
        -- Salidas hacia L293D: Motor A (Izquierdo - Canales 1 y 2)
        PIN_12EN   : out STD_LOGIC;  -- Pin 1 del L293D
        PIN_1A     : out STD_LOGIC;  -- Pin 2 del L293D
        PIN_2A     : out STD_LOGIC;  -- Pin 7 del L293D
        
        -- Salidas hacia L293D: Motor B (Derecho - Canales 3 y 4)
        PIN_34EN   : out STD_LOGIC;  -- Pin 9 del L293D
        PIN_3A     : out STD_LOGIC;  -- Pin 10 del L293D
        PIN_4A     : out STD_LOGIC;  -- Pin 15 del L293D
        
        -- LEDs de diagnóstico en la DE10-Lite
        LED_LUZ    : out STD_LOGIC;  -- LEDR[0]: '1' = Hay luz
        LED_OBS    : out STD_LOGIC;  -- LEDR[1]: '1' = Obstáculo detectado (< 20 cm)
        LED_GIRO   : out STD_LOGIC   -- LEDR[2]: '1' = Maniobra de giro activa
    );
end SensorUltra;

architecture Behavioral of SensorUltra is
    -- Constantes para reloj de 50 MHz (1 ciclo = 20 ns)
    constant TRIG_MAX    : integer := 3000000; -- Periodo de 60 ms
    constant TRIG_PULSO  : integer := 500;     -- Pulso alto de 10 us
    
    -- Fórmula para distancia X en cm: DIST_UMBRAL = X * 2915
    -- Configurado actualmente a 20 cm (20 * 2915 = 58300 ciclos)
    constant DIST_UMBRAL : integer := 58300;   

    signal trig_cnt   : integer range 0 to TRIG_MAX := 0;
    signal echo_cnt   : integer range 0 to TRIG_MAX := 0;
    
    -- Sincronizadores para estabilizar la señal externa ECHO
    signal echo_sync1 : STD_LOGIC := '0';
    signal echo_sync2 : STD_LOGIC := '0';
    signal echo_prev  : STD_LOGIC := '0';
    
    signal obstaculo  : STD_LOGIC := '0';
    signal hay_luz    : STD_LOGIC;
begin

    -- Invertimos el sensor de luz (KY-018 entrega '0' con luz)
    hay_luz <= not SENSOR_LUZ;

    -- Proceso 1: Disparo de TRIG (10 us cada 60 ms) y medición de ECHO
    process(CLK_50M)
    begin
        if rising_edge(CLK_50M) then
            echo_sync1 <= US_ECHO;
            echo_sync2 <= echo_sync1;
            echo_prev  <= echo_sync2;

            -- Contador de periodo del Trigger
            if trig_cnt < TRIG_MAX - 1 then
                trig_cnt <= trig_cnt + 1;
            else
                trig_cnt <= 0;
            end if;

            if trig_cnt < TRIG_PULSO then
                US_TRIG <= '1';
            else
                US_TRIG <= '0';
            end if;

            -- Medición del pulso ECHO
            if echo_sync2 = '1' then
                if echo_cnt < TRIG_MAX then
                    echo_cnt <= echo_cnt + 1;
                end if;
            elsif echo_prev = '1' and echo_sync2 = '0' then
                if (echo_cnt > 100) and (echo_cnt < DIST_UMBRAL) then
                    obstaculo <= '1'; -- Objeto dentro de la distancia X
                else
                    obstaculo <= '0'; -- Camino libre
                end if;
                echo_cnt <= 0;
            else
                echo_cnt <= 0;
            end if;
        end if;
    end process;

    -- Proceso 2: Control de maniobras de los dos motorreductores
    process(SW_ENABLE, hay_luz, obstaculo)
    begin
        if (SW_ENABLE = '0') or (hay_luz = '0') then
            -- ALTO: Sin luz o switch maestro abajo
            PIN_12EN <= '0';  PIN_1A <= '0';  PIN_2A <= '0';
            PIN_34EN <= '0';  PIN_3A <= '0';  PIN_4A <= '0';
            LED_GIRO <= '0';
            
        elsif obstaculo = '1' then
            -- GIRO: Motor A adelante, Motor B en reversa
            PIN_12EN <= '1';  PIN_1A <= '1';  PIN_2A <= '0';
            PIN_34EN <= '1';  PIN_3A <= '0';  PIN_4A <= '1';
            LED_GIRO <= '1';
            
        else
            -- AVANZAR: Ambos motores hacia adelante
            PIN_12EN <= '1';  PIN_1A <= '1';  PIN_2A <= '0';
            PIN_34EN <= '1';  PIN_3A <= '1';  PIN_4A <= '0';
            LED_GIRO <= '0';
        end if;
    end process;

    -- Salidas a LEDs de diagnóstico
    LED_LUZ <= hay_luz;
    LED_OBS <= obstaculo;

end Behavioral;