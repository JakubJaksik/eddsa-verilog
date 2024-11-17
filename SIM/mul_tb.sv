`timescale 1ns/1ps
import parameters_pkg::*;

module mul_tb;
    reg clk;
    reg start;
    reg [DATA_WIDTH-1:0] a;
    reg [DATA_WIDTH-1:0] b;
    wire [DATA_WIDTH*2-1:0] result;
    wire done;

    mul uut (
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
        a = 448'h40000000000000000000000000000000000000000000000000000001fffffffffffffffffffffffffffffffffffffffffffffffffffffffe;
        b = 448'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 1: a * b = %h", result);
        if (result == a * b)
            $display("Test 1 passed.");
        else
            $display("Test 1 failed.");
        
        #10
        a = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = 448'h3;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 2: a * b = %h", result);
        if (result == a * b)
            $display("Test 2 passed.");
        else
            $display("Test 2 failed.");

        #10
        a = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 3: a * b = %h", result);
        if (result == a * b)
            $display("Test 3 passed.");
        else
            $display("Test 3 failed.");

        #10
        a = 0;
        b = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 4: a * b = %h", result);
        if (result == 0)
            $display("Test 4 passed.");
        else
            $display("Test 4 failed.");

        $stop;
    end
endmodule
