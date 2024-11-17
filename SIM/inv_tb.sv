`timescale 1ns/1ps
import parameters_pkg::*;

module inv_tb;
    logic clk;
    logic start;
    logic [DATA_WIDTH-1:0] a;
    logic [DATA_WIDTH-1:0] inv;
    logic done;

    logic [DATA_WIDTH-1:0] expected_inv;

    inv uut (
        .clk(clk),
        .start(start),
        .a(a),
        .inv(inv),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        a = 448'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        expected_inv = 448'h9379DC4C2DB3227DE5B863B705A378854295DF4C4EE47573AF1736E3C198B59BA7278A6820C2F7885C394C06D78B075ED1F09270E9E1F035;
        start = 1;
        #10; start = 0;

        wait (done);
        if (inv == expected_inv) begin
            $display("Test 1 passed!");
        end else begin
            $display("Test 1 failed: \nexpected %h, \ngot %h", expected_inv, inv);
        end

        #10;
        a = 448'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        expected_inv = 448'h3E7063E7063E7063E7063E7063E7063E7063E7063E7063E7063E706376A2576A2576A2576A2576A2576A2576A2576A2576A2576A2576A256;
        start = 1;
        #10; start = 0;

        wait (done);
        if (inv !== expected_inv) begin
            $display("Test 2 failed: \nexpected %h, \ngot %h", expected_inv, inv);
        end else begin
            $display("Test 2 passed!");
        end
        $stop;
    end
endmodule

