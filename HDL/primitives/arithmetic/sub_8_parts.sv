/*
    Module: sub_8_parts

    Description:
    This module performs staged subtraction of two large inputs (a and b) with a bit width specified by 
    the parameter SIZE. The width of SIZE must be divisible by 8. The module is designed with a typical 
    input size of 448 bits in mind, supporting larger operations by dividing the inputs into eight segments 
    to handle subtraction with potential borrow across stages.

    Parameters:
    - SIZE: Bit width of the inputs, must be divisible by 8.

    Inputs:
    - clk   : Clock signal.
    - rst   : Synchronous reset signal.
    - start : Initiates the subtraction process.
    - a, b  : Input operands with width SIZE.

    Outputs:
    - result: Result of a - b, with a width of SIZE + 1 to accommodate any borrow.
    - done  : Asserted high when the subtraction is complete.

    Operation:
    - On `start`, the module begins subtracting `b` from `a` in 8 stages, each handling an eighth of the bits.
      The FSM controls the subtraction process across states IDLE, STAGE1 to STAGE7. Each stage 
      manages borrow propagation to accommodate multi-stage subtraction. The final result is stored in `result`, 
      with `done` signaling completion.
*/

module sub_8_parts #(
    parameter int SIZE = 896 // Default bit width, must be divisible by 8
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  [SIZE-1:0] a,       
    input  [SIZE-1:0] b,       
    output logic [SIZE:0] result,
    output logic done
);
    typedef enum logic [2:0] {IDLE, STAGE1, STAGE2, STAGE3, STAGE4, STAGE5, STAGE6, STAGE7} state_t;
    state_t state = IDLE;

    logic [SIZE/8-1:0] partial_diff1, partial_diff2, partial_diff3, partial_diff4, partial_diff5, partial_diff6, partial_diff7;
    logic borrow;

    always_ff@(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 1;
            result <= 0;
            partial_diff1 <= 0;
            partial_diff2 <= 0;
            partial_diff3 <= 0;
            partial_diff4 <= 0;
            partial_diff5 <= 0;
            partial_diff6 <= 0;
            partial_diff7 <= 0;
            borrow <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        {borrow, partial_diff1} <= a[SIZE/8-1:0] - b[SIZE/8-1:0];
                        state <= STAGE1;
                        done <= 0;
                    end 
                end
                STAGE1: begin
                    {borrow, partial_diff2} <= a[2*SIZE/8-1:SIZE/8] - b[2*SIZE/8-1:SIZE/8] - borrow;
                    state <= STAGE2;
                end
                STAGE2: begin
                    {borrow, partial_diff3} <= a[3*SIZE/8-1:2*SIZE/8] - b[3*SIZE/8-1:2*SIZE/8] - borrow;
                    state <= STAGE3;
                end
                STAGE3: begin
                    {borrow, partial_diff4} <= a[4*SIZE/8-1:3*SIZE/8] - b[4*SIZE/8-1:3*SIZE/8] - borrow;
                    state <= STAGE4;
                end
                STAGE4: begin
                    {borrow, partial_diff5} <= a[5*SIZE/8-1:4*SIZE/8] - b[5*SIZE/8-1:4*SIZE/8] - borrow;
                    state <= STAGE5;
                end
                STAGE5: begin
                    {borrow, partial_diff6} <= a[6*SIZE/8-1:5*SIZE/8] - b[6*SIZE/8-1:5*SIZE/8] - borrow;
                    state <= STAGE6;
                end
                STAGE6: begin
                    {borrow, partial_diff7} <= a[7*SIZE/8-1:6*SIZE/8] - b[7*SIZE/8-1:6*SIZE/8] - borrow;
                    state <= STAGE7;
                end
                STAGE7: begin
                    result[SIZE:7*SIZE/8] <= a[SIZE-1:7*SIZE/8] - b[SIZE-1:7*SIZE/8] - borrow;
                    result[7*SIZE/8-1:0] <= {partial_diff7, partial_diff6, partial_diff5, partial_diff4, partial_diff3, partial_diff2, partial_diff1};
                    state <= IDLE;
                    done <= 1;
                end
            endcase
        end
    end

endmodule
