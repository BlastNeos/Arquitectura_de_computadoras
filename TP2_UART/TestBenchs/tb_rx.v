`timescale 10ns / 1ps //10ns es el semi ciclo, un ciclo entero tiene 20ns osea 50MHz

module tb_rx;
localparam N_BITS = 8;
localparam N_COUNT = 163;
localparam SB_TICK = 16;
reg clk;
reg reset;
wire tick;
reg rx;
wire rx_done_tick;
wire [N_BITS - 1:0] DatoFinal; 
always #1 clk = ~clk;


initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    clk = 1;
    reset = 1;
    rx = 1;
    //tick = 0;
    
    #2 reset = 0;
    #200rx = 0;
    #200rx = 1;

    //#1 reset = 1;

    //#1 reset = 0;
    
    #400000 $finish;

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
    .SB_TICK(16)
)
u_uart_rx(
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .s_tick(tick),
    .rx_done_tick(rx_done_tick),
    .dout(DatoFinal)
);

endmodule
