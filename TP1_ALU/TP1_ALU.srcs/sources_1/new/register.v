/*
 * Registro parametrizable con habilitacion de carga.
 *
 * WIDTH define la cantidad de bits almacenados.
 *
 * El registro captura el valor presente en data_in
 * en el flanco ascendente del clock solamente cuando
 * load esta activo.
 *
 * Si load = 0, conserva el valor previamente almacenado.
 *
 * rst permite llevar el registro a cero.
 */

module register #(
    parameter WIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 load,
    input  wire [WIDTH-1:0]     data_in,
    output reg  [WIDTH-1:0]     data_out
);

    /*
     * Logica secuencial.
     *
     * El bloque solo se ejecuta ante un flanco
     * ascendente del reloj.
     */
    always @(posedge clk) begin

        // Reset sincronico: pone el registro en cero.
        if (rst)
            data_out <= {WIDTH{1'b0}};

        // Si load esta activo, almacena el nuevo dato.
        else if (load)
            data_out <= data_in;

        /*
         * Si rst = 0 y load = 0 no se realiza ninguna
         * asignacion, por lo que el registro conserva
         * su valor anterior.
         */

    end

endmodule