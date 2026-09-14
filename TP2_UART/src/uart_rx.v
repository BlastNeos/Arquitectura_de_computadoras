module uart_rx
#(
    parameter N_BITS  = 8,
    parameter SB_TICK = 16
)
(
    input  wire              clk,
    input  wire              reset,
    input  wire              rx,
    input  wire              s_tick,

    output reg               rx_done_tick,
    output wire [N_BITS-1:0] dout
);

    /*
     * Estados de la FSM del receptor UART.
     */
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;


    /*
     * Estado actual y próximo estado.
     */
    reg [1:0] state_reg;
    reg [1:0] state_next;


    /*
     * s_reg:
     * contador de ticks de sobremuestreo dentro de un bit.
     *
     * Para SB_TICK = 16 cuenta entre 0 y 15.
     */
    reg [3:0] s_reg;
    reg [3:0] s_next;


    /*
     * n_reg:
     * indica qué bit de datos se está recibiendo.
     */
    localparam N_COUNTER_WIDTH = $clog2(N_BITS);

    reg [N_COUNTER_WIDTH-1:0] n_reg;
    reg [N_COUNTER_WIDTH-1:0] n_next;


    /*
     * Registro donde se reconstruye el byte recibido.
     */
    reg [N_BITS-1:0] b_reg;
    reg [N_BITS-1:0] b_next;


    /*
     * Registros de estado.
     */
    always @(posedge clk)
    begin
        if (reset)
        begin
            state_reg <= IDLE;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
        end
        else
        begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
        end
    end


    /*
     * Lógica de próximo estado.
     */
    always @(*)
    begin

        state_next  = state_reg;
        s_next      = s_reg;
        n_next      = n_reg;
        b_next      = b_reg;

        rx_done_tick = 1'b0;


        case (state_reg)

            /*
             * UART permanece en 1 cuando la línea está inactiva.
             * La detección de un 0 indica el posible comienzo
             * de un start bit.
             */
            IDLE:
            begin
                if (~rx)
                begin
                    state_next = START;
                    s_next     = 0;
                end
            end


            /*
             * Se espera hasta aproximadamente la mitad
             * del start bit para comprobar que continúa en 0.
             */
            START:
            begin
                if (s_tick)
                begin
                    if (s_reg == ((SB_TICK / 2) - 1))
                    begin
                        if (~rx)
                        begin
                            state_next = DATA;
                            s_next     = 0;
                            n_next     = 0;
                        end
                        else
                        begin
                            /*
                             * Falso start bit.
                             */
                            state_next = IDLE;
                        end
                    end
                    else
                    begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end


            /*
             * Cada bit se muestrea cada SB_TICK pulsos.
             */
            DATA:
            begin
                if (s_tick)
                begin
                    if (s_reg == (SB_TICK - 1))
                    begin
                        s_next = 0;

                        /*
                         * UART transmite LSB primero.
                         * El desplazamiento reconstruye el byte.
                         */
                        b_next = {
                            rx,
                            b_reg[N_BITS-1:1]
                        };

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
             * Se verifica el bit de stop.
             */
            STOP:
            begin
                if (s_tick)
                begin
                    if (s_reg == (SB_TICK - 1))
                    begin
                        s_next     = 0;
                        state_next = IDLE;

                        /*
                         * Sólo se considera válido el byte
                         * si el stop bit se encuentra en 1.
                         */
                        if (rx)
                            rx_done_tick = 1'b1;
                    end
                    else
                    begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end


            /*
             * Recuperación ante un estado inválido.
             */
            default:
            begin
                state_next = IDLE;
                s_next     = 0;
                n_next     = 0;
                b_next     = 0;
            end

        endcase
    end


    assign dout = b_reg;

endmodule