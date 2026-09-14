module uart_top
#(
    parameter N_BITS  = 8,
    parameter SB_TICK = 16,
    parameter N_COUNT = 326
)
(
    input  wire clk,
    input  wire reset,
    input  wire rx,
    output wire tx
);

    // Tick de sobremuestreo para RX y TX.
    wire tick;

    // Datos recibidos desde la PC.
    wire [N_BITS-1:0] param_rec;
    wire rx_done;

    // Operand A, operand B y código de operación.
    wire [N_BITS-1:0] A;
    wire [N_BITS-1:0] B;
    wire [N_BITS-1:0] OP;

    // Resultado de la ALU.
    wire [N_BITS-1:0] RES;

    // Pulso generado por la interfaz para iniciar
    // la transmisión del resultado.
    wire tx_start_res;

    // Sincronización de la entrada UART externa
    // con el dominio de reloj de la FPGA.
    reg rx_meta;
    reg rx_sync;


    /*
     * Sincronizador de dos flip-flops.
     *
     * La señal RX proviene de un dispositivo externo y,
     * por lo tanto, no está sincronizada con clk.
     */
    always @(posedge clk)
    begin
        if (reset)
        begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end
        else
        begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end


    /*
     * Generador del tick de sobremuestreo.
     *
     * Para clk = 100 MHz, baud = 19200 y sobremuestreo x16:
     *
     * N_COUNT ~= 100 MHz / (19200 * 16) ~= 326
     */
    baudrategen #(
        .N_COUNT(N_COUNT)
    )
    u_baudrategen (
        .clock(clk),
        .reset(reset),
        .tick(tick)
    );


    /*
     * Receptor UART.
     *
     * Recibe los bytes enviados desde la PC.
     */
    uart_rx #(
        .N_BITS(N_BITS),
        .SB_TICK(SB_TICK)
    )
    u_uart_rx (
        .clk(clk),
        .reset(reset),
        .rx(rx_sync),
        .s_tick(tick),
        .rx_done_tick(rx_done),
        .dout(param_rec)
    );


    /*
     * Interfaz entre UART y ALU.
     *
     * Los bytes recibidos se interpretan secuencialmente como:
     *   1° byte -> A
     *   2° byte -> B
     *   3° byte -> OP
     *
     * Luego del tercer byte se solicita transmitir el resultado.
     */
    uart_interface #(
        .N_BITS(N_BITS)
    )
    u_uart_interface (
        .clk(clk),
        .reset(reset),
        .i_dato_Recv(param_rec),
        .i_dato_Recv_valid(rx_done),
        .o_tx_start(tx_start_res),
        .o_A(A),
        .o_B(B),
        .o_OP(OP)
    );


    /*
     * Unidad Aritmético-Lógica.
     */
    ALU #(
        .N_BITS(N_BITS),
        .N_LEDS(N_BITS)
    )
    u_ALU (
        .o_res(RES),
        .i_A(A),
        .i_B(B),
        .i_Op(OP)
    );


    /*
     * Transmisor UART.
     *
     * Envía a la PC el resultado producido por la ALU.
     */
    uart_tx #(
        .N_BITS(N_BITS),
        .SB_TICK(SB_TICK)
    )
    u_uart_tx (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start_res),
        .s_tick(tick),
        .din(RES),
        .tx_done_tick(),
        .tx(tx)
    );

endmodule