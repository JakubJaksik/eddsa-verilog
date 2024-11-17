/*
A module performing subtraction in Fp.
Input: 
 a, b - 448-bit numbers; 
Output: 
 out - the result (modulo p)
*/

import parameters_pkg::*;

module sub (
    input  logic clk,
    input  logic start,
    input  [DATA_WIDTH-1:0] a,
    input  [DATA_WIDTH-1:0] b,
    output logic [DATA_WIDTH-1:0] result,
    output logic done
);
    logic [DATA_WIDTH:0] temp_diff;
    logic [DATA_WIDTH:0] adjusted_diff;

    typedef enum logic [1:0] {IDLE, STAGE1, STAGE2} state_t;
    state_t state, next_state;

    always_ff @(posedge clk) begin
        if (start) begin
            state <= STAGE1;
            done <= 0;
        end else begin
            state <= next_state;
            if (state == STAGE2)
                done <= 1;
        end
    end

    always_ff @(posedge clk) begin
        case (state)
            IDLE: begin
                next_state = start ? STAGE1 : IDLE;
            end
            STAGE1: begin
                temp_diff = {1'b0, a} - {1'b0, b};
                next_state = STAGE2;
            end
            STAGE2: begin
                if (temp_diff[448])
                    adjusted_diff = temp_diff + MODULUS;
                else
                    adjusted_diff = temp_diff;
                result = adjusted_diff[447:0];
                next_state = IDLE;
            end
        endcase
    end

endmodule

