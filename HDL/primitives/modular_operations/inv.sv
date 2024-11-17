import parameters_pkg::*;

module inv (
    input  logic clk,
    input  logic start,
    input  [DATA_WIDTH-1:0] a,
    output logic [DATA_WIDTH-1:0] inv,
    output logic done
);
    localparam EXPONENT = MODULUS - 2;

    logic [DATA_WIDTH-1:0] mul1_in_a, mul1_in_b, mul1_result, mul2_in_a, mul2_in_b, mul2_result, exponent, result_mont;
    logic mul1_start, mul2_start, mul1_done, mul2_done;

    typedef enum logic [1:0] {IDLE, STAGE1, STAGE2, STAGE3} state_t;
    state_t state = IDLE;

    mul_mont mul_montgomery1 (
        .clk(clk),
        .start(mul1_start),
        .a(mul1_in_a),
        .b(mul1_in_b),
        .result(mul1_result),
        .done(mul1_done)
    );

    mul_mont mul_montgomery2 (
        .clk(clk),
        .start(mul2_start),
        .a(mul2_in_a),
        .b(mul2_in_b),
        .result(mul2_result),
        .done(mul2_done)
    );

    always_ff @(posedge clk) begin
        case (state)
            IDLE: begin
                if (start) begin
                    mul1_in_a <= a;
                    mul1_in_b <= R2_MOD_P;
                    exponent <= EXPONENT;
                    result_mont <= R_MOD_P;
                    mul1_start <= 1;
                    done <= 0;
                    state <= STAGE1;
                end
            end

            STAGE1: begin
                mul1_start <= 0;
                if(mul1_done) begin
                    mul1_in_a <= mul1_result;
                    mul1_in_b <= mul1_result;

                    mul2_in_a <= result_mont;
                    mul2_in_b <= mul1_result;
                    mul1_start <= 1;
                    mul2_start <= 1;
                    state <= STAGE2;
                end
            end

            STAGE2: begin
                if (mul1_done && mul2_done ) begin
                    if (exponent == 0) begin
                        mul1_in_a <= result_mont;
                        mul1_in_b <= 1;
                        mul1_start <= 1;
                        state <= STAGE3;
                    end else begin 
                        if (exponent[0] == 1) begin
                            result_mont <= mul2_result;
                        end
                        mul1_in_a <= mul1_result;
                        mul1_in_b <= mul1_result;
                        mul2_in_a <= mul1_result;
                        mul2_in_b <= ( (exponent[1] == 1) && (exponent[0] == 1)) ? mul2_result : result_mont;
                        exponent <= exponent >> 1;
                        mul1_start <= 1;
                        mul2_start <= 1;
                    end
                end else begin
                    mul1_start <= 0;
                    mul2_start <= 0;
                end
            end

            STAGE3: begin
                mul1_start <= 0;
                if (mul1_done) begin
                    inv <= mul1_result;
                    done <= 1;
                    state <= IDLE;
                end
            end
        endcase
    end
endmodule
