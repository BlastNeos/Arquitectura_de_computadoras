`timescale 10ns / 1ps //10ns es el semi ciclo, un ciclo entero tiene 20ns osea 50MHz

module tb_tx;
localparam N_BITS = 8;
localparam N_COUNT = 163;
localparam SB_TICK = 16;
reg clk;
reg reset;
wire tick;
reg tx_start;
wire tx_finish;
reg [N_BITS - 1:0] DatoTrasmi; 
wire tx_sal;
always #1 clk = ~clk;


initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    clk = 1;
    reset = 1;
    tx_start = 0;
    DatoTrasmi = 8'b10100111;
    #100 tx_start = 1;
    //tick = 0;
    
    #2 reset = 0;


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

uart_tx #(
    .N_BITS(N_BITS),
    .SB_TICK(SB_TICK)
)
u_uart_tx(
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .s_tick(tick),
    .din(DatoTrasmi),
    .tx_done_tick(tx_finish),
    .tx(tx_sal)
);

endmodule
