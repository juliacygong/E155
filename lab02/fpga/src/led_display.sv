// Julia Gong E155
// led_display.sv
// jgong@g.hmc.edu
// Date created: 9/5/2025
// This module takes in the inputs for the values of the dual 7-segment display and adds the numbers together to output the sum on an LED display

module led_display(input logic [3:0] s1,
                   input logic [3:0] s2,
                   output logic [4:0] led

); 

logic [4:0] y; 

assign y = s1 + s2; // add values of segment display 1 and 2

assign led[4] = y[4];
assign led[3] = y[3];
assign led[2] = y[2];
assign led[1] = y[1];
assign led[0] = y[0];

endmodule