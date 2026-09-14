module uart_tx
#(
    parameter N_BITS  = 8,
    parameter SB_TICK = 16
)
(
    input  wire              clk,
    input  wire              reset,
    input  wire              tx_start,
    input  wire              s_tick,
    input  wire [N_BITS-1:0] din,

    output reg               tx_done_tick,
    output wire              tx
);

    /*
     * Estados de la FSM del transmisor UART.
     */
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;


    reg [1:0] state_reg;
    reg [1:0] state_next;


    /*
     * Contador de ticks dentro de cada bit.
     */
    reg [3:0] s_reg;
    reg [3:0] s_next;


    /*
     * Contador de bits transmitidos.
     */
    localparam N_COUNTER_WIDTH = $clog2(N_BITS);

    reg [N_COUNTER_WIDTH-1:0] n_reg;
    reg [N_COUNTER_WIDTH-1:0] n_next;


    /*
     * Registro de desplazamiento.
     */
    reg [N_BITS-1:0] b_reg;
    reg [N_BITS-1:0] b_next;


    /*
     * Registro de salida UART.
     */
    reg tx_reg;
    reg tx_next;


    /*
     * Registros secuenciales.
     */
    always @(posedge clk)
    begin
        if (reset)
        begin
            state_reg <= IDLE;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
            tx_reg    <= 1'b1;
        end
        else
        begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
            tx_reg    <= tx_next;
        end
    end


    /*
     * Lógica de próximo estado y salida.
     */
    always @(*)
    begin

        state_next = state_reg;
        s_next     = s_reg;
        n_next     = n_reg;
        b_next     = b_reg;
        tx_next    = tx_reg;

        tx_done_tick = 1'b0;


        case (state_reg)

            /*
             * Línea UART inactiva en nivel alto.
             */
            IDLE:
            begin
                tx_next = 1'b1;

                if (tx_start)
                begin
                    b_next     = din;
                    s_next     = 0;
                    state_next = START;
                end
            end


            /*
             * Start bit = 0.
             */
            START:
            begin
                tx_next = 1'b0;

                if (s_tick)
                begin
                    if (s_reg == (SB_TICK - 1))
                    begin
                        s_next     = 0;
                        n_next     = 0;
                        state_next = DATA;
                    end
                    else
                    begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end


            /*
             * Transmisión de los datos.
             *
             * UART transmite el bit menos significativo
             * primero.
             */
            DATA:
            begin
                tx_next = b_reg[0];

                if (s_tick)
                begin
                    if (s_reg == (SB_TICK - 1))
                    begin
                        s_next = 0;

                        b_next = b_reg >> 1;

                        if (n_reg == (N_BITS - 1))
                        begin
                            n_next     = 0;
                            state_next = STOP;
                        end
                        else
                        begin
                            n_next = n_reg + 1'b1;
                        end
                    end
                    else
                    begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end


            /*
             * Stop bit = 1.
             */
            STOP:
            begin
                tx_next = 1'b1;

                if (s_tick)
                begin
                    if (s_reg == (SB_TICK - 1))
                    begin
                        s_next      = 0;
                        state_next  = IDLE;
                        tx_done_tick = 1'b1;
                    end
                    else
                    begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end


            /*
             * Recuperación ante estado inválido.
             */
            default:
            begin
                state_next = IDLE;
                s_next     = 0;
                n_next     = 0;
                b_next     = 0;
                tx_next    = 1'b1;
            end

        endcase
    end


    assign tx = tx_reg;

endmodule