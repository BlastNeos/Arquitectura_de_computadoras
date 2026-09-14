`timescale 1ns / 1ps

module top_debug #(
    parameter DATA_WIDTH = 8
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   load_a,
    input  wire                   load_b,
    input  wire                   load_op,
    input  wire [DATA_WIDTH-1:0]  sw,
    output wire [DATA_WIDTH-1:0]  led
);

    // Prueba directa: cada switch controla su LED correspondiente.
    assign led = sw;

endmodule