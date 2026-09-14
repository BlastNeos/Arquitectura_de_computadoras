`timescale 1ns / 1ps

module tb_uart_top;

    localparam N_BITS   = 8;
    localparam SB_TICK  = 16;
    localparam N_COUNT  = 326;

    // Clock real de la Basys 3: 100 MHz -> 10 ns.
    localparam CLK_PERIOD = 10;

    // Periodo ideal de un bit a 19200 baud:
    // 1 / 19200 = 52.083 us ~= 52083 ns.
    localparam BIT_PERIOD = 52083;

    reg clk;
    reg reset;
    reg rx;

    wire tx;

    reg [7:0] received_data;

    integer errors;
    integer tests;


    /*
     * Clock de 100 MHz.
     */
    always #(CLK_PERIOD / 2)
        clk = ~clk;


    /*
     * Device Under Test.
     */
    uart_top #(
        .N_BITS(N_BITS),
        .SB_TICK(SB_TICK),
        .N_COUNT(N_COUNT)
    )
    dut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx)
    );


    /*
     * Simula el envío de un byte desde la PC hacia la FPGA.
     *
     * Formato UART:
     *
     * idle = 1
     * start = 0
     * 8 bits de datos, LSB primero
     * stop = 1
     */
    task send_uart_byte;
        input [7:0] data;

        integer i;

        begin
            // Start bit.
            rx = 1'b0;
            #(BIT_PERIOD);

            // Data bits: LSB first.
            for (i = 0; i < 8; i = i + 1)
            begin
                rx = data[i];
                #(BIT_PERIOD);
            end

            // Stop bit.
            rx = 1'b1;
            #(BIT_PERIOD);
        end
    endtask


    /*
     * Recibe y decodifica un byte enviado por la FPGA.
     */
    task receive_uart_byte;
        output [7:0] data;

        integer i;

        begin
            // Esperar comienzo del start bit.
            @(negedge tx);

            // Desde el comienzo del start esperamos 1,5 bits
            // para quedar aproximadamente en el centro
            // del primer bit de datos.
            #(BIT_PERIOD + (BIT_PERIOD / 2));

            // Recibir 8 bits, LSB first.
            for (i = 0; i < 8; i = i + 1)
            begin
                data[i] = tx;
                #(BIT_PERIOD);
            end

            // En este punto deberíamos estar dentro del stop bit.
            if (tx !== 1'b1)
            begin
                $display(
                    "ERROR: stop bit invalido en respuesta UART"
                );
                errors = errors + 1;
            end

            // Completar aproximadamente el stop bit.
            #(BIT_PERIOD / 2);
        end
    endtask


    /*
     * Ejecuta una operación completa:
     *
     * PC -> A
     * PC -> B
     * PC -> OP
     * FPGA -> resultado
     */
    task run_test;
        input [7:0] A;
        input [7:0] B;
        input [7:0] OP;
        input [7:0] expected;

        reg [7:0] result;

        begin
            tests = tests + 1;

            $display(
                "TEST %0d: A=0x%02h B=0x%02h OP=0x%02h",
                tests,
                A,
                B,
                OP
            );

            send_uart_byte(A);
            send_uart_byte(B);

            /*
             * El receptor de la respuesta comienza a esperar antes
             * de enviar OP para no perder el comienzo de la
             * transmisión de salida.
             */
            fork

                begin
                    receive_uart_byte(result);
                end

                begin
                    send_uart_byte(OP);
                end

            join


            if (result === expected)
            begin
                $display(
                    "PASS: resultado = 0x%02h",
                    result
                );
            end
            else
            begin
                $display(
                    "ERROR: esperado=0x%02h recibido=0x%02h",
                    expected,
                    result
                );

                errors = errors + 1;
            end

            // Pequeña separación entre operaciones.
            #(BIT_PERIOD);
        end
    endtask


    initial
    begin

        clk    = 1'b0;
        reset  = 1'b1;
        rx     = 1'b1;

        errors = 0;
        tests  = 0;

        /*
         * Mantener reset durante varios ciclos.
         */
        repeat (10)
            @(posedge clk);

        reset = 1'b0;

        repeat (10)
            @(posedge clk);


        /*
         * ADD
         * 5 + 3 = 8
         */
        run_test(
            8'h05,
            8'h03,
            8'h20,
            8'h08
        );


        /*
         * SUB
         * 10 - 4 = 6
         */
        run_test(
            8'h0A,
            8'h04,
            8'h22,
            8'h06
        );


        /*
         * AND
         * 10101010 & 00001111 = 00001010
         */
        run_test(
            8'hAA,
            8'h0F,
            8'h24,
            8'h0A
        );


        /*
         * OR
         * 10100000 | 00001111 = 10101111
         */
        run_test(
            8'hA0,
            8'h0F,
            8'h25,
            8'hAF
        );


        /*
         * XOR
         * 10101010 ^ 11111111 = 01010101
         */
        run_test(
            8'hAA,
            8'hFF,
            8'h26,
            8'h55
        );


        /*
         * NOR
         * ~(00001111 | 11110000) = 00000000
         */
        run_test(
            8'h0F,
            8'hF0,
            8'h27,
            8'h00
        );


        /*
         * SRA
         *
         * 11110000 >>> 2
         * esperado: 11111100
         *
         * Este caso también verifica que A sea
         * interpretado como signed.
         */
        run_test(
            8'hF0,
            8'h02,
            8'h03,
            8'hFC
        );


        /*
         * SRL
         *
         * 11110000 >> 2
         * esperado: 00111100
         */
        run_test(
            8'hF0,
            8'h02,
            8'h02,
            8'h3C
        );


        /*
         * Resumen.
         */
        $display("");
        $display("------------------------------------");
        $display("Pruebas ejecutadas: %0d", tests);
        $display("Errores detectados: %0d", errors);

        if (errors == 0)
            $display("RESULTADO FINAL: PASS");
        else
            $display("RESULTADO FINAL: FAIL");

        $display("------------------------------------");

        $finish;
    end


    /*
     * Timeout general.
     *
     * Evita que la simulación quede esperando indefinidamente
     * si la FPGA nunca genera una respuesta UART.
     */
    initial
    begin
        #30000000;

        $display("");
        $display("ERROR: timeout general de simulacion.");

        $finish;
    end

endmodule