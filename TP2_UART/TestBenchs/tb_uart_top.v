`timescale 10ns / 1ps //10ns es el semi ciclo, un ciclo entero tiene 20ns osea 50MHz

module tb_uart_top;
localparam N_BITS = 8;
localparam SB_TICK = 16;
localparam N_COUNT = 163;
reg clk;
reg reset;
reg [31:0] c;
always #1 c = c + 1;
always #1 clk = ~clk;
reg tx_start;
reg [N_BITS - 1:0] DatoEnviar;
wire [N_BITS - 1:0] RES;
wire rx_res_done;

initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    c = 0;
    clk = 1;
    reset = 1;
    tx_start = 0;
    DatoEnviar = 8'b10011001;
    #2 reset = 0;
    #2 tx_start = 1;
    #54769
    DatoEnviar = 8'b00011011;
    #54769
    DatoEnviar = 32;

    
    #154769 $finish;

end


uart_top #(
    .N_BITS(8),
    .SB_TICK(16),
    .N_COUNT(163)
)
u_uart_top(
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .ParamEnviar(DatoEnviar),
    .RESULTADO(RES),
    .datoListorti(rx_res_done)
);

endmodule
