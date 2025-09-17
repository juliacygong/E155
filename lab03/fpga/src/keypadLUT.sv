// Julia Gong E155
// keypadLUT.sv
// jgong@g.hmc.edu
// Date created: 9/11/2025
// Look up table for keys

module keypadLUT(input logic [7:0] key_out,
                 input logic key_valid,
                 output logic [3:0] key);

logic [7:0] key_real;


// look up table for row and column inputs to keys
always_comb begin
	key = 4'b0000;
	key_real = {key_out[5], key_out[4], key_out[7], key_out[6] , key_out[3:0]};
    if (key_valid) begin
        // outputs signal for 7-segment display
        case (key_real)
            8'b0001_0001: key = 4'b1010; // A
            8'b0001_0010: key = 4'b0000; // 0
            8'b0001_0100: key = 4'b1011; // B
            8'b0001_1000: key = 4'b1111; // F
            8'b0010_0001: key = 4'b0111; // 7
            8'b0010_0010: key = 4'b1000; // 8
            8'b0010_0100: key = 4'b1001; // 9
            8'b0010_1000: key = 4'b1110; // E
            8'b0100_0001: key = 4'b0100; // 4
            8'b0100_0010: key = 4'b0101; // 5
            8'b0100_0100: key = 4'b0110; // 6
            8'b0100_1000: key = 4'b1101; // D
            8'b1000_0001: key = 4'b0001; // 1
            8'b1000_0010: key = 4'b0010; // 2
            8'b1000_0100: key = 4'b0011; // 3
            8'b1000_1000: key = 4'b1100; // C
            default: 	   key = 4'b0000;
        endcase
    end
end

endmodule
