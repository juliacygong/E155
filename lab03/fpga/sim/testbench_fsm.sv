// Julia Gong E155
// testbench_fsm.sv
// jgong@g.hmc.edu
// Date created: 9/13/2025
// This module tests the fsm to ensure that the inputs are properly being debounced

`timescale 1ns/1ps

module testbench_fsm();
logic clk, int_osc, reset, key_valid;
logic [7:0] key_val;
logic [3:0] key, key_col;
logic [31:0] errors;

// instantiate module
fsm dut(int_osc, reset, key_val, key_col, key, key_valid);

always begin
    clk = 1; #5; clk = 0; #5;
end

// generate 48 MHz clock
initial begin
    int_osc = 0;
    forever #10.417 int_osc = ~int_osc;  // ~48 MHz clock
end

initial begin
    errors = 0;
    reset = 1; #5; reset = 0; #5;

    // one button pressed 
    key_val = 8'b0001_0001; #10000000; // wait for debounce
    #10000; // holding key
    // release key
    key_col = 4'b0000;     #10000500; // wait for debounce
    assert (key_valid === 1'b1 && key === 4'b1010) else begin
        $display("Error: key_val %b", key_val);
        errors = errors + 1;
    end
    #10000500; // wait for debounce

    // one button held down while another key pressed
    key_val = 8'b1000_1000; #10000000; // wait for debounce
    key_val = 8'b0100_0001; #50; // new input
    #10000; // holding key
    key_col = 4'b0000;     #10000500; // wait for debounce
    assert (key_valid === 1'b1 && key === 4'b1100) else begin
        $display("Error: key_val %b", key_val);
        errors = errors + 1;
    end
    #10000500; // wait for debounce


    // two buttons pressed almost at the same time
    key_val = 8'b0100_0010; #30; key_val = 8'b0010_1000; #10000000; // wait for debounce
    #10000; // holding key
    //release key
    key_col = 4'b0000;     #10000500; // wait for debounce
    assert (key_valid === 1'b1 && key === 4'b0101) else begin
        $display("Error: key_val %b", key_val);
        errors = errors + 1;
    end
    #10000500; // wait for debounce

$display("All tests completed with %d errors", errors);
    $stop;


end

endmodule
