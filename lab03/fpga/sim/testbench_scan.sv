// Julia Gong E155
// testbench_scan.sv
// jgong@g.hmc.edu
// Date created: 9/13/2025
// This module tests the scan module to ensure that the correct key value is being determined

`timescale 1ns/1ps

module testbench_scan();
logic clk, reset;
logic [3:0] cols;
logic [7:0] key_vals;
logic [31:0] errors;

// instantiate module
scan dut(clk, reset, cols, key_val)

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

initial begin
    errors = 0;
    dut.rows = 4'b0;
    reset = 1; #10; reset = 0; #10

    // assertions for each row and column
    dut.rows = 4'b1110; cols = 4'b1110; #10;
    assert (key_val === 8'b0001_0001) else begin
        $display ("Error: row = %b and col = %b", dut.rows, cols);
        errors = errors + 1;
    end

    #10

    dut.rows = 4'b1101; cols = 4'b1101; #10;
    assert (key_val === 8'b0010_0010) else begin
        $display ("Error: row = %b and col = %b", dut.rows, cols);
        errors = errors + 1;
    end

    #10

    dut.rows = 4'b1011; cols = 4'b1011; #10;
    assert (key_val === 8'b0100_0100) else begin
        $display ("Error: row = %b and col = %b", dut.rows, cols);
            errors = errors + 1;
    end

    #10

    dut.rows = 4'b0111; cols = 4'b0111; #10;
    assert (key_val === 8'b1000_1000) else begin
        $display ("Error: row = %b and col = %b", dut.rows, cols);
            errors = errors + 1;
    end

    #10

    $display("All tests completed with %d errors", errors);
        $stop;

    end

endmodule
