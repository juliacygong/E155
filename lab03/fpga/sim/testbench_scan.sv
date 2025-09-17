// Julia Gong E155
// testbench_scan.sv
// jgong@g.hmc.edu
// Date created: 9/13/2025
// This module tests the scan module to ensure that the correct key value is being determined

`timescale 1ns/1ps

module testbench_scan();
logic clk, reset;
logic [3:0] key_col, cols, key_row, row_current;
logic [7:0] key_val;
logic [31:0] errors;


// instantiate module
scan dut(clk, reset, cols, row_stop, row_current, key_row, key_col, key_val);

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

initial begin
    errors = 0;
    reset = 0; #1; reset = 1; #1;

    // assertions for each row and column
    cols = 4'b1110; #5;
	wait (key_row == 4'b1110); #1
    assert (key_val === 8'b0001_0001) else begin
        $display ("Error: row = %b and col = %b", key_row, cols);
        errors = errors + 1;
    end

    #1

    cols = 4'b1101; #1;
	wait (key_row == 4'b1101); #1
    assert (key_val === 8'b0010_0010) else begin
        $display ("Error: row = %b and col = %b", key_row, cols);
        errors = errors + 1;
    end

    #1

	cols = 4'b1011; #1;
    wait (key_row == 4'b1011); #1
    assert (key_val === 8'b0100_0100) else begin
        $display ("Error: row = %b and col = %b", key_row, cols);
            errors = errors + 1;
    end

    #1

    cols = 4'b0111; #1;
	wait (key_row == 4'b0111); #1
    assert (key_val === 8'b1000_1000) else begin
        $display ("Error: row = %b and col = %b", key_row, cols);
            errors = errors + 1;
    end
	#1;
	
	cols = 4'b0111; #1;
	wait (key_row == 4'b1011); #1
    assert (key_val === 8'b1000_0100) else begin
        $display ("Error: row = %b and col = %b", key_row, cols);
            errors = errors + 1;
    end
	#1;
	
	cols = 4'b1101; #1;
	wait (key_row == 4'b0111); #1
    assert (key_val === 8'b0010_1000) else begin
        $display ("Error: row = %b and col = %b", key_row, cols);
            errors = errors + 1;
    end
	
	$display("All tests completed with %d errors", errors);
    $stop;
	
end

endmodule
