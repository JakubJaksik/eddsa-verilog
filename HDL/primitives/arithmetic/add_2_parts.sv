/*
    Module: add

    Description:
    This module performs staged addition of two large inputs (a and b) with a bit width specified by 
    the parameter SIZE. The width of SIZE must be divisible by 2. The module is designed 
    with a typical input size of 448 bits in mind.

    Parameters:
    - SIZE: Bit width of the inputs, must be divisible by 2.

    Inputs:
    - clk   : Clock signal.
    - rst   : Synchronous reset signal.
    - start : Initiates the addition process.
    - a, b  : Input operands with width SIZE.

    Outputs:
    - result   : Result of a + b, with a width of SIZE + 1 to accommodate any carry.
    - done  : Asserted high when the addition is complete.

    Operation:
    - On `start`, the module begins adding `a` and `b` in 2 stages, each handling half of the bits.
      The FSM controls the addition process across IDLE and STAGE1 states, with the 
      final result in `result` once `done` is asserted.
*/

module add_2_parts #(
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

    logic [SIZE/2-1:0] partial_sum1;
    logic carry;

    always_ff@(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 1;
            result <= 0;
            partial_sum1 <= 0;
            carry <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        {carry, partial_sum1} <= a[SIZE/2-1:0] + b[SIZE/2-1:0];
                        state <= STAGE1;
                        done <= 0;
                    end 
                end
                STAGE1: begin
                    result[SIZE:SIZE/2] <= a[SIZE-1:SIZE/2] + b[SIZE-1:SIZE/2] + carry;
                    result[SIZE/2-1:0] <= partial_sum1;
                    state <= IDLE;
                    done <= 1;
                end
            endcase
        end
    end

endmodule
