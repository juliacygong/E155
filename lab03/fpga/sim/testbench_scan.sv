// Julia Gong E155
// testbench_scan.sv
// jgong@g.hmc.edu
// Date created: 9/13/2025
// This module tests the scan module to ensure that the correct key value is being determined

`timescale 1ns/1ps

module testbench_scan();
logic clk, reset;
logic [3:0] key_col, cols_sync;
logic [7:0] key_val;
logic [31:0] errors;

// instantiate module
scan dut(clk, reset, cols_sync, key_col, key_val);

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

initial begin
    errors = 0;
    reset = 1; #1; reset = 0; #1

    // assertions for each row and column
    wait (dut.rows == 4'b1110); cols_sync = 4'b1110; #1;
    assert (key_val === 8'b0001_0001) else begin
        $display ("Error: row = %b and col = %b", dut.rows, cols_sync);
        errors = errors + 1;
    end

    #10

    wait (dut.rows == 4'b1101); cols_sync = 4'b1101; #1;
    assert (key_val === 8'b0010_0010) else begin
        $display ("Error: row = %b and col = %b", dut.rows, cols_sync);
        errors = errors + 1;
    end

    #10

    wait (dut.rows == 4'b1011); cols_sync = 4'b1011; #1;
    assert (key_val === 8'b0100_0100) else begin
        $display ("Error: row = %b and col = %b", dut.rows, cols_sync);
            errors = errors + 1;
    end

    #10

    wait (dut.rows == 4'b0111); cols_sync = 4'b0111; #1;
    assert (key_val === 8'b1000_1000) else begin
        $display ("Error: row = %b and col = %b", dut.rows, cols_sync);
            errors = errors + 1;
    end
end

endmodule