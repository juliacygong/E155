// Julia Gong E155
// scan.sv
// jgong@g.hmc.edu
// Date created: 9/11/2025
// This module scans the keyboards for inputs

module scan(input logic clk, reset,
            input logic [3:0] cols_sync,
            output logic [3:0] key_col, 
            output logic [7:0] key_val
);

logic [3:0] key_row, rows;
logic [1:0] row_num;
logic key_in;


always_ff @(posedge clk, posedge reset) begin
    if (reset)
        row_num <= 0;
    else
        row_num <= row_num + 1'b1;
end

always_comb begin
    rows = 4'b1111; // start with all rows high
    // set the bit low for specific bit number
    case(row_num)
        2'b00:      rows = 4'b1110;
        2'b01:      rows = 4'b1101;
        2'b10:      rows = 4'b1011;
        2'b11:      rows = 4'b0111;
    endcase
end


always_comb begin
    key_row = 4'b0000;
    key_col = 4'b0000;
    key_val = 8'b0000_0000;
    if (cols_sync != 4'b1111) begin // receives an input so one goes low
        key_row = ~rows; // inverts bits so that row ON is in one hot encoding
        key_col = ~cols_sync; // inverts bits so that col ON is in one hot encoding
        key_val = {key_row, key_col};
    end

end

endmodule
