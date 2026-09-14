/*
 * Unidad Aritmetico-Logica (ALU)
 *
 * Modulo combinacional parametrizable que implementa las
 * operaciones requeridas para el Trabajo Practico N°1.
 *
 * DATA_WIDTH define el ancho del bus de datos, permitiendo
 * reutilizar la ALU posteriormente con otro ancho de palabra,
 * por ejemplo dentro del pipeline del trabajo final.
 *
 * Entradas:
 *   A  : primer operando.
 *   B  : segundo operando.
 *   Op : codigo de 6 bits que selecciona la operacion.
 *
 * Salida:
 *   S  : resultado de la operacion.
 *
 * La ALU es combinacional: no almacena estado y no necesita clock.
 */

module alu #(
    parameter DATA_WIDTH = 8
)(
    input  wire [DATA_WIDTH-1:0] A,
    input  wire [DATA_WIDTH-1:0] B,
    input  wire [5:0]            Op,
    output reg  [DATA_WIDTH-1:0] S
);

    /*
     * Codigos de operacion definidos por el enunciado.
     *
     * Se utilizan localparam para evitar trabajar directamente
     * con valores binarios dentro del case y mejorar la
     * legibilidad del diseño.
     */
    localparam OP_ADD = 6'b100000;
    localparam OP_SUB = 6'b100010;
    localparam OP_AND = 6'b100100;
    localparam OP_OR  = 6'b100101;
    localparam OP_XOR = 6'b100110;
    localparam OP_SRA = 6'b000011;
    localparam OP_SRL = 6'b000010;
    localparam OP_NOR = 6'b100111;


    /*
     * Cantidad de bits necesarios para expresar el desplazamiento.
     *
     * Para DATA_WIDTH = 8:
     *      SHIFT_WIDTH = log2(8) = 3 bits
     *      desplazamientos posibles: 0 a 7 posiciones.
     *
     * Para DATA_WIDTH = 32:
     *      SHIFT_WIDTH = log2(32) = 5 bits
     *      desplazamientos posibles: 0 a 31 posiciones.
     *
     * El caso DATA_WIDTH <= 1 evita obtener un bus de ancho cero.
     */
    localparam SHIFT_WIDTH =
        (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH);


    /*
     * Para las operaciones de desplazamiento se utilizan
     * los bits menos significativos de B como cantidad
     * de posiciones a desplazar.
     *
     * Ejemplo con DATA_WIDTH = 8:
     *      shift_amount = B[2:0]
     */
    wire [SHIFT_WIDTH-1:0] shift_amount;

    assign shift_amount = B[SHIFT_WIDTH-1:0];


    /*
     * Logica combinacional de la ALU.
     *
     * always @(*) indica que el bloque debe reevaluarse
     * cada vez que cambia cualquiera de sus entradas.
     *
     * No existe clock porque la ALU no almacena informacion.
     */
    always @(*) begin

        /*
         * Valor por defecto.
         *
         * Si Op contiene un codigo no implementado,
         * la salida toma el valor cero.
         *
         * Tambien garantiza que S recibe una asignacion
         * para todos los posibles caminos del bloque
         * combinacional.
         */
        S = {DATA_WIDTH{1'b0}};

        case (Op)

            // Suma de los dos operandos.
            OP_ADD:
                S = A + B;

            // Resta: A - B.
            OP_SUB:
                S = A - B;

            // AND bit a bit.
            OP_AND:
                S = A & B;

            // OR bit a bit.
            OP_OR:
                S = A | B;

            // XOR bit a bit.
            OP_XOR:
                S = A ^ B;

            /*
             * Shift Right Arithmetic.
             *
             * Desplaza A hacia la derecha y conserva el signo,
             * replicando el bit mas significativo.
             *
             * $signed(A) hace que A sea interpretado como
             * un numero con signo.
             */
            OP_SRA:
                S = $signed(A) >>> shift_amount;

            /*
             * Shift Right Logical.
             *
             * Desplaza A hacia la derecha e introduce
             * ceros por la izquierda.
             */
            OP_SRL:
                S = A >> shift_amount;

            // NOR bit a bit: primero OR y luego negacion.
            OP_NOR:
                S = ~(A | B);

            /*
             * Codigo de operacion no reconocido.
             * La salida permanece en cero.
             */
            default:
                S = {DATA_WIDTH{1'b0}};

        endcase
    end

endmodule