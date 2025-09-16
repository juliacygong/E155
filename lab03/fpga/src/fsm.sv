// Julia Gong E155
// fsm.sv
// jgong@g.hmc.edu
// Date created: 9/11/2025
// This module creates the FSM for the keypad

module fsm(input logic clk, reset,
           input logic [7:0] key_val,
           input logic [3:0] key_col, 
           output logic [3:0] key,
           output logic key_valid
);

logic reset_count;
logic [7:0] key_out, key_first;
logic [23:0] counter;


typedef enum logic [3:0] {Wait, Input, Input_wait, Hold, Debounce, Debounce_wait} statetype;
statetype state, nextstate;

always_ff @(posedge clk, negedge reset) begin
    if (~reset)              state <= Wait;
    else                    state <= nextstate;
end

always_ff @(posedge clk, negedge reset) begin
    if (~reset) 
        counter <= 3'b0;
    else if (reset_count) 
        counter <= 3'b0;
    else 
        counter <= counter + 3'd5;
end


always_ff @(posedge clk, negedge reset) begin
    if (~reset) begin
        key_first <= 8'b0000_0000;
	end
    else if (state == Wait && key_val != 8'b0000_0000) begin // capture on first press
        key_first <= key_val;
	end
end


// output register for key_out
always_ff @(posedge clk, negedge reset) begin
    if (~reset) key_out <= 8'd0000_0000;
    else if (key_valid) key_out <= key_first;
end

// FSM 
always_comb begin
    reset_count = 1'b0;
    key_valid = 1'b0;
    nextstate = state;
    case (state)
        Wait: 
		begin
			//led_out = 3'b001;
            if (key_val != 8'b0000_0000) nextstate = Input;
            else                         nextstate = Wait;
        end
        Input: 
		begin
			//led_out = 3'b010;
            reset_count = 1'b1; // reset counter to wait 40 Mhz
            nextstate = Input_wait;
        end
        Input_wait: 
		begin
            //reset_count = 1'b0;
			//led_out = 3'b100;
            if (counter[23]) begin
                if (key_val == key_first) begin
                    key_valid = 1'b1;
                    nextstate = Hold;
				end
                else         nextstate = Wait; // key changed or released during debounce (ignore)
			end
            else             nextstate = Input_wait;
        end
        Hold: 
		begin
			//led_out = 3'b011;
            if (key_col == 4'b0000) nextstate = Debounce; // wait for key release
            else                    nextstate = Hold;
            
        end
        Debounce: 
		begin
			//led_out = 3'b101;
            reset_count = 1'b1;
            nextstate = Debounce_wait;
        end
        Debounce_wait: 
		begin
			//led_out = 3'b111;
            reset_count = 1'b0;
            if (counter[23]) nextstate = Wait;
            else             nextstate = Debounce_wait;
        end
    endcase
end

keypadLUT key_dut(.key_out(key_out), .key_valid(key_valid), .key(key));


endmodule
