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
		   output logic row_stop,
);

logic reset_count;
logic [7:0] key_out, key_first;
logic [2:0] counter;
logic [3:0] row_now;

// next state logic
typedef enum logic [3:0] {WAIT, INPUT, INPUT_WAIT, HOLD, DEBOUNCE, DEBOUNCE_WAIT} statetype;
statetype state, nextstate;

always_ff @(posedge clk, negedge reset) begin
    if (~reset)              state <= WAIT;
    else                    state <= nextstate;
end


// counter ~50Hz
always_ff @(posedge clk, negedge reset) begin
    if (~reset) 
        counter <= 3'b0;
    else if (~reset_count) 
        counter <= 3'b0;
    else 
        counter <= counter + 3'd2;
end

// value sent to LUT
always_ff @(posedge clk, negedge reset) begin
    if (~reset) begin
        key_out <= 8'b0000_0000;
	end
    else if (state == WAIT && key_col != 4'b0000) begin // capture on first press
        key_out <= key_val;
	end
end


// FSM 
always_comb begin
    reset_count = 1'b0;
    key_valid = 1'b0;
    nextstate = state;
	row_stop = 1'b0;
    case (state)
        WAIT: 
		begin
			if (key_col != 4'b0000 && $countones(key_col) == 1 && key_val[7:4] != 4'b0000) begin // checks to make sure multiple columns are not pressed
				nextstate = INPUT;
					row_stop = 1'b1;
				end
            else                         nextstate = WAIT;
        end
        INPUT: 
		begin
			row_stop = 1'b1;
            reset_count = 1'b0; // reset counter to wait 40 Mhz
            nextstate = INPUT_WAIT;
        end
        INPUT_WAIT: 
		begin
			row_stop = 1'b1;
            reset_count = 1'b1;
            if (counter[2]) begin
                    key_valid = 1'b1;
                    nextstate = HOLD;
			end
            else             nextstate = INPUT_WAIT;
        end
        HOLD: 
		begin
			row_stop = 1'b1;
            if (key_col == 4'b0000) nextstate = DEBOUNCE; // wait for key release
            else                    nextstate = HOLD;
            
        end
        DEBOUNCE: 
		begin
			row_stop = 1'b1;
            reset_count = 1'b0;
            nextstate = DEBOUNCE_WAIT;
        end
        DEBOUNCE_WAIT: 
		begin
			row_stop = 1'b1;
            reset_count = 1'b1;
            if (counter[2]) nextstate = WAIT;
            else          nextstate = DEBOUNCE_WAIT;
        end
    endcase
end

// keypad look up table
keypadLUT key_dut(.key_out(key_out), .key_valid(key_valid), .key(key));


endmodule
