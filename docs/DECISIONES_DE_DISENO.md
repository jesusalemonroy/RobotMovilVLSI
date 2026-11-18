# Decisiones y límites del diseño

## FSM

La tabla de transición del documento se tomó como autoridad. Las ecuaciones booleanas publicadas no coinciden con todos los renglones de esa tabla, así que la FSM se implementó con `case` y condiciones explícitas. Se interpretó `F=1` como meta alcanzada en todos los estados activos de navegación, aunque la tabla solo lo muestra explícitamente en Buscar y Seguir. El estado Meta permanece enclavado hasta reset.

El módulo `motor_control` interpreta el giro de búsqueda y de evasión como pivote diferencial. Para Giro, la velocidad izquierda es 50% y la derecha 100%. La resolución de PWM es de 8 bits y el clock enable se genera por acumulación fraccional para aproximarse a 18 kHz desde 50 MHz.

## Entradas pendientes

La interfaz de luz se deja como adaptador provisional. No contiene modelo de LDR, fotodiodo, ADC, comparador ni calibración. Cuando se conozca el nuevo sensor, se cambia `light_sensor_interface.vhd` y se actualizan los pines del esquema.

El indicador de atasco necesita una medida física de movimiento. Se dejó `progress_i` expuesto para un encoder o sensor equivalente. El temporizador genera `jam_o` tras 5 segundos sin pulsos mientras el controlador ordena movimiento.

## Ultrasónicos

Se implementó un disparo secuencial por sensor para evitar crosstalk, con timeout nominal de 30 ms. La duración de Echo se convierte usando el valor nominal de 58 microsegundos por centímetro. La salida representa una bandera booleana de proximidad, no una distancia numérica en centímetros.

## Integración eléctrica

Las salidas de dirección y PWM son señales lógicas para un driver puente H. La FPGA no entrega corriente para motores. Verificar niveles lógicos, corriente de motor, diodos/driver, regulación y tierras comunes antes de energizar el sistema. Ajustar el Pin Planner a la placa y revisar los niveles de Echo de los HC-SR04.
