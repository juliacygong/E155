// Julia Gong E155
// testbench.sv
// jgong@g.hmc.edu
// Date created: 9/2/25
// This file tests to see if the dual 7-segment display is displaying the proper hexidecimal value given the input from s[3:0]. 
// This file also tests if the LEDs are showing the proper sum of the 7-segment displays

`timescale 1ns/1ps 

module testbench_lab2();
    logic       clk, reset;
    logic       [6:0] seg;
    logic       [4:0] led;
    logic       [3:0] s1, s2;
    logic       anode1, anode2;
    logic       [31:0] errors;


// instantiate module
lab2_jg #(24'd28) dut(reset, s1, s2, anode1, anode2, led, seg);

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end


initial begin
		dut.counter = 0;
        errors = 0;
        reset = 0; #10; reset = 1;

        // counter starts at 0 on reset = 0
        s1 = 4'b0000; s2 = 4'b0000; #10;
        assert (seg === 7'b100_0000 && led === 5'b00000 && anode1 === 1'b0 && anode2 === 1'b1) else begin
            $display("Error: inputs = %b and %b",
                    s1, s2);
                    errors = errors + 1;
        end

        #6500000; // time for counter to switch (80Hz)


        s1 = 4'b0011; s2 = 4'b0000; #10;
        assert (seg === 7'b0110000 && led === 5'b00011 && anode1 === 1'b1 && anode2 === 1'b0) else begin
            $display("Error: inputs = %b and %b",
                    s1, s2);
                    errors = errors + 1;
        end

        #6500000;

       
        s1 = 4'b0111; s2 = 4'b0000; #10;
        assert (seg === 7'b1000000 && led === 5'b00111 && anode1 === 1'b0 && anode2 === 1'b1) else begin
            $display("Error: inputs = %b and %b",
                    s1, s2);
                    errors = errors + 1;
        end

        #6500000;

        s1 = 4'b1000; s2 = 4'b0000; #10;
        assert (seg === 7'b0000000 && led === 5'b01000 && anode1 === 1'b1 && anode2 === 1'b0) else begin
            $display("Error: inputs = %b and %b",
                    s1, s2);
                    errors = errors + 1;
        end


        #6500000;

        s1 = 4'b1100; s2 = 4'b0001; #10;
        assert (seg === 7'b1111001 && led === 5'b01101 && anode1 === 1'b0 && anode2 === 1'b1) else begin
            $display("Error: inputs = %b and %b",
                    s1, s2);
                    errors = errors + 1;
        end
		#6500000;
		 
        s1 = 4'b0111; s2 = 4'b0000; #10;
        assert (seg === 7'b1111000 && led === 5'b00111 && anode1 === 1'b1 && anode2 === 1'b0) else begin
            $display("Error: inputs = %b and %b",
                    s1, s2);
                    errors = errors + 1;
        end


        #6500000;

        s1 = 4'b1111; s2 = 4'b1111; #10;
        assert (seg === 7'b0001110 && led === 5'b11110 && anode1 === 1'b0 && anode2 === 1'b1) else begin
            $display("Error: inputs = %b and %b",
                    s1, s2);
                    errors = errors + 1;
        end

        #6500000;

        s1 = 4'b1111; s2 = 4'b1111; #10;
        assert (seg === 7'b0001110 && led === 5'b11110 && anode1 === 1'b1 && anode2 === 1'b0) else begin
            $display("Error: inputs = %b and %b",
                    s1, s2);
                    errors = errors + 1;
        end

        $display("All tests completed with %d errors", errors);
        $stop;
end

endmodule