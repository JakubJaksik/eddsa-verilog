`timescale 1ns/1ps
import parameters_pkg::*;

module mul_mont_tb;
    reg clk;
    reg start;
    reg [DATA_WIDTH-1:0] a;
    reg [DATA_WIDTH-1:0] b;
    reg [DATA_WIDTH-1:0] expected;
    wire [DATA_WIDTH-1:0] result;
    wire done;

    mul_mont uut (
        .clk(clk),
        .start(start),
        .a(a),
        .b(b),
        .result(result),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // abR^-1
        a = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = 448'h2;
        expected = 448'h40000000000000000000000000000000000000000000000000000001bffffffffffffffffffffffffffffffffffffffffffffffffffffffc;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 1: Montgomery Multiplication result = %h", result);
        if (result == expected)
            $display("Test 1 passed.");
        else
            $display("Test 1 failed, expected result = %h.", expected);

        #10;
        a = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = 448'h3;
        expected = 448'h600000000000000000000000000000000000000000000000000000029FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 2: Montgomery Multiplication result = %h", result);
        if (result == expected)
            $display("Test 2 passed.");
        else
            $display("Test 2 failed, expected result = %h.", expected);

        #10;
        a = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE;
        expected = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE00000000000000000000000000000000000000000000000000000001;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 3: Montgomery Multiplication result = %h", result);
        if (result == expected)
            $display("Test 3 passed.");
        else
            $display("Test 3 failed, expected result = %h.", expected);

        #10;
        a = 0;
        b = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        expected = 0;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 4: Montgomery Multiplication result = %h", result);
        if (result == expected)
            $display("Test 4 passed.");
        else
            $display("Test 4 failed, expected result = %h.", expected);
            
        // Converting a to aR
        #10;
        a = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = R2_MOD_P;
        expected = 448'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 5: Montgomery Multiplication result = %h", result);
        if (result == expected)
            $display("Test 5 passed.");
        else
            $display("Test 5 failed, expected result = %h.", expected);

        // Converting abR to ab
        #10;
        a = 448'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE;
        b = 448'h1;
        expected = 448'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 6: Montgomery Multiplication result = %h", result);
        if (result == expected)
        $display("Test 6 passed.");
        else
        $display("Test 6  failed, expected result = %h.", expected);


        $stop;
    end
endmodule
