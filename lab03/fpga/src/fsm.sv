// Julia Gong E155
// lab3_jg.sv
// jgong@g.hmc.edu
// Date created: 9/11/2025
// This module creates the FSM for the keypad

module fsm(input logic int_osc, reset,
           input logic [7:0] key_val,
           input logic [3:0] key_col, 
           output logic [3:0] key,
           output logic key_valid
);

logic reset_count;
logic [7:0] key_out;
logic [23:0] counter;


typedef enum logic [3:0] {Wait, Input, Input_wait, Hold, Debounce, Debounce_wait} statetype;
statetype state, nextstate;


always_ff @(posedge int_osc, posedge reset) begin
    if (reset) 
        counter <= 24'd0;
    else if (reset_count) 
        counter <= 24'd0;
    else 
        counter <= counter + 24'd18;
end


always_ff @(posedge int_osc, posedge reset) begin
    if (reset)              state <= Wait;
    else                    state <= nextstate;
end

// output register for key_out
always_ff @(posedge int_osc, posedge reset) begin
    if (reset) key_out <= 8'd0000_0000;
    else if (state == Debounce) key_out <= key_val;
end

// FSM 
always_comb begin
    reset_count = 1'b0;
    key_valid = 1'b0;
    nextstate = state;
    key_out = 8'b0000_0000;
    case (state)
        Wait: begin
            key_valid = 1'b0;
            if (key_val != 8'b0000_0000) nextstate = Input;
            else                          nextstate = Wait;
        end
        Input: begin
            reset_count = 1'b1; // reset counter to wait 40 Mhz
            nextstate = Input_wait;
        end
        Input_wait: begin
            reset_count = 1'b0;
            if (counter[23]) nextstate = Hold;
            else             nextstate = Input_wait;
        end
        Hold: begin
            if (key_col == 4'b0000) nextstate = Debounce;
            else                          nextstate = Hold;
            
        end
        Debounce: begin
            key_valid = 1'b1;
            reset_count = 1'b1;
            nextstate = Debounce_wait;
        end
        Debounce_wait: begin
            key_valid = 1'b1;
            reset_count = 1'b0;
            if (counter[23]) nextstate = Wait;
            else             nextstate = Debounce_wait;
        end
    endcase
end

keypadLUT(.key_out(key_out), .key_valid(key_valid), .key(key));


endmodule
