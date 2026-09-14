`timescale 10ns / 1ps //10ns es el semi ciclo, un ciclo entero tiene 20ns osea 50MHz

module tb_bdr;
localparam N_BITS = 8;
localparam N_COUNT = 163;
reg clk;
reg reset;
wire tick;
always #1 clk = ~clk;

initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    clk = 1;
    reset = 1;
    //tick = 0;
    
    #2 reset = 0;

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

endmodule
