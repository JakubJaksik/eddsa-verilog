module mul #(
    parameter int SIZE = 448
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  [SIZE-1:0] a,
    input  [SIZE-1:0] b,
    output logic [2*SIZE-1:0] result,
    output logic done
);
    typedef enum logic [1:0] {IDLE, STAGE1, STAGE2, FINISH} state_t;
    state_t state = IDLE;
    
    logic add_224_start, add_448_start, add_896_start;
    logic add_224_done, add_448_done, add_896_done;
    logic [SIZE/2-1:0] add_224_a, add_224_b,
    logic [SIZE/2:0] add_224_result;
    logic [SIZE-1:0] add_448_a, add_448_b,
    logic [SIZE:0] add_448_result;
    logic [2*SIZE-1:0] add_896_a, add_896_b,
    logic [2*SIZE:0] add_896_result;

    logic [2*SIZE-1:0] accumulated_result,

    add_2_parts #(SIZE/2) adder_224 (
        .clk(clk),
        .rst(rst),
        .start(add_224_start),
        .a(add_224_a),
        .b(add_224_b),
        .result(add_224_result),
        .done(add_224_done)
    );

    add_4_parts #(SIZE) adder_448 (
        .clk(clk),
        .rst(rst),
        .start(add_448_start),
        .a(add_448_a),
        .b(add_448_b),
        .result(add_448_result),
        .done(add_448_done)
    );

    add_8_parts #(2*SIZE) adder_896 (
        .clk(clk),
        .rst(rst),
        .start(add_896_start),
        .a(add_896_a),
        .b(add_896_b),
        .result(add_896_result),
        .done(add_896_done)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            accumulated_result <= 0;
            add_224_start <= 0;
            add_448_start <= 0;
            add_896_start <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= STAGE1;
                        done <= 0;
                    end
                end
                STAGE1: begin
                    
                end
                STAGE2: begin
                    
                end
                FINISH: begin

                end
            endcase
        end
    end
endmodule

