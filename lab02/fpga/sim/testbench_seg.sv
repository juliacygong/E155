// Julia Gong E155
// testbench_seg.sv
// jgong@g.hmc.edu
// Date created: 8/28/25
// This file tests to see if the 7 segment display is displaying the proper hexidecimal value given the input from s[3:0].

`timescale 1ns/1ps 

module testbench_seg();
    logic       clk, reset;
    logic       [3:0] s;
    logic       [6:0] seg, segExpected;
    logic       [31:0] vectornum, errors;
    logic       [13:0] testvectors[10000:0];
    //instantiate device under test
    seg_display dut(s, seg); 
    // generate testbench clock
    always
        begin
            clk = 1; #5; clk = 0; #5;
        end
    //load testvectors at start of test and pulse reset
    initial
        begin
            $readmemb("lab2_testvectors_seg.txt", testvectors);
            vectornum = 0; errors = 0;
            reset = 1; #22; reset = 0;
        end
    // apply testvectors on rising edge of clk
    always @(posedge clk)
        begin
            #1; {s, segExpected} = testvectors[vectornum];
        end
    // check results on falling edge of clk
    always @(negedge clk)
            if(~reset) begin // skip during reset
                if (seg != segExpected) begin // check result
                    $display("Error: inputs = %b", {s});
                    $display("output = %b (%b expected)", seg, segExpected);
                    errors = errors + 1;
        end
        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 14'bx) begin
            $display("%d tests completed with %d errors", vectornum, errors);
            $stop;
            end
        end
endmodule