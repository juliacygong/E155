// Julia Gong E155
// testbench_lab3.sv
// jgong@g.hmc.edu
// Date created: 9/13/2025
// This module tests entire keypad system where 

`timescale 1ns/1ps

module testbench_lab3_jg;

    logic reset, clk;
    logic [3:0] cols;

    logic anode1, anode2;
    logic [3:0] key_row;
    logic [6:0] seg;

    lab3_jg dut (
        .reset(reset),
        .cols(cols),
        .anode1(anode1),
        .anode2(anode2),
        .key_row(key_row),
        .seg(seg)
    );


always
    begin
        clk = 1; #5; clk = 0; #5;
    end

    initial begin

        reset = 0;
        cols = 4'b1111; // no key pressed

        #10000000; // wait for internal oscillator to stabilize

        reset = 1;

        #50000000; // wait after reset for system to start scanning

        // Simulate key press
        $display("Pressing key: row 0, col 0");
        cols = 4'b1110; // col 0 low (active)

        // Wait enough time for FSM debounce + scan cycles (e.g. 50ms)
        #50000000;

        // Release key
        $display("Releasing key");
        cols = 4'b1111;

        // Wait more time to observe key release handling
        #50000000;

        $display("Final key_row: %b", key_row);
        $display("Segment output: %b", seg);
        $display("Anode1: %b, Anode2: %b", anode1, anode2);

        $stop;
    end

endmodule
