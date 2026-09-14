module baudrategen
#(
    parameter N_COUNT = 326
)
(
    input  wire clock,
    input  wire reset,
    output wire tick
);

    // Cantidad mínima de bits necesaria para contar hasta N_COUNT - 1.
    localparam COUNTER_WIDTH = $clog2(N_COUNT);

    reg [COUNTER_WIDTH-1:0] count;

    wire reset_counter;

    assign reset_counter = (count == N_COUNT - 1);
    assign tick = reset_counter;

    always @(posedge clock)
    begin
        if (reset)
            count <= 0;
        else if (reset_counter)
            count <= 0;
        else
            count <= count + 1'b1;
    end

endmodule
