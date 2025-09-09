// Julia Gong E155
// testbench_seg.sv
// jgong@g.hmc.edu
// Date created: 9/6/25
// This file tests to see if the 5-bit LED display is showing the sum of the s1 and s2 inputs

`timescale 1ns/1ps 

module testbench_led();
    logic clk, reset;
    logic [3:0] s1, s2;
    logic [4:0] led;
    logic [31:0] errors;

// instantiate device under test
led_display dut(s1, s2, led);

// generate testbench clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

    initial begin
        errors = 0; 
        s1 = 4'b0000; 
        s2 = 4'b0000;

        for (int a = 0; a < 16; a++) begin
            for (int b = 0; b < 16; b++) begin
                // apply inputs on rising edge
                @(posedge clk);
                s1 = a;
                s2 = b;

                // check result on falling edge
                @(negedge clk);
                if (led !== (a + b)) begin
                    $display("Error: inputs = %0d and %0d, output = %0d (expected %0d)",
                             a, b, led, a+b);
                    errors++;
                end
            end
        end

        $display ("All tests completed with %0d errors" , errors);
        $stop;
    end

endmodule

