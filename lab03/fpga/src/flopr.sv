// Julia Gong E155
// lab3_jg.sv
// jgong@g.hmc.edu
// Date created: 9/11/2025
// This module creates a flip flop to hold the current and past key values for the 7-segment display

module flopr #(parameter WIDTH = 4'd4)
       (input  logic clk, reset,
        input logic en,
        input  logic [WIDTH-1:0] d,
        output logic [WIDTH-1:0] q);

always_ff @(posedge clk, posedge reset)
    if (reset)
        q <= 0;
    else if (en)  
        q <= d;

endmodule
