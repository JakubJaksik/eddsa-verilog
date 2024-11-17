`timescale 1ns/1ps
import parameters_pkg::*;

module mont_ladder_tb;
    reg clk;
    reg start;
    reg  [455:0] s;
    reg  [DATA_WIDTH-1:0] X, Y, Z;
    wire logic [DATA_WIDTH-1:0] X_out, Y_out, Z_out;
    wire done;

    reg  [DATA_WIDTH-1:0] expected_X3, expected_Y3, expected_Z3;

    mont_ladder uut (
        .clk(clk),
        .start(start),
        .s(s),
        .X(X),
        .Y(Y),
        .Z(Z),
        .X_out(X_out),
        .Y_out(Y_out),
        .Z_out(Z_out),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        X = 448'hbad3bf5ad2b82e03724617332c78ae3c821b3b7c074eaeaf3e7b99c34019fa17590b939fe1d71947656fd2a0f15948b72efa0646e531229a;
        Y = 448'h94f5d548128afedd33601db3f487450e8ab82b7a55629b516559100b9995f00c163883f999d8aed7cd1ab93f88bc9f8230b2429974c6e42b;
        Z = R_MOD_P;
        s = 456'd10;

        expected_X3 = 448'h5fbaa18f6e2e99ef070751af9d83b3d5103dd1b6a2abc69a422c44b835ecb1c7206442c44b1d5a972ec8fd6cd9cb565489c1f7d401e24999;
        expected_Y3 = 448'h2ceae123442d929d8d56109f1d845835ac10d933321f09941f866652d239dc87d6ac135bdd803a936146314faa41736f154f1d0a2822587e;
        expected_Z3 = 448'hf4aa83e9b20da22d9dea2237cb8f085a974818fc39bb47e676de264b2749be1a71ce4fb9f784736b487dba943f01b6f7a41973d680c1242a;
        
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 1: [s]P");
        $display("X: %h", X_out);
        $display("Y: %h", Y_out);
        $display("Z: %h", Z_out);
        if (X_out == expected_X3 && Y_out == expected_Y3 && Z_out == expected_Z3) 
            $display("Test 1 passed.");
        else begin
            $display("Test 1 failed.");
            $display("Expected: ");
            $display("X: %h", expected_X3);
            $display("Y: %h", expected_Y3);
            $display("Z: %h", expected_Z3);
        end

        $stop;
    end
endmodule
