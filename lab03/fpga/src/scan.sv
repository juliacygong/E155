// Julia Gong E155
// scan.sv
// jgong@g.hmc.edu
// Date created: 9/11/2025
// This module scans the keyboards for inputs

module scan(input logic clk, reset,
            input logic [3:0] cols, 
			input logic row_stop,
			output logic [3:0] key_row, 
            output logic [3:0] key_col, 
            output logic [7:0] key_val
);

logic [3:0] row_num, c_sync, cols_sync;
logic key_in;

// synchronizer for keypad inputs
always_ff @(posedge clk, negedge reset) begin
	if (~reset) begin
		c_sync <= 4'b1111;
		cols_sync <= 4'b1111;
	end
	else begin
    c_sync <= cols;
    cols_sync <= c_sync;
	end
end

always_ff @(posedge (clk), negedge reset) begin
	if (~reset)
        key_row <= 4'b1110; 
	else if (row_stop) begin
		key_row <= 4'b0000; 
	end
	else if (key_row == 4'b0000) begin
        key_row <= 4'b1110; // Restart rotation when row_stop goes low
    end
	else
        key_row <= {key_row[2:0], key_row[3]};
end


always_comb begin
    key_col = 4'b0000;
    key_val = 8'b0000_0000;
    if (cols_sync != 4'b1111) begin // receives an input so one goes low
        key_col = ~cols_sync; // inverts bits so that col ON is in one hot encoding
		key_val = {~key_row, key_col};
    end

end

endmodule
