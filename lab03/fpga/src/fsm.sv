// Julia Gong E155
// fsm.sv
// jgong@g.hmc.edu
// Date created: 9/11/2025
// This module creates the FSM for the keypad

module fsm(input logic clk, reset,
           input logic [7:0] key_val,
           input logic [3:0] key_col, 
           output logic [3:0] key,
           output logic key_valid,
		   output logic [2:0] led_out,
		   output logic row_stop,
		   output logic [3:0] row_current
);

logic reset_count;
logic [7:0] key_out, key_first;
logic [2:0] counter;
logic [7:0] key_f; 
logic [3:0] row_now;


typedef enum logic [3:0] {WAIT, INPUT, INPUT_WAIT, HOLD, DEBOUNCE, DEBOUNCE_WAIT} statetype;
statetype state, nextstate;

always_ff @(posedge clk, negedge reset) begin
    if (~reset)              state <= WAIT;
    else                    state <= nextstate;
end

always_ff @(posedge clk, negedge reset) begin
    if (~reset) 
        counter <= 3'b0;
    else if (~reset_count) 
        counter <= 3'b0;
    else 
        counter <= counter + 5'd2;
end


always_ff @(posedge clk, negedge reset) begin
    if (~reset) begin
        key_out <= 8'b0000_0000;
	end
    else if (state == WAIT && key_col != 4'b0000) begin // capture on first press
        key_out <= key_val;
	end
end


// output register for key_out
// always_ff @(posedge clk, negedge reset) begin
   // if (~reset) key_out <= 8'd0000_0000;
   // else if (key_valid) key_out <= key_first;
//end

always_ff @(posedge clk, negedge reset)
    if (~reset)
        key_f <= 8'b1111_1111;
    else if (row_stop && state == WAIT)  
        key_f <= key_val;
		//{key_out[5], key_out[4], key_out[7], key_out[6], key_val[3:0]};

// FSM 
always_comb begin
    reset_count = 1'b0;
    key_valid = 1'b0;
    nextstate = state;
	led_out = 3'b000;
	row_stop = 1'b0;
	//row_stop = 1'b0;
    case (state)
        WAIT: 
		begin
			led_out = key_val[6:4];
			row_now = key_val[7:4];
            if (key_col != 4'b0000 && $countones(key_col) == 1 && key_val[7:4] != 4'b0000) begin
				nextstate = INPUT;
					row_current = key_val[7:4]; 
					row_stop = 1'b1;
				end
            else                         nextstate = WAIT;
        end
        INPUT: 
		begin
			row_stop = 1'b1;
			led_out = key_val[6:4];
            reset_count = 1'b0; // reset counter to wait 40 Mhz
            nextstate = INPUT_WAIT;
        end
        INPUT_WAIT: 
		begin
			row_stop = 1'b1;
            reset_count = 1'b1;
			led_out = 3'b100;
            if (counter[2]) begin
                    key_valid = 1'b1;
                    nextstate = HOLD;
			end
            else             nextstate = INPUT_WAIT;
        end
        HOLD: 
		begin
			row_stop = 1'b1;
			led_out = key_val[6:4];
            if (key_col == 4'b0000) nextstate = DEBOUNCE; // wait for key release
            else                    nextstate = HOLD;
            
        end
        DEBOUNCE: 
		begin
			row_stop = 1'b1;
			led_out = key_val[6:4];
            reset_count = 1'b0;
            nextstate = DEBOUNCE_WAIT;
        end
        DEBOUNCE_WAIT: 
		begin
			row_stop = 1'b1;
			led_out = key_val[6:4];
            reset_count = 1'b1;
            if (counter[2]) nextstate = WAIT;
            else          nextstate = DEBOUNCE_WAIT;
        end
    endcase
end

keypadLUT key_dut(.key_out(key_out), .key_valid(key_valid), .key(key));


endmodule
