`timescale 1ns/1ps
import parameters_pkg::*;

module point_add_tb;
    reg clk;
    reg start;
    reg  [DATA_WIDTH-1:0] X1, Y1, Z1;
    reg  [DATA_WIDTH-1:0] X2, Y2, Z2;
    wire logic [DATA_WIDTH-1:0] X3, Y3, Z3;
    wire done;

    reg  [DATA_WIDTH-1:0] expected_X3, expected_Y3, expected_Z3;

    point_add uut (
        .clk(clk),
        .start(start),
        .X1(X1),
        .Y1(Y1),
        .Z1(Z1),
        .X2(X2),
        .Y2(Y2),
        .Z2(Z2),
        .X3(X3),
        .Y3(Y3),
        .Z3(Z3),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        X1 = 448'h420685F0EA8836D16EF0905D88B9EE96C7295E6EB444D6FB9BE886A7F2ED152A7E9B28E44CD37AB765FAB7BC2914F8FE6D35BF93B17AA383;
        Y1 = 448'hD81F4FBA18417765F7687A33AB50A1F0E6ACAF94714FA9DD012232506EE00948A98ABB416EF259FC5486DA8E9AC23C2104AC119C79A99632;
        Z1 = R_MOD_P;

        X2 = 448'h377E8B3FA418A525159F32830C694EF413C301AC9661A92AEF05D69EDD20ADB35D248B2E71076A0EE9D7F2900F85E7D0BED0684971B843F9;
        Y2 = 448'hE725520BDB5A083DF83B0C87FDDDC5027B8E6DE549A23C24E8FB173022AA7851CBD9028BFFBAAFD9817B91F0E340893452E324B09FBA2E89;
        Z2 = R_MOD_P;

        expected_X3 = 448'hC4D1AE1E8E07A6233963EFDE2FAEA74FBF1296A41998042211A25FA1936DBF0A52B5E617DB05C053EB91B1815BBBD995E9BD5E83E817E90F;
        expected_Y3 = 448'hEDEB4FDB6EB1B186797AC9837325D06F1F849B71CC88920C30863692CE97A5BACC54F15BBD23B2B6EBF5D2D9C89EE0C3BAA789C179A79961;
        expected_Z3 = 448'hD882C6FFF18330BF3A58F92003379C19EE9B556947A90DF20105A556F754E8F5E7D4E91D124955B38DBED4CE9407450DD6F5E054A7060BB4;
        
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 1: P + Q");
        $display("X3: %h", X3);
        $display("Y3: %h", Y3);
        $display("Z3: %h", Z3);
        if (X3 == expected_X3 && Y3 == expected_Y3 && Z3 == expected_Z3) 
            $display("Test 1 passed.");
        else begin
            $display("Test 1 failed.");
            $display("Expected: ");
            $display("X3: %h", expected_X3);
            $display("Y3: %h", expected_Y3);
            $display("Z3: %h", expected_Z3);
        end

        #10
        X1 = 448'h200000000000000000000000000000000000000000000000000000002;
        Y1 = 448'h300000000000000000000000000000000000000000000000000000003;
        Z1 = R_MOD_P;

        X2 = 448'h400000000000000000000000000000000000000000000000000000004;
        Y2 = 448'h500000000000000000000000000000000000000000000000000000005;
        Z2 = R_MOD_P;

        expected_X3 = 448'h6264EE600000000000000000000000000000000000000000000000006264EE6;
        expected_Y3 = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE0B157DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE0B157E;
        expected_Z3 = 448'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBFF3ED063BFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBFF3ED063C0;
        
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Test 2: P + Q");
        $display("X3: %h", X3);
        $display("Y3: %h", Y3);
        $display("Z3: %h", Z3);
        if (X3 == expected_X3 && Y3 == expected_Y3 && Z3 == expected_Z3) 
            $display("Test 2 passed.");
        else begin
            $display("Test 2 failed.");
            $display("Expected: ");
            $display("X3: %h", expected_X3);
            $display("Y3: %h", expected_Y3);
            $display("Z3: %h", expected_Z3);
        end

        $stop;
    end
endmodule
