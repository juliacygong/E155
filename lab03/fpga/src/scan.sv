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

logic [3:0] row_num, c_sync, cols_sync;
logic row_stop;
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
        key_row <= 4'b1110; 
    else if (row_stop) begin // stop scanning rows when input reciepted
        key_row <= key_row:
    end
    else
        key_row <= {key_row[2:0], key_row[3]};
end


always_comb begin
    key_col = 4'b0000;
    key_val = 8'b0000_0000;
    row_stop = 1'b0;
    if (cols_sync != 4'b1111) begin // receives an input so one goes low
        row_stop = 1'b1;
        key_col = ~cols_sync; // inverts bits so that col ON is in one hot encoding
		key_val = {~key_row, key_col};
    end

end

endmodule
