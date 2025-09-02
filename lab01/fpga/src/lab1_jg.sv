// Julia Gong E155
// lab1_jg.sv
// jgong@g.hmc.edu
// Date created: 8/28/25
// This module instantiates the 7 segment display that displays a hexidecimal digital that is described by s[3:0] and turns on LEDs based on inputs as well
module lab1_jg #(parameter N = 34'd859)
		(input logic clk, reset, 
		 input logic [3:0] s,
		 output logic [2:0] led,
		 output logic [6:0] seg
);

logic int_osc; 
logic [33:0] counter; 


   // Internal high-speed oscillator
HSOSC #(.CLKHF_DIV(2'b00)) 
       hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	   
// Counter
   always_ff @(posedge int_osc) begin
     if(reset == 1'b0)  counter <= 1'b0;
     else            	counter <= counter + N;
   end
  
  seg_display dut(clk, s, seg);
  
   // Assign LED outputs
   assign led[0] = (s[0] ^ s[1]);
   assign led[1] = (s[3] & s[2]);
   assign led[2] = counter[33];

endmodule