// Julia Gong E155
// testbench_keypadLUT.sv
// jgong@g.hmc.edu
// Date created: 9/13/2025
// This module tests the LUT outputs for the keypad

`timescale 1ns/1ps

module testbench_keypadLUT();
logic clk, reset, key_valid;
logic [31:0] errors;
logic [7:0] key_out;
logic [3:0] key;


// instantiate module 
keypadLUT dut(key_out, key_valid, key);

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

initial begin
    errors = 0;
    reset = 1; #10; reset = 0; #10;

    // begin testing cases
    key_out = 8'b0001_0001; key_valid = 1'b1; #10
    assert (key === 4'b1010) else begin // A
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0001_0010; key_valid = 1'b1; #10
    assert (key === 4'b0000) else begin // 0
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0001_0100; key_valid = 1'b1; #10
    assert (key === 4'b1011) else begin // B
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0001_1000; key_valid = 1'b1; #10
    assert (key === 4'b1111) else begin // F
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0010_0001; key_valid = 1'b1; #10
    assert (key === 4'b0111) else begin // 7
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0010_0010; key_valid = 1'b1; #10
    assert (key === 4'b1000) else begin // 8
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0010_0100; key_valid = 1'b1; #10
    assert (key === 4'b1001) else begin // 9
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0010_1000; key_valid = 1'b1; #10
    assert (key === 4'b1110) else begin // E
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0100_0001; key_valid = 1'b1; #10
    assert (key === 4'b0100) else begin // 4
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0100_0010; key_valid = 1'b1; #10
    assert (key === 4'b0101) else begin // 5
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0100_0100; key_valid = 1'b1; #10
    assert (key === 4'b0110) else begin // 6
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b0100_1000; key_valid = 1'b1; #10
    assert (key === 4'b1101) else begin // D
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b1000_0001; key_valid = 1'b1; #10
    assert (key === 4'b0001) else begin // 1
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b1000_0010; key_valid = 1'b1; #10
    assert (key === 4'b0010) else begin // 2
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b1000_0100; key_valid = 1'b1; #10
    assert (key === 4'b0011) else begin // 3
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

    #10

    key_out = 8'b1000_1000; key_valid = 1'b1; #10
    assert (key === 4'b1100) else begin // C
        $display("Error: inputs = %b",
                    key_out);
                    errors = errors + 1;
    end

$display("All tests completed with %d errors", errors);
        $stop;

end

endmodule
    