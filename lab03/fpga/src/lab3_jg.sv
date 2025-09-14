// Julia Gong E155
// lab3_jg.sv
// jgong@g.hmc.edu
// Date created: 9/11/2025
// This module creates a keyboard scanner than scans for inputs and outputs the last input digits onto a 7 segment display

module lab3_jg(input logic reset,
               input logic [3:0] cols, // keyboard columns
               output logic anode1, anode2,
               output logic [6:0] seg
);

logic int_osc, select; 
logic [3:0] s, sync, cols_sync, key_col; 
logic [23:0] counter;
logic [7:0] key_val; 
logic [3:0] curr_key, prev_key; 


// Internal high-speed oscillator
HSOSC #(.CLKHF_DIV(2'b00)) 
       hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	   
// Counter oscillating at 80Hz
always_ff @(posedge int_osc, posedge reset) begin
    if (reset)		          counter <= 1'b0;
    else              		  counter <= counter + 24'd28;
end

assign select = counter[23];

// synchronizer for keypad inputs
always_ff @(posedge int_osc) begin
    sync <= cols;
    cols_sync <= sync;
end

scan scan_dut(.clk(int_osc), .reset(reset), .cols_sync(cols_sync), .key_col(key_col), .key_val(key_val));

fsm fsm_dut(.int_osc(int_osc), .reset(reset), .key_val(key_val), .key_col(key_col), .key(key), .key_valid(key_valid));

flopr #(4) curr_reg(.clk(int_osc), .reset(reset), .en(key_valid), .d(key), .q(curr_key)); // stores current key

flopr #(4) prev_reg(.clk(int_osc), .reset(reset), .en(key_valid), .d(curr_key), .q(prev_key));

mux mux_dut(.select(select), .s1(prev_key), .s2(curr_key), .s(s), .anode1(anode1), .anode2(anode2)); // change input for mux

seg_display disp(.s(s), .seg(seg));

endmodule
