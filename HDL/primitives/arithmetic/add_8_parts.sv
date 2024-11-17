/*
    Module: add

    Description:
    This module performs staged addition of two large inputs (a and b) with a bit width specified by 
    the parameter SIZE. The width of SIZE must be divisible by 8. The module is designed 
    with a typical input size of 448 bits in mind.

    Parameters:
    - SIZE: Bit width of the inputs, must be divisible by 8.

    Inputs:
    - clk   : Clock signal.
    - rst   : Synchronous reset signal.
    - start : Initiates the addition process.
    - a, b  : Input operands with width SIZE.

    Outputs:
    - result   : Result of a + b, with a width of SIZE + 1 to accommodate any carry.
    - done  : Asserted high when the addition is complete.

    Operation:
    - On `start`, the module begins adding `a` and `b` in 8 stages, each handling an eighth of the bits.
      The FSM controls the addition process across IDLE, STAGE1 to STAGE7 states, with the 
      final result in `result` once `done` is asserted.
*/

module add_8_parts #(
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

    logic [SIZE/8-1:0] partial_sum1, partial_sum2, partial_sum3, partial_sum4, partial_sum5, partial_sum6, partial_sum7;
    logic carry;

    always_ff@(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 1;
            result <= 0;
            partial_sum1 <= 0;
            partial_sum2 <= 0;
            partial_sum3 <= 0;
            partial_sum4 <= 0;
            partial_sum5 <= 0;
            partial_sum6 <= 0;
            partial_sum7 <= 0;
            carry <= 0;
        end else begin
            case (state) 
                IDLE: begin
                    if (start) begin
                        {carry, partial_sum1} <= a[SIZE/8-1:0] + b[SIZE/8-1:0];
                        state <= STAGE1;
                        done <= 0;
                    end 
                end
                STAGE1: begin
                    {carry, partial_sum2} <= a[2*SIZE/8-1:SIZE/8] + b[2*SIZE/8-1:SIZE/8] + carry;
                    state <= STAGE2;
                end
                STAGE2: begin
                    {carry, partial_sum3} <= a[3*SIZE/8-1:2*SIZE/8] + b[3*SIZE/8-1:2*SIZE/8] + carry;
                    state <= STAGE3;
                end
                STAGE3: begin
                    {carry, partial_sum4} <= a[4*SIZE/8-1:3*SIZE/8] + b[4*SIZE/8-1:3*SIZE/8] + carry;
                    state <= STAGE4;
                end
                STAGE4: begin
                    {carry, partial_sum5} <= a[5*SIZE/8-1:4*SIZE/8] + b[5*SIZE/8-1:4*SIZE/8] + carry;
                    state <= STAGE5;
                end
                STAGE5: begin
                    {carry, partial_sum6} <= a[6*SIZE/8-1:5*SIZE/8] + b[6*SIZE/8-1:5*SIZE/8] + carry;
                    state <= STAGE6;
                end
                STAGE6: begin
                    {carry, partial_sum7} <= a[7*SIZE/8-1:6*SIZE/8] + b[7*SIZE/8-1:6*SIZE/8] + carry;
                    state <= STAGE7;
                end
                STAGE7: begin
                    result[SIZE:7*SIZE/8] <= a[8*SIZE/8-1:7*SIZE/8] + b[8*SIZE/8-1:7*SIZE/8] + carry;
                    result[7*SIZE/8-1:0] <= {partial_sum7, partial_sum6, partial_sum5, partial_sum4, partial_sum3, partial_sum2, partial_sum1};
                    state <= IDLE;
                    done <= 1;
                end
            endcase
        end
    end

endmodule
