# Robot móvil VLSI - Quartus / VHDL

Repositorio inicial del control digital descrito en `Proyecto_Final_Diseño_Digital_VLSI.pdf`. El archivo principal es el esquema de Quartus `quartus/robot_top.bdf`; el esquema instancia `robot_core`, que integra los módulos VHDL de `rtl/`.

## Abrir el proyecto

1. Use Intel Quartus Prime **Lite o Standard** con soporte para MAX 10. El formato BDF no se sintetiza en Quartus Prime Pro 23.3 o posterior.
2. Abra `quartus/RobotMovil.qpf`.
3. Revise que `robot_top.bdf` sea el top-level. Si Quartus pide generar/actualizar el símbolo, abra `rtl/robot_core.vhd` y elija **File > Create/Update > Create Symbol Files for Current File**, guardando `robot_core.bsf` en `quartus/`.
4. Antes de programar la placa, asigne los pines físicos a las entradas y salidas según la placa concreta en Pin Planner. El proyecto selecciona MAX 10 10M50DAF484C7G, compatible con DE10-Lite; no fija pines de placa porque el montaje final y el cableado aún deben confirmarse.

## Módulos

| Archivo | Función |
|---|---|
| `clock_divider.vhd` | Enable fraccional para contador PWM de 8 bits a ~18 kHz y tick de 1 ms. |
| `light_sensor_interface.vhd` | Adaptador temporal para sensores de luz; **pendiente de reemplazar** al elegir el modelo. |
| `ultrasonic_control.vhd` | Dispara 4 HC-SR04 de forma secuencial, mide Echo y conserva banderas de obstáculo a menos de 10 cm. |
| `robot_fsm.vhd` | FSM Moore de seis estados: Buscar, Seguir, Esquiva, Giro, Atasco y Meta. |
| `jam_timer.vhd` | Detecta falta de pulsos de progreso por N segundos (5 s por defecto). |
| `motor_control.vhd` | Traduce estados a dirección y duty cycle de cada motor; Giro usa 50%/100%. |
| `pwm_generator.vhd` | PWM compartido de 8 bits, un canal por motor. |
| `status_display.vhd` | Estado en HEX0, HEX1 apagado y alertas/estado en LEDs. |
| `robot_core.vhd` | Integra los bloques anteriores; símbolo del bloque que aparece en el BDF principal. |

## Contratos provisionales de hardware

- `light_cmp_i(0)` significa luz alineada al frente; `light_strong_i` significa meta alcanzada. El adaptador se dejó deliberadamente simple y provisional. Ajustar su lógica y el cableado cuando se seleccione el sensor nuevo.
- `echo_i(0..3)` y `trig_o(0..3)` corresponden a frente, izquierda, derecha y atrás. Los sensores se consultan uno por uno. La FSM usa la bandera frontal; las otras tres quedan disponibles para ampliar la política de navegación.
- `progress_i` debe recibir pulsos de encoder o un indicador externo de avance. Sin ese elemento físico, el temporizador no puede distinguir que el robot está atascado; no conectarlo permanentemente a cero en el montaje final.
- `motor_dir_o(3 downto 0)` = izquierda IN1, izquierda IN2, derecha IN1, derecha IN2. `motor_pwm_o(0)` es PWM izquierdo y `motor_pwm_o(1)` PWM derecho. Conectar a las entradas de un puente H; nunca conectar motores directamente a pines FPGA.
- MAX 10 usa lógica de 3.3 V. Acondicione las señales Echo si el módulo ultrasónico entrega 5 V y comparta GND entre FPGA, sensores y etapa de potencia. La alimentación de motores debe ir por el driver.

## Transiciones adoptadas

Se siguió la tabla de transición del PDF porque las ecuaciones booleanas impresas no son consistentes con dicha tabla. La entrada de meta (`F`) tiene prioridad desde estados móviles Buscar, Seguir, Esquiva y Giro; Meta es absorbente. Atasco escapa a Buscar al terminar la maniobra. En el estado Giro, las condiciones se evalúan en orden: atasco, obstáculo, luz al frente y continuar bordeando.

## Estructura

```text
robot-movil-vlsi/
├── quartus/
│   ├── RobotMovil.qpf
│   ├── RobotMovil.qsf
│   ├── robot_top.bdf       # Top-level esquemático
│   └── robot_core.bsf      # Símbolo jerárquico de robot_core
├── rtl/                    # Entidades VHDL sintetizables
└── docs/
```

El BDF se entrega como esquema principal jerárquico de integración y el bloque `robot_core` instancia cada módulo como entidad VHDL separada. Para mover un módulo individual al nivel gráfico, genere su archivo de símbolo BSF desde Quartus y colóquelo en el Block Diagram Editor.
