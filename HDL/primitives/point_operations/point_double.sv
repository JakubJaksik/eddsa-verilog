import parameters_pkg::*;

module point_double (
    input  logic clk,
    input  logic start,
    input  [DATA_WIDTH-1:0] X1, Y1, Z1,
    output logic [DATA_WIDTH-1:0] X3, Y3, Z3,
    output logic done
);

    typedef enum logic [3:0] {
        IDLE, STAGE1, STAGE2, STAGE3, STAGE4, STAGE5, STAGE6, STAGE7
    } state_t;
    state_t state = IDLE;

    logic [DATA_WIDTH-1:0] reg1, reg2, reg3;
    logic [DATA_WIDTH:0] reg4;
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
                    // C
                    mul1_in_a <= X1;
                    mul1_in_b <= X1;
                    // D
                    mul2_in_a <= Y1;
                    mul2_in_b <= Y1;
                    // temp1
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
                    // B
                    mul1_in_a <= add_result;
                    mul1_in_b <= add_result;
                    // H
                    mul2_in_a <= Z1;
                    mul2_in_b <= Z1;
                    // E
                    add_in_a <= mul1_result;
                    add_in_b <= mul2_result;
                    // temp4
                    sub_in_a <= mul1_result;
                    sub_in_b <= mul2_result;

                    mul1_start <= 1;
                    mul2_start <= 1;
                    add_start <= 1;
                    sub_start <= 1;
                    state <= STAGE2;
                end
            end

            STAGE2: begin
                mul1_start <= 0;
                mul2_start <= 0;
                add_start <= 0;
                sub_start <= 0;
                if (mul1_done && mul2_done && add_done && sub_done) begin
                    reg1 <= add_result;            // E
                    reg4 <= mul2_result;

                    // Y3
                    mul1_in_a <= add_result;
                    mul1_in_b <= sub_result;

                    // temp3
                    sub_in_a <= mul1_result;
                    sub_in_b <= add_result;

                    mul1_start <= 1;
                    sub_start <= 1;
                    state <= STAGE3;
                end
            end

            STAGE3: begin
                reg4 <= reg4 << 1;
                state <= STAGE4;
            end

            STAGE4: begin
                mul1_start <= 0;
                sub_start <= 0;
                if (sub_done) begin
                    reg2 <= sub_result;          //temp3

                    if (reg4 >= MODULUS) begin
                        // temp2
                        reg4 <= reg4 - MODULUS;
                    end
                    state <= STAGE5;
                end
            end

            STAGE5: begin
                // J
                sub_in_a <= reg1;
                sub_in_b <= reg4[DATA_WIDTH-1:0];
                sub_start <= 1;
                state <= STAGE6;
            end

            STAGE6: begin
                sub_start <= 0;
                if (mul1_done && sub_done) begin
                    reg3 <= mul1_result;            // Y3

                    // X3
                    mul1_in_a <= reg2;
                    mul1_in_b <= sub_result;

                    // Z3
                    mul2_in_a <= reg1;
                    mul2_in_b <= sub_result;

                    mul1_start <= 1;
                    mul2_start <= 1;
                    state <= STAGE7;
                end
            end

            STAGE7: begin
                mul1_start <= 0;
                mul2_start <= 0;
                if (mul1_done && mul2_done) begin
                    X3 <= mul1_result;
                    Y3 <= reg3;
                    Z3 <= mul2_result;

                    state <= IDLE;
                    done <= 1;
                end
            end
        endcase
    end

endmodule