// Julia Gong E155
// lab2_jg.sv
// jgong@g.hmc.edu
// Date created: 9/5/2025
// This module turns on a dual 7-segment display using time multiplexing and outputs the sum of both numbers onto 5 LEDs
// The 7 segment display takes inputs from 8 DIP switches on the development board

module lab2_jg #(parameter N = 24'd28)
               (input logic reset,
               input logic [3:0]s1,
               input logic [3:0]s2,
               output logic anode1, anode2,
               output logic [4:0] led,
               output logic [6:0] seg
);

logic int_osc, select; 
logic [3:0] s;
logic [23:0] counter;

// Internal high-speed oscillator
HSOSC #(.CLKHF_DIV(2'b00)) 
       hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	   
// Counter 
    always_ff @(posedge int_osc) begin
        if(reset == 1'b0)		  counter <= 1'b0;
        else              		  counter <= counter + N;
    end

assign select = counter[23];

mux dut(select, s1, s2, s, anode1, anode2);

seg_display disp1(s, seg);

led_display leds(s1, s2, led);

endmodule