// Julia Gong E155
// testbench_fsm.sv
// jgong@g.hmc.edu
// Date created: 9/13/2025
// This module tests the fsm to ensure that the inputs are properly being debounced

`timescale 1ns/1ps

module testbench_fsm();


    logic clk, reset, key_valid, row_stop;
    logic [7:0] key_val;
    logic [3:0] key, key_col, row_current;
    logic [31:0] errors;

    // Clock Generation (100MHz)
    always #5 clk = ~clk;


    fsm dut (
        .clk(clk),
        .reset(reset),
        .key_val(key_val),
        .key_col(key_col),
        .key(key),
        .key_valid(key_valid),
        .row_stop(row_stop),
        .row_current(row_current)
    );

    // Constants
    localparam DEBOUNCE_WAIT_CYCLES = 8;   // Counter[2] implies ~4 cycles @ 100MHz (based on counter width)
    localparam integer CYCLE = 10;         // One clock period (ns)
    localparam integer WAIT_DEBOUNCE = 4 * CYCLE * DEBOUNCE_WAIT_CYCLES;

    // === TASKS ===

    // Reset
    task do_reset();
        reset = 1; clk = 0; #CYCLE;
        reset = 0; #CYCLE;
        reset = 1; #CYCLE;
    endtask

    // Press a key
    task press_key(input [7:0] key_data, input [3:0] col_data);
        key_val = key_data;
        key_col = col_data;
    endtask

    // Release key
    task release_key();
        key_col = 4'b0000;
    endtask

    // Simulate full press & release with debounce
    task simulate_keypress(
        input [7:0] key_data,
        input [3:0] col_data,
        input [3:0] expected_key
    );
        press_key(key_data, col_data);
        repeat (10) @(posedge clk);  // Give time to settle
        repeat (DEBOUNCE_WAIT_CYCLES) @(posedge clk);

        if (!key_valid) begin
            $display("ERROR: key_valid not high for key_val=%b", key_data);
            errors++;
        end else if (key !== expected_key) begin
            $display("ERROR: expected key=%b but got %b", expected_key, key);
            errors++;
        end else begin
            $display("PASS: key_val=%b -> key=%b", key_data, key);
        end

        release_key();
        repeat (DEBOUNCE_WAIT_CYCLES) @(posedge clk);
    endtask

    // === TEST SEQUENCE ===
    initial begin
        errors = 0;
        do_reset();

        // TEST 1: Simple key press
        simulate_keypress(8'b0001_0001, 4'b0001, 4'b1010);  // row=0001, col=0001 (example key A)

        // TEST 2: New key pressed while another is held
        press_key(8'b1000_1000, 4'b1000); // Key 1 pressed
        repeat (2) @(posedge clk);
        press_key(8'b0100_0001, 4'b0001); // Key 2 pressed while holding
        repeat (10) @(posedge clk);
        release_key();
        repeat (DEBOUNCE_WAIT_CYCLES) @(posedge clk);
        if (!key_valid || key !== 4'b1100) begin
            $display("ERROR: Multi-press test failed.");
            errors++;
        end else begin
            $display("PASS: Multi-press test passed.");
        end

        // TEST 3: Two keys pressed almost simultaneously
        press_key(8'b0100_0010, 4'b0010);
        #30;
        press_key(8'b0010_1000, 4'b1000);
        repeat (10) @(posedge clk);
        release_key();
        repeat (DEBOUNCE_WAIT_CYCLES) @(posedge clk);
        if (!key_valid || key !== 4'b0101) begin
            $display("ERROR: Simultaneous press test failed.");
            errors++;
        end else begin
            $display("PASS: Simultaneous press test passed.");
        end

        // Final report
        $display("All tests completed with %0d error(s).", errors);
        $stop;
    end

endmodule
