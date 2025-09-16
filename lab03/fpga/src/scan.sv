// Julia Gong E155
// scan.sv
// jgong@g.hmc.edu
// Date created: 9/11/2025
// This module scans the keyboards for inputs

module scan(input logic clk, reset,
            input logic [3:0] cols, 
            output logic [3:0] key_row,
            output logic [3:0] key_col, 
            output logic [7:0] key_val,
			output logic led_val,
			output logic [2:0] led_col
);

logic [3:0] rows, c_sync, cols_sync;
logic [1:0] row_num;
logic key_in;


// synchronizer for keypad inputs
always_ff @(posedge clk, negedge reset) begin
	if (~reset) begin
		c_sync <= 0;
		cols_sync <= 0;
	end
	else begin
    c_sync <= cols;
    cols_sync <= c_sync;
	end
end

always_ff @(posedge clk, negedge reset) begin
    if (~reset)
        row_num <= 0;
    else
        row_num <= row_num + 1'b1;
end

always_comb begin
    // set the bit low for specific bit number
    case(row_num)
        2'b00:      rows = 4'b1110;
        2'b01:      rows = 4'b1101;
        2'b10:      rows = 4'b1011;
        2'b11:      rows = 4'b0111;
        default:    rows = 4'b1111;
    endcase
end

assign key_row = rows; 

always_comb begin
    key_col = 4'b0000;
    key_val = 8'b0000_0000;
	led_val = 1'b0;
    if (cols_sync != 4'b1111) begin // receives an input so one goes low
        key_col = ~cols_sync; // inverts bits so that col ON is in one hot encoding
        key_val = {~rows, key_col};
		led_val = 1'b1;
		led_col = cols_sync[2:0];
    end
end

endmodule
