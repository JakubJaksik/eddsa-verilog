/*
A module performing multiplication in Fp.
Input: 
 a, b - 448-bit numbers; 
Output: 
 out - the result (modulo p)
*/
import parameters_pkg::*;

module mul_mont (
    input  logic clk,
    input  logic start,
    input  [DATA_WIDTH-1:0] a,
    input  [DATA_WIDTH-1:0] b,
    output logic [DATA_WIDTH-1:0] result,
    output logic done
);
    typedef enum logic [2:0] {IDLE, STAGE2, STAGE1, STAGE3, STAGE4} state_t;
    state_t stage = IDLE;

    logic [DATA_WIDTH*2:0] temp;
    logic [DATA_WIDTH*2-1:0] mul_ab_result, mul_ab_p_inv_result, mul_m_p_result;
    logic [DATA_WIDTH:0] add_result;
    logic [DATA_WIDTH-1:0] m_result;
    logic mul_ab_done, mul_ab_p_inv_done, mul_m_p_done;

    mul mul_ab (
        .clk(clk),
        .start(start && stage == IDLE),
        .a(a),
        .b(b),
        .result(mul_ab_result),
        .done(mul_ab_done)
    );

    mul mul_ab_p_inv (
        .clk(clk),
        .start(stage == STAGE1),
        .a(mul_ab_result[DATA_WIDTH-1:0]),
        .b(MODULUS_INV),
        .result(mul_ab_p_inv_result),
        .done(mul_ab_p_inv_done)
    );

    mul mul_m_p (
        .clk(clk),
        .start(stage == STAGE2 && !mul_m_p_done),
        .a(m_result),
        .b(MODULUS),
        .result(mul_m_p_result),
        .done(mul_m_p_done)
    );

    always_ff @(posedge clk) begin
        case (stage)
            IDLE: begin
                done <= 0;
                result <= 0;
                if (mul_ab_done) begin
                    stage <= STAGE1;
                end
            end
            STAGE1: begin
                if (mul_ab_p_inv_done) begin
                    // m = (t * p_inv) mod R
                    m_result <= mul_ab_p_inv_result[DATA_WIDTH-1:0];
                    stage <= STAGE2;
                end
            end
            STAGE2: begin
                if (mul_m_p_done) begin
                    temp <= mul_m_p_result + mul_ab_result;
                    stage <= STAGE3;
                end
            end
            STAGE3: begin
                add_result <= temp[DATA_WIDTH*2:DATA_WIDTH];
                stage <= STAGE4;
            end
            STAGE4: begin
                result <= (add_result >= MODULUS) ? add_result - MODULUS : add_result;
                done <= 1;
                stage <= IDLE;
            end
        endcase
    end
endmodule
