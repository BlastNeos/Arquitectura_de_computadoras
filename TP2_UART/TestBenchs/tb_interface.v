`timescale 10ns / 1ps //10ns es el semi ciclo, un ciclo entero tiene 20ns osea 50MHz

module tb_interface;
localparam N_BITS = 8;
localparam N_COUNT = 163;
localparam SB_TICK = 16;
reg clk;
reg reset;
wire tick;
reg rx;
wire rx_done_tick;
wire [NB_BITS - 1:0] DatoFinal; 
wire tx_start;

wire [NB_BITS-1 : 0]  A;
wire [NB_BITS-1 : 0]  B;
wire [NB_BITS-1 : 0]  OP;
wire [NB_BITS-1 : 0]  RES;

always #1 clk = ~clk;


initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    clk = 1;
    reset = 1;
    rx = 1;
    //tick = 0;
    //DATO A
    #2 reset = 0;
    #5216 rx = 0;   //start
    #5216 rx = 1;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 1;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 0;   //paridad
    #5216 rx = 1;   //Stop
    #1000 rx = 1;
    
    //DATO B
    #5216 rx = 0;   //start
    #5216 rx = 1;
    #5216 rx = 0;
    #5216 rx = 1;
    #5216 rx = 1;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 1;   //paridad
    #5216 rx = 1;   //Stop
    
    
    //DATO OP
    #5216 rx = 0;   //start
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 1;
    #5216 rx = 0;
    #5216 rx = 0;
    #5216 rx = 1;   //paridad
    #5216 rx = 1;   //Stop
    
    
    #102160 $finish;


end


baudrategen #(
    .N_BITS(N_BITS),
    .N_COUNT(N_COUNT)
)
u_baudrategen(
    .clock(clk),
    .reset(reset),
    .tick(tick)
);

uart_rx #(
    .N_BITS(N_BITS),
    .SB_TICK(SB_TICK)
)
u_uart_rx(
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .s_tick(tick),
    .rx_done_tick(rx_done_tick),
    .dout(DatoFinal)
);

uart_interface #(
    .N_BITS(N_BITS)
)
u_uart_interface(
    .clk(clk),
    .reset(reset),
    .i_dato_Recv(DatoFinal),
    .i_dato_Recv_valid(rx_done_tick),
    .o_tx_start(tx_start),
    .o_A(A),
    .o_B(B),
    .o_OP(OP)
);


uart_tx #(
    .N_BITS(N_BITS),
    .SB_TICK(SB_TICK)
)
u_uart_tx(
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .s_tick(tick),
    .din(RES),
    .tx_done_tick(tx_finish),
    .tx(tx_sal)
);


ALU #(
    .N_BITS(N_BITS),
    .N_LEDS(N_BITS)
)
u_ALU(
    .o_res(RES),
    .i_A(A),
    .i_B(B),
    .i_Op(OP)
);

endmodule
