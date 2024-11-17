import parameters_pkg::*;

module point_add (
    input  logic clk,
    input  logic start,
    input  [DATA_WIDTH-1:0] X1, Y1, Z1,
    input  [DATA_WIDTH-1:0] X2, Y2, Z2,
    output logic [DATA_WIDTH-1:0] X3, Y3, Z3,
    output logic done
);

    typedef enum logic [3:0] {
        IDLE, STAGE1, STAGE2, STAGE3, STAGE4, STAGE5, STAGE6
    } state_t;
    state_t state = IDLE;

    logic [DATA_WIDTH-1:0] reg1, reg2,reg3, reg4, reg5, reg6;
    logic [DATA_WIDTH-1:0] mul1_in_a, mul1_in_b, mul2_in_a, mul2_in_b, add_in_a, add_in_b, sub_in_a, sub_in_b; 
    logic [DATA_WIDTH-1:0] mul1_result, mul2_result, add_result, sub_result;
    logic mul1_done, mul2_done, add_done, sub_done, mul1_start, mul2_start, add_start, sub_start;
    
    mul_mont mul1 (.clk(clk), .start(mul1_start), .a(mul1_in_a), .b(mul1_in_b), .result(mul1_result), .done(mul1_done));
    mul_mont mul2 (.clk(clk), .start(mul2_start), .a(mul2_in_a), .b(mul2_in_b), .result(mul2_result), .done(mul2_done));
    
    add add_module (.clk(clk), .start(add_start), .a(add_in_a), .b(add_in_b), .sum(add_result), .done(add_done));
    sub sub_module (.clk(clk), .start(sub_start), .a(sub_in_a), .b(sub_in_b), .result(sub_result), .done(sub_done));

    always_ff @(posedge clk) begin
        case (state)
            IDLE: begin
                done <= 0;
                if (start) begin
                    mul1_in_a <= X1;
                    mul1_in_b <= X2;

                    mul2_in_a <= Y1;
                    mul2_in_b <= Y2;

                    add_in_a <= X1;
                    add_in_b <= Y1;

                    mul1_start <= 1;
                    mul2_start <= 1;
                    add_start <= 1;
                    state <= STAGE1;
                end
            end

            STAGE1: begin
                mul1_start <= 0;
                mul2_start <= 0;
                add_start <= 0;
                if (mul1_done && mul2_done && add_done) begin
                    reg1 <= mul1_result;        // C
                    reg2 <= mul2_result;        // D
                    reg3 <= add_result;         // temp2

                    mul1_in_a <= Z1;
                    mul1_in_b <= Z2;

                    mul2_in_a <= mul1_result;
                    mul2_in_b <= mul2_result;

                    add_in_a <= X2;
                    add_in_b <= Y2;

                    mul1_start <= 1;
                    mul2_start <= 1;
                    add_start <= 1;
                    state <= STAGE2;
                end
            end

            STAGE2: begin
                mul1_start <= 0;
                mul2_start <= 0;
                add_start <= 0;
                if (mul1_done && mul2_done && add_done) begin
                    reg4 <= mul1_result;        // A
                    reg5 <= add_result;         // temp3

                    mul1_in_a <= mul1_result;
                    mul1_in_b <= mul1_result;

                    mul2_in_a <= mul2_result;
                    mul2_in_b <= D;

                    add_in_a <= reg1;
                    add_in_b <= reg2;

                    sub_in_a <= reg2;
                    sub_in_b <= reg1;

                    mul1_start <= 1;
                    mul2_start <= 1;
                    add_start <= 1;
                    sub_start <= 1;
                    state <= STAGE3;
                end
            end

            STAGE3: begin
                mul1_start <= 0;
                mul2_start <= 0;
                add_start <= 0;
                sub_start <= 0;
                if (mul1_done && mul2_done && add_done && sub_done) begin
                    reg6 <= add_result;         // temp4

                    mul1_in_a <= reg3;
                    mul1_in_b <= reg5;

                    mul2_in_a <= reg4;
                    mul2_in_b <= sub_result;

                    add_in_a <= mul1_result;
                    add_in_b <= mul2_result;

                    sub_in_a <= mul1_result;
                    sub_in_b <= mul2_result;

                    mul1_start <= 1;
                    mul2_start <= 1;
                    add_start <= 1;
                    sub_start <= 1;
                    state <= STAGE4;
                end
            end

            STAGE4: begin
                mul1_start <= 0;
                mul2_start <= 0;
                add_start <= 0;
                sub_start <= 0;
                if (mul1_done && mul2_done && add_done && sub_done) begin
                    reg1 <= sub_result;         // F
                    reg2 <= add_result;         // G

                    mul1_in_a <= reg4;
                    mul1_in_b <= sub_result;

                    mul2_in_a <= add_result;
                    mul2_in_b <= mul2_result;

                    sub_in_a <= mul1_result;
                    sub_in_b <= reg6;

                    mul1_start <= 1;
                    mul2_start <= 1;
                    sub_start <= 1;
                    state <= STAGE5;
                end
            end

            STAGE5: begin
                mul1_start <= 0;
                mul2_start <= 0;
                sub_start <= 0;
                if (mul1_done && mul2_done && sub_done) begin
                    reg5 <= mul2_result;        // Y3


                    mul1_in_a <= sub_result;
                    mul1_in_b <= mul1_result;

                    mul2_in_a <= reg1;
                    mul2_in_b <= reg2;

                    mul1_start <= 1;
                    mul2_start <= 1;
                    state <= STAGE6;
                end
            end

            STAGE6: begin
                mul1_start <= 0;
                mul2_start <= 0;
                if (mul1_done && mul2_done) begin
                    X3 <= mul1_result;
                    Y3 <= reg5;
                    Z3 <= mul2_result;

                    state <= IDLE;
                    done <= 1;
                end
            end
        endcase
    end
endmodule
