/*
    Module: sub_2_parts

    Description:
    This module performs staged subtraction of two large inputs (a and b) with a bit width specified by 
    the parameter SIZE. The width of SIZE must be divisible by 2. The module is designed with a typical 
    input size of 448 bits in mind, supporting larger operations by dividing the inputs into two segments 
    to handle subtraction with potential borrow across stages.

    Parameters:
    - SIZE: Bit width of the inputs, must be divisible by 2.

    Inputs:
    - clk   : Clock signal.
    - rst   : Synchronous reset signal.
    - start : Initiates the subtraction process.
    - a, b  : Input operands with width SIZE.

    Outputs:
    - result: Result of a - b, with a width of SIZE + 1 to accommodate any borrow.
    - done  : Asserted high when the subtraction is complete.

    Operation:
    - On `start`, the module begins subtracting `b` from `a` in 2 stages, each handling half of the bits.
      The FSM controls the subtraction process across states IDLE and STAGE1. Each stage 
      manages borrow propagation to accommodate multi-stage subtraction. The final result is stored in `result`, 
      with `done` signaling completion.
*/

module sub_2_parts #(
    parameter int SIZE = 224 // Default bit width, must be divisible by 2
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  [SIZE-1:0] a,       
    input  [SIZE-1:0] b,       
    output logic [SIZE:0] result,
    output logic done
);
    typedef enum logic [1:0] {IDLE, STAGE1} state_t;
    state_t state = IDLE;

    logic [SIZE/2-1:0] partial_diff1;
    logic borrow;

    always_ff@(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 1;
            result <= 0;
            partial_diff1 <= 0;
            borrow <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        {borrow, partial_diff1} <= a[SIZE/2-1:0] - b[SIZE/2-1:0];
                        state <= STAGE1;
                        done <= 0;
                    end 
                end
                STAGE1: begin
                    result[SIZE:SIZE/2] <= a[SIZE-1:SIZE/2] - b[SIZE-1:SIZE/2] - borrow;
                    result[SIZE/2-1:0] <= partial_diff1;
                    state <= IDLE;
                    done <= 1;
                end
            endcase
        end
    end

endmodule
