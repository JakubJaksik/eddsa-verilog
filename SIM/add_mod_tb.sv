`timescale 1ns/1ps
import parameters_pkg::*;

module add_tb;
    reg clk;
    reg start;
    reg [DATA_WIDTH-1:0] a;
    reg [DATA_WIDTH-1:0] b;
    wire [DATA_WIDTH-1:0] sum;
    wire done;

    add uut (
        .clk(clk),
        .start(start),
        .a(a),
        .b(b),
        .sum(sum),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        a = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        b = 448'h1;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 1: a + b = %h", sum);
        if (sum == a + b) 
            $display("Test 1 passed.");
        else
            $display("Test 1 failed.");

        a = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // p - 1
        b = 448'h2;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 2: a + b = %h (mod p)", sum);
        if (sum == ((a + b) - MODULUS)) 
            $display("Test 2 passed.");
        else
            $display("Test 2 failed.");

        a = MODULUS - 1;
        b = 448'h1;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 3: a + b = %h (mod p)", sum);
        if (sum == 0)
            $display("Test 3 passed.");
        else
            $display("Test 3 failed.");

        $stop;
    end
endmodule
