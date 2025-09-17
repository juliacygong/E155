// Julia Gong E155
// testbench_scan.sv
// jgong@g.hmc.edu
// Date created: 9/13/2025
// This module tests the scan module to ensure that the correct key value is being determined

`timescale 1ns/1ps

module testbench_scan;


    logic clk, reset;
    logic [3:0] cols, key_row, key_col, row_current;
    logic [7:0] key_val;
    logic row_stop;
    int errors;

    // Parameters
    localparam CLK_PERIOD = 10;


    scan dut (
        .clk(clk),
        .reset(reset),
        .cols(cols),
        .row_stop(row_stop),
        .row_current(row_current),
        .key_row(key_row),
        .key_col(key_col),
        .key_val(key_val)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // === Task: Reset the design ===
    task do_reset();
        begin
            reset = 0;
            row_stop = 0;
            row_current = 4'b0000;
            cols = 4'b1111;
            @(posedge clk);
            reset = 1;
            @(posedge clk);
        end
    endtask

    // === Task: Simulate a key press at specific row/col ===
    task test_key_press(
        input [3:0] active_row_onehot,
        input [3:0] active_col_onehot,
        input [7:0] expected_key_val
    );
        int max_cycles;
        int cycles;
        begin
            max_cycles = 20;
            cycles = 0;

            // Apply stimulus
            row_stop = 0;
            cols = ~active_col_onehot;

            // Wait for key_row to rotate to match active_row_onehot
            while (key_row !== active_row_onehot && cycles < max_cycles) begin
                @(posedge clk);
                cycles++;
            end

            if (cycles == max_cycles) begin
                $display("ERROR: Timed out waiting for row match. Expected %b, got %b", active_row_onehot, key_row);
                errors++;
            end else begin
                @(posedge clk); // Let logic settle
                if (key_val !== expected_key_val) begin
                    $display("ERROR: Expected key_val = %b, got = %b", expected_key_val, key_val);
                    errors++;
                end else begin
                    $display("PASS: key_val = %b for row = %b, col = %b", key_val, active_row_onehot, active_col_onehot);
                end
            end

            // Release key
            cols = 4'b1111;
            @(posedge clk);
        end
    endtask

    // === Main Test Sequence ===
    initial begin
        clk = 0;
        errors = 0;

        do_reset();

        // Test cases (expected key_val = {~row, ~col})
        test_key_press(4'b1110, 4'b1110, 8'b0001_0001);
        test_key_press(4'b1101, 4'b1101, 8'b0010_0010);
        test_key_press(4'b1011, 4'b1011, 8'b0100_0100);
        test_key_press(4'b0111, 4'b0111, 8'b1000_1000);
        test_key_press(4'b1011, 4'b0111, 8'b0100_1000);
        test_key_press(4'b0111, 4'b1101, 8'b1000_0010);

        $display("All tests completed with %0d error(s).", errors);
        $stop;
    end

endmodule
