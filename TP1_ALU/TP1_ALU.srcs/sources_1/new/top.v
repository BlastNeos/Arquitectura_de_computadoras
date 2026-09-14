`timescale 1ns / 1ps

/*
 * Modulo superior del Trabajo Practico N°1.
 *
 * Integra:
 *  - dos registros para almacenar los operandos A y B;
 *  - un registro de 6 bits para almacenar el codigo de operacion;
 *  - la ALU parametrizable.
 *
 * Los mismos switches se reutilizan para cargar A, B y Op.
 * Cada valor se almacena mediante su correspondiente señal load.
 *
 * La salida de la ALU se conecta directamente a los LEDs.
 */

module top #(
    parameter DATA_WIDTH = 8
)(
    input  wire                    clk,
    input  wire                    rst,

    // Señales de carga de los tres registros.
    input  wire                    load_a,
    input  wire                    load_b,
    input  wire                    load_op,

    // Switches utilizados para ingresar los datos.
    input  wire [DATA_WIDTH-1:0]   sw,

    // Resultado de la ALU mostrado en los LEDs.
    output wire [DATA_WIDTH-1:0]   led
);

    /*
     * Señales internas.
     *
     * Contienen los valores almacenados en los registros.
     */
    wire [DATA_WIDTH-1:0] a_reg;
    wire [DATA_WIDTH-1:0] b_reg;
    wire [5:0]            op_reg;


    /*
     * Registro del operando A.
     *
     * Cuando load_a = 1 en un flanco ascendente del clock,
     * se almacena el valor actual de los switches.
     */
    register #(
        .WIDTH(DATA_WIDTH)
    ) reg_a (
        .clk      (clk),
        .rst      (rst),
        .load     (load_a),
        .data_in  (sw),
        .data_out (a_reg)
    );


    /*
     * Registro del operando B.
     *
     * Utiliza el mismo bus de switches que el registro A,
     * pero posee una señal de carga independiente.
     */
    register #(
        .WIDTH(DATA_WIDTH)
    ) reg_b (
        .clk      (clk),
        .rst      (rst),
        .load     (load_b),
        .data_in  (sw),
        .data_out (b_reg)
    );


    /*
     * Registro del codigo de operacion.
     *
     * Op posee solamente 6 bits, por lo que se utilizan
     * los seis bits menos significativos de los switches.
     */
    register #(
        .WIDTH(6)
    ) reg_op (
        .clk      (clk),
        .rst      (rst),
        .load     (load_op),
        .data_in  (sw[5:0]),
        .data_out (op_reg)
    );


    /*
     * Instancia de la ALU.
     *
     * Las entradas provienen de los valores almacenados
     * previamente en los tres registros.
     *
     * Su salida se conecta directamente al bus de LEDs.
     */
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) alu_inst (
        .A  (a_reg),
        .B  (b_reg),
        .Op (op_reg),
        .S  (led)
    );

endmodule