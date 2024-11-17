`timescale 1ns/1ps
import parameters_pkg::*;

module point_double_tb;
    reg clk;
    reg start;
    reg  [DATA_WIDTH-1:0] X1, Y1, Z1;
    wire logic [DATA_WIDTH-1:0] X3, Y3, Z3;
    wire done;

    reg  [DATA_WIDTH-1:0] expected_X3, expected_Y3, expected_Z3;

    point_double uut (
        .clk(clk),
        .start(start),
        .X1(X1),
        .Y1(Y1),
        .Z1(Z1),
        .X3(X3),
        .Y3(Y3),
        .Z3(Z3),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        X1 = 448'h377E8B3FA418A525159F32830C694EF413C301AC9661A92AEF05D69EDD20ADB35D248B2E71076A0EE9D7F2900F85E7D0BED0684971B843F9;
        Y1 = 448'hE725520BDB5A083DF83B0C87FDDDC5027B8E6DE549A23C24E8FB173022AA7851CBD9028BFFBAAFD9817B91F0E340893452E324B09FBA2E89;
        Z1 = R_MOD_P;

        expected_X3 = 448'h8F7D31C53CE218EC0C706EB5C1BD6D483303FB502F3F16C1776413F2FDD199FB15C02A02EED473B364FD15C77CE763B514D38CAB476C3C27;
        expected_Y3 = 448'h23F7C6EA1574DE77F304DB2CE70DAC394F8B0A07DE915E81570E8DA857668D80278AED1382E34400483BBA5733EAFD0E678569AE867A958D;
        expected_Z3 = 448'hE58BEB92FE6B38853238475B62CF47EB9E98C953E5B2C85E2203103DBD6E7E9E8B8494AD3DE2393B838B62B2653F714AD571A6B08DB785BE;
        
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

        $stop;
    end
endmodule
