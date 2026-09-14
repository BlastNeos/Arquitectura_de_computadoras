## ============================================================
## Basys 3 - TP1 ALU
## FPGA: XC7A35T-1CPG236C
##
## Asignacion:
##   SW0..SW7  -> entrada de datos sw[7:0]
##   LD0..LD7  -> resultado led[7:0]
##
##   BTNL -> load_a
##   BTNR -> load_b
##   BTNU -> load_op
##   BTNC -> rst
##
##   CLK100MHZ -> clk
## ============================================================


## ------------------------------------------------------------
## Clock de placa: 100 MHz
## ------------------------------------------------------------

set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Periodo de un clock de 100 MHz = 10 ns
create_clock -add -name sys_clk_pin -period 10.000 \
    -waveform {0 5} [get_ports clk]


## ------------------------------------------------------------
## Switches SW0 - SW7
## ------------------------------------------------------------

set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]

set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]

set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]

set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]

set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]

set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]

set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]

set_property PACKAGE_PIN W13 [get_ports {sw[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]


## ------------------------------------------------------------
## LEDs LD0 - LD7
## ------------------------------------------------------------

set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]

set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]

set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]


## ------------------------------------------------------------
## Pulsadores
## ------------------------------------------------------------

## Boton izquierdo: cargar operando A
set_property PACKAGE_PIN W19 [get_ports load_a]
set_property IOSTANDARD LVCMOS33 [get_ports load_a]

## Boton derecho: cargar operando B
set_property PACKAGE_PIN T17 [get_ports load_b]
set_property IOSTANDARD LVCMOS33 [get_ports load_b]

## Boton superior: cargar codigo de operacion
set_property PACKAGE_PIN T18 [get_ports load_op]
set_property IOSTANDARD LVCMOS33 [get_ports load_op]

## Boton central: reset
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]