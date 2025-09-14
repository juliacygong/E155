// Julia Gong E155
// testbench_lab3.sv
// jgong@g.hmc.edu
// Date created: 9/13/2025
// This module tests entire keypad system where 

`timescale 1ns/1ps

module testbench_lab3();
logic clk, reset;
logic [3:0] cols;
logic anode1, anode2;
logic [6:0] seg;
logic [31:0] errors;

// instantiate module
lab3_jg dut(reset, cols, anode1, anode2, seg);

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

initial begin
    errors = 0;
    dut.rows = 4'b0000;
    reset = 1; #10; reset = 0; #10;
    
    // anode2 shows previous value and anode1 shows current value

    // column and row input for key
    cols = 4'b0001; dut.rows = 4'b0100; #100;
    #20000500; // wait for debouncing 7'b000_0011
    assert (seg === 7'b000_0011 && anode1 === 1'b0 && anode2 === 1'b1) else begin // B current value
        $display("Error: cols input %b", cols);
        errors = errors + 1; 
    end

    #6500000; // time for counter to switch (80Hz)

    assert (seg === 7'b100_0000 && anode1 === 1'b1 && anode2 === 1'b0) else begin // 0 previous value
        $display("Error: cols input %b", cols);
        errors = errors + 1; 
    end

    #10

    // new input
    cols = 4'b0100; dut.rows = 4'b0001; #100;
    #20000500; // wait for debouncing 
    assert (seg === 7'b001_1001 && anode1 === 1'b0 && anode2 === 1'b1) else begin // 4 current value
        $display("Error: cols input %b", cols);
        errors = errors + 1; 
    end

    #6500000; // time for counter to switch (80Hz)
    assert (seg === 7'b000_0011 && anode1 === 1'b1 && anode2 === 1'b0) else begin // B previous value
        $display("Error: cols input %b", cols);
        errors = errors + 1; 
    end

    #10

    // new input
    cols = 4'b0010; dut.rows = 4'b0010; #100;
    #20000500; // wait for debouncing 
    assert (seg === 7'b000_0000 && anode1 === 1'b0 && anode2 === 1'b1) else begin // 8 current value
        $display("Error: cols input %b", cols);
        errors = errors + 1; 
    end

    #6500000; // time for counter to switch (80Hz)
    assert (seg === 7'b001_1001 && anode1 === 1'b1 && anode2 === 1'b0) else begin // 4 previous value
        $display("Error: cols input %b", cols);
        errors = errors + 1; 
    end

    $display("All tests completed with %d errors", errors);
    $stop;

end


endmodule

