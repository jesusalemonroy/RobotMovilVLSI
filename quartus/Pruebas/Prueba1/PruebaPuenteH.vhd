library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PruebaPuenteH is
    Port (
        -- Entradas
        SW_ENABLE  : in  STD_LOGIC;  -- SW[0]: '1' = Sistema habilitado, '0' = Paro maestro
        SENSOR_LUZ : in  STD_LOGIC;  -- Salida digital del LM339 ('0' = Con luz, '1' = Tapado)
        
        -- Salidas físicas hacia el puente H L293D
        PIN_12EN   : out STD_LOGIC;  -- Pin 1 (o Pin 9) del L293D
        PIN_1A     : out STD_LOGIC;  -- Pin 2 (o Pin 10) del L293D
        PIN_2A     : out STD_LOGIC;  -- Pin 7 (o Pin 15) del L293D
        
        -- Salidas de diagnóstico hacia los LEDs de la DE10-Lite
        LED_1A     : out STD_LOGIC;  -- LEDR[0]: Encendido = Motor avanzando (Con luz)
        LED_2A     : out STD_LOGIC;  -- LEDR[1]: Encendido = Motor detenido (Tapado)
        LED_SENSOR : out STD_LOGIC   -- LEDR[2]: Encendido = Hay luz detectada
    );
end PruebaPuenteH;

architecture Behavioral of PruebaPuenteH is
    signal hay_luz      : STD_LOGIC;
    signal motor_activo : STD_LOGIC;
begin
    -- Invertimos la señal cruda del sensor: '1' cuando recibe luz, '0' cuando está tapado
    hay_luz <= not SENSOR_LUZ;

    -- El motor avanza solo si SW[0] está arriba Y hay luz
    motor_activo <= SW_ENABLE and hay_luz;

    -- Salidas hacia el L293D
    PIN_12EN <= motor_activo;  -- '1' con luz y SW[0]='1'; '0' al taparlo
    PIN_1A   <= motor_activo;  -- '1' para girar adelante; '0' para detenerse
    PIN_2A   <= '0';           -- Fijo en '0'
    
    -- Diagnóstico visual en los LEDs
    LED_1A     <= motor_activo;      -- LEDR[0] encendido = motor avanzando
    LED_2A     <= not motor_activo;  -- LEDR[1] encendido = motor detenido
    LED_SENSOR <= hay_luz;           -- LEDR[2] encendido = luz detectada
end Behavioral;