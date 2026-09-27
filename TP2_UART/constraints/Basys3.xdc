###############################################################################
# TP2 - UART + ALU
# Digilent Basys 3 - Artix-7 XC7A35T
#
# Top-level:
#   clk
#   reset
#   rx
#   tx
#   result[7:0]
###############################################################################


###############################################################################
# CLOCK
#
# Oscilador integrado de la Basys 3:
#   Frecuencia = 100 MHz
#   Periodo    = 10 ns
###############################################################################

set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]

create_clock -add \
    -name sys_clk_pin \
    -period 10.000 \
    -waveform {0.000 5.000} \
    [get_ports clk]


###############################################################################
# RESET
#
# Botón central BTNC.
# El diseño utiliza reset activo en nivel alto.
###############################################################################

set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports reset]


###############################################################################
# UART - USB/RS232 (FTDI integrado en Basys 3)
#
# rx : dato recibido por la FPGA desde la PC
# tx : dato transmitido por la FPGA hacia la PC
###############################################################################

set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports rx]
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports tx]


###############################################################################
# LEDs
#
# result[7:0] muestra directamente el resultado de la ALU.
#
# result[0] -> LD0
# result[1] -> LD1
# ...
# result[7] -> LD7
###############################################################################

set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {result[0]}]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {result[1]}]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports {result[2]}]
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports {result[3]}]
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports {result[4]}]
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports {result[5]}]
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports {result[6]}]
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports {result[7]}]


###############################################################################
# CONFIGURACIÓN DEL DISPOSITIVO
###############################################################################

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]