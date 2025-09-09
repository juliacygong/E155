// Julia Gong E155
// testbench_mux.sv
// jgong@g.hmc.edu
// Date created: 8/28/25
// This file tests to see if the 7 segment display is displaying the proper hexidecimal value given the input from s[3:0].

`timescale 1ns/1ps 

module testbench_mux();
    logic       clk, reset;
	logic 		select;
	logic 		[3:0] s1, s2;
    logic       [3:0] s, sExpected;
    logic       anode1, anode1Expected, anode2, anode2Expected;
    logic       [31:0] vectornum, errors;
    logic       [14:0] testvectors[10000:0];
    //instantiate device under test
    mux dut(select, s1, s2, s, anode1, anode2); 
    // generate testbench clock
    always
        begin
            clk = 1; #5; clk = 0; #5;
        end
    //load testvectors at start of test and pulse reset
    initial
        begin
            $readmemb("lab2_testvectors_mux.txt", testvectors);
            vectornum = 0; errors = 0;
            reset = 1; #22; reset = 0;
        end
    // apply testvectors on rising edge of clk
    always @(posedge clk)
        begin
            #1; {select, s1, s2, sExpected, anode1Expected, anode2Expected} = testvectors[vectornum];
        end
    // check results on falling edge of clk
    always @(negedge clk)
            if(~reset) begin // skip during reset
                if (s != sExpected) begin // check result
                    $display("Error: inputs = %b and %b and %b", select, s1, s2);
                    $display("output = %b (%b expected)", s, sExpected);
                    errors = errors + 1;
				end
				else if (anode1 != anode1Expected) begin
					$display("Error: inputs = %b and %b and %b", select, s1, s2);
					$display("output = %b (%b expected)", anode1, anode1Expected);
					errors = errors + 1;
				end
				else if (anode2 != anode2Expected) begin
					$display("Error: inputs = %b and %b and %b", select, s1, s2);
					$display("output = %b (%b expected)", anode2, anode2Expected);
					errors = errors + 1;
				end

        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 15'bx) begin
            $display("%d tests completed with %d errors", vectornum, errors);
            $stop;
            end
        end
endmodule