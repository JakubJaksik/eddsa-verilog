/*
    Module: add

    Description:
    This module performs staged addition of two large inputs (a and b) with a bit width specified by 
    the parameter SIZE. The width of SIZE must be divisible by 4. The module is designed 
    with a typical input size of 448 bits in mind.

    Parameters:
    - SIZE: Bit width of the inputs, must be divisible by 4.

    Inputs:
    - clk   : Clock signal.
    - rst   : Synchronous reset signal.
    - start : Initiates the addition process.
    - a, b  : Input operands with width SIZE.

    Outputs:
    - result   : Result of a + b, with a width of SIZE + 1 to accommodate any carry.
    - done  : Asserted high when the addition is complete.

    Operation:
    - On `start`, the module begins adding `a` and `b` in 4 stages, each handling a quarter of the bits.
      The FSM controls the addition process across IDLE, STAGE1, STAGE2, and STAGE3 states, with the 
      final result in `result` once `done` is asserted.
*/

module add_4_parts #(
    parameter int SIZE = 896 // Default bit width, must be divisible by 4
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  [SIZE-1:0] a,       
    input  [SIZE-1:0] b,       
    output logic [SIZE:0] result,
    output logic done
);
    typedef enum logic [1:0] {IDLE, STAGE1, STAGE2, STAGE3} state_t;
    state_t state = IDLE;

    logic [SIZE/4-1:0] partial_sum1, partial_sum2, partial_sum3;
    logic carry;

    always_ff@(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 1;
            result <= 0;
            partial_sum1 <= 0;
            partial_sum2 <= 0;
            partial_sum3 <= 0;
            carry <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        {carry, partial_sum1} <= a[SIZE/4-1:0] + b[SIZE/4-1:0];
                        state <= STAGE1;
                        done <= 0;
                    end 
                end
                STAGE1: begin
                    {carry, partial_sum2} <= a[2*SIZE/4-1:SIZE/4] + b[2*SIZE/4-1:SIZE/4] + carry;
                    state <= STAGE2;
                end
                STAGE2: begin
                    {carry, partial_sum3} <= a[3*SIZE/4-1:2*SIZE/4] + b[3*SIZE/4-1:2*SIZE/4] + carry;
                    state <= STAGE3;
                end
                STAGE3: begin
                    result[SIZE:3*SIZE/4] <= a[4*SIZE/4-1:3*SIZE/4] + b[4*SIZE/4-1:3*SIZE/4] + carry;
                    result[3*SIZE/4-1:0] <= {partial_sum3, partial_sum2, partial_sum1};
                    state <= IDLE;
                    done <= 1;
                end
            endcase
        end
    end

endmodule
