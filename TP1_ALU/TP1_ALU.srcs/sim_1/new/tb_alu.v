`timescale 1ns / 1ps

/*
 * Testbench de la ALU
 *
 * Objetivos:
 *  - Verificar todas las operaciones implementadas.
 *  - Generar operandos aleatorios.
 *  - Calcular automáticamente el resultado esperado.
 *  - Comparar el resultado esperado con la salida real de la ALU.
 *
 * El testbench es utilizado solamente durante la simulacion.
 * No forma parte del hardware sintetizado en la FPGA.
 */

module tb_alu;

    /*
     * Debe coincidir con el ancho utilizado en la ALU.
     * Podemos modificarlo posteriormente para comprobar
     * que la parametrizacion funciona correctamente.
     */
    parameter DATA_WIDTH = 8;

    /*
     * Cantidad de pruebas aleatorias que realizaremos
     * para cada operacion.
     *
     * Con 100 pruebas y 8 operaciones:
     *      100 x 8 = 800 pruebas aleatorias.
     */
    parameter TESTS_PER_OP = 100;


    /*
     * Codigos de operacion definidos por el enunciado.
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
     * Cantidad de bits utilizados para indicar
     * el desplazamiento.
     */
    localparam SHIFT_WIDTH =
        (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH);


    /*
     * Entradas que el testbench aplicara a la ALU.
     *
     * Son reg porque el testbench les asigna valores.
     */
    reg [DATA_WIDTH-1:0] A;
    reg [DATA_WIDTH-1:0] B;
    reg [5:0]            Op;


    /*
     * Salida producida por la ALU.
     *
     * Es wire porque es conducida por el modulo
     * que estamos probando.
     */
    wire [DATA_WIDTH-1:0] S;


    /*
     * Contadores utilizados para presentar
     * un resumen al finalizar la simulacion.
     */
    integer tests;
    integer errors;
    integer i;


    /*
     * Instancia del Device Under Test (DUT).
     *
     * Estamos creando una instancia real del modulo alu
     * y conectando las señales del testbench con sus puertos.
     */
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .A  (A),
        .B  (B),
        .Op (Op),
        .S  (S)
    );


    /*
     * Modelo de referencia.
     *
     * Esta funcion calcula cual DEBERIA ser el resultado.
     *
     * Luego compararemos este valor con la salida real
     * producida por la ALU.
     */
    function [DATA_WIDTH-1:0] reference_model;

        input [DATA_WIDTH-1:0] a;
        input [DATA_WIDTH-1:0] b;
        input [5:0]            op;

        reg [SHIFT_WIDTH-1:0] shift_amount;

        begin

            shift_amount = b[SHIFT_WIDTH-1:0];

            case (op)

                OP_ADD:
                    reference_model = a + b;

                OP_SUB:
                    reference_model = a - b;

                OP_AND:
                    reference_model = a & b;

                OP_OR:
                    reference_model = a | b;

                OP_XOR:
                    reference_model = a ^ b;

                OP_SRA:
                    reference_model =
                        $signed(a) >>> shift_amount;

                OP_SRL:
                    reference_model =
                        a >> shift_amount;

                OP_NOR:
                    reference_model =
                        ~(a | b);

                default:
                    reference_model =
                        {DATA_WIDTH{1'b0}};

            endcase
        end

    endfunction


    /*
     * Chequeo automatico.
     *
     * Compara la salida del DUT contra el resultado
     * calculado por el modelo de referencia.
     */
    task check_result;

        reg [DATA_WIDTH-1:0] expected;

        begin

            expected = reference_model(A, B, Op);

            tests = tests + 1;

            /*
             * !== permite detectar tambien valores
             * indefinidos X o Z durante la simulacion.
             */
            if (S !== expected) begin

                errors = errors + 1;

                $display(
                    "ERROR | A=%b B=%b Op=%b | S=%b Esperado=%b",
                    A, B, Op, S, expected
                );

            end
        end

    endtask


    /*
     * Ejecuta una prueba aleatoria para
     * una operacion determinada.
     */
    task random_test;

        input [5:0] operation;

        begin

            A  = $random;
            B  = $random;
            Op = operation;

            /*
             * Esperamos 1 ns para permitir que la
             * logica combinacional propague el resultado.
             *
             * Este retardo pertenece solamente al testbench.
             */
            #1;

            check_result;

        end

    endtask


    /*
     * Secuencia principal del testbench.
     */
    initial begin

        tests  = 0;
        errors = 0;

        A  = 0;
        B  = 0;
        Op = 0;

        #1;


        /*
         * Algunas pruebas dirigidas iniciales.
         *
         * Sirven como comprobaciones simples antes
         * de comenzar con las entradas aleatorias.
         */

        A = 5;
        B = 3;
        Op = OP_ADD;
        #1;
        check_result;

        A = 10;
        B = 4;
        Op = OP_SUB;
        #1;
        check_result;

        A = 8'b10101010;
        B = 8'b11001100;
        Op = OP_AND;
        #1;
        check_result;

        A = 8'b10000000;
        B = 1;
        Op = OP_SRL;
        #1;
        check_result;

        A = 8'b10000000;
        B = 1;
        Op = OP_SRA;
        #1;
        check_result;


        /*
         * Pruebas aleatorias.
         *
         * En cada iteracion se prueba cada una
         * de las ocho operaciones.
         */
        for (i = 0; i < TESTS_PER_OP; i = i + 1) begin

            random_test(OP_ADD);
            random_test(OP_SUB);
            random_test(OP_AND);
            random_test(OP_OR);
            random_test(OP_XOR);
            random_test(OP_SRA);
            random_test(OP_SRL);
            random_test(OP_NOR);

        end


        /*
         * Resumen final.
         */
        $display("");
        $display("======================================");
        $display("       RESULTADO DEL TESTBENCH");
        $display("======================================");     
        $display("Pruebas ejecutadas : %0d", tests);
        $display("Errores encontrados : %0d", errors);

        if (errors == 0)
            $display("RESULTADO: TODAS LAS PRUEBAS PASARON");
        else
            $display("RESULTADO: SE ENCONTRARON ERRORES");

        $display("======================================");
        $display("");

        $finish;

    end

endmodule