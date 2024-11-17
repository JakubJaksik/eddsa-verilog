`timescale 1ns/1ps
import parameters_pkg::*;

module sub_tb;
    parameter int SIZE = DATA_WIDTH;

    logic clk;
    logic rst;
    logic start;
    logic [SIZE-1:0] a;
    logic [SIZE-1:0] b;
    logic [SIZE:0] result;
    logic done;

    logic [SIZE:0] expected;

    sub #(.SIZE(SIZE)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
        .result(result),
        .done(done)
    );

    integer test_counter = 0;
    integer pass_counter = 0;

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 0;

        // Test 1: a > b, no borrow needed
        test_counter = test_counter + 1;
        a = 448'h2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        expected = 449'h1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        start = 1;
        #10 start = 0;
        wait(done);
        if (result == expected) begin
            pass_counter = pass_counter + 1;
            $display("Test %0d passed!\n", test_counter);
        end else begin
            $display("Test %0d failed!", test_counter);
            $display("Obtained: %h", result);
            $display("Expected: %h\n", expected);
        end
        #10;

        // Test 2: a < b, borrow needed
        test_counter = test_counter + 1;
        a = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        expected = 449'h11fffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000;
        start = 1;
        #10 start = 0;
        wait(done);
        if (result == expected) begin
            pass_counter = pass_counter + 1;
            $display("Test %0d passed!\n", test_counter);
        end else begin
            $display("Test %0d failed!", test_counter);
            $display("Obtained: %h", result);
            $display("Expected: %h\n", expected);
        end
        #10;

        // Test 3: a == b, result should be zero
        test_counter = test_counter + 1;
        a = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        expected = 449'h0;
        start = 1;
        #10 start = 0;
        wait(done);
        if (result == expected) begin
            pass_counter = pass_counter + 1;
            $display("Test %0d passed!\n", test_counter);
        end else begin
            $display("Test %0d failed!", test_counter);
            $display("Obtained: %h", result);
            $display("Expected: %h\n", expected);
        end
        #10;

        // Test 4: a = 0, b non-zero, expecting a large result with borrow
        test_counter = test_counter + 1;
        a = 448'h0;
        b = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        expected = 449'h1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
        start = 1;
        #10 start = 0;
        wait(done);
        if (result == expected) begin
            pass_counter = pass_counter + 1;
            $display("Test %0d passed!\n", test_counter);
        end else begin
            $display("Test %0d failed!", test_counter);
            $display("Obtained: %h", result);
            $display("Expected: %h\n", expected);
        end
        #10;

        // Test 5: a and b are small values, no borrow expected
        test_counter = test_counter + 1;
        a = 448'h5;
        b = 448'h3;
        expected = 449'h2;
        start = 1;
        #10 start = 0;
        wait(done);
        if (result == expected) begin
            pass_counter = pass_counter + 1;
            $display("Test %0d passed!\n", test_counter);
        end else begin
            $display("Test %0d failed!", test_counter);
            $display("Obtained: %h", result);
            $display("Expected: %h\n", expected);
        end
        #10;

        // Test 6: a = SIZE-bit max value, b = 1, expect result to be max value - 1
        test_counter = test_counter + 1;
        a = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = 448'h1;
        expected = 449'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe;
        start = 1;
        #10 start = 0;
        wait(done);
        if (result == expected) begin
            pass_counter = pass_counter + 1;
            $display("Test %0d passed!\n", test_counter);
        end else begin
            $display("Test %0d failed!", test_counter);
            $display("Obtained: %h", result);
            $display("Expected: %h\n", expected);
        end

        // Summary
        if (pass_counter == test_counter)
            $display("All passed [%0d/%0d]!", pass_counter, test_counter);
        else
            $display("[%0d/%0d] tests passed", pass_counter, test_counter);

        $stop;
    end
endmodule