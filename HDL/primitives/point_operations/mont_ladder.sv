import parameters_pkg::*;

module mont_ladder (
    input logic clk,
    input logic start,
    input logic [455:0] s,
    input logic [DATA_WIDTH-1:0] X, Y, Z,
    output logic [DATA_WIDTH-1:0] X_out, Y_out, Z_out,
    output logic done
);

    typedef enum logic [1:0] {
        IDLE, STAGE1, STAGE2, FINALIZE
    } state_t;
    state_t state = IDLE;

    logic [8:0] i, msb_index;

    find_msb_index find_msb_inst (
        .scalar(s),
        .msb_index(msb_index)
    );

    // Wewnętrzne sygnały
    logic [DATA_WIDTH-1:0] X1, Y1, Z1;
    logic [DATA_WIDTH-1:0] X2, Y2, Z2;
    logic [DATA_WIDTH-1:0] R0_X, R0_Y, R0_Z;
    logic [DATA_WIDTH-1:0] R1_X, R1_Y, R1_Z;
    logic [DATA_WIDTH-1:0] add_X_out, add_Y_out, add_Z_out;
    logic [DATA_WIDTH-1:0] double_X_out, double_Y_out, double_Z_out;
    logic point_add_done, point_double_done;

    logic point_add_start, point_double_start;

    point_add add_inst (
        .clk(clk),
        .start(point_add_start),
        .X1(X1), .Y1(Y1), .Z1(Z1),
        .X2(X2), .Y2(Y2), .Z2(Z2),
        .X3(add_X_out), .Y3(add_Y_out), .Z3(add_Z_out),
        .done(point_add_done)
    );

    point_double double_inst (
        .clk(clk),
        .start(point_double_start),
        .X1(X1), .Y1(Y1), .Z1(Z1),
        .X3(double_X_out), .Y3(double_Y_out), .Z3(double_Z_out),
        .done(point_double_done)
    );

    always_ff @(posedge clk) begin
        case (state)
            IDLE: begin
                done <= 0;
                if (start) begin
                    R0_X <= 0;
                    R0_Y <= R_MOD_P;
                    R0_Z <= R_MOD_P;
                    R1_X <= X;
                    R1_Y <= Y;
                    R1_Z <= Z;
                    i <= msb_index;
                    state <= STAGE2;
                end
            end

            STAGE1: begin
                point_add_start <= 0;
                point_double_start <= 0;
                if (point_add_done) begin
                    if (s[i] == 456'h0) begin
                        R1_X <= add_X_out;
                        R1_Y <= add_Y_out;
                        R1_Z <= add_Z_out;
                        R0_X <= double_X_out;
                        R0_Y <= double_Y_out;
                        R0_Z <= double_Z_out;
                    end else begin 
                        R0_X <= add_X_out;
                        R0_Y <= add_Y_out;
                        R0_Z <= add_Z_out;
                        R1_X <= double_X_out;
                        R1_Y <= double_Y_out;
                        R1_Z <= double_Z_out;
                    end
                    if (i > 0) begin
                        i <= i - 8'h1;
                        state <= STAGE2;
                    end else begin
                        state <= FINALIZE;
                    end
                end
            end

            STAGE2: begin
                if (s[i] == 456'h0) begin
                    X1 <= R0_X;
                    Y1 <= R0_Y;
                    Z1 <= R0_Z;
                    X2 <= R1_X;
                    Y2 <= R1_Y;
                    Z2 <= R1_Z;
                end else begin
                    X1 <= R1_X;
                    Y1 <= R1_Y;
                    Z1 <= R1_Z;
                    X2 <= R0_X;
                    Y2 <= R0_Y;
                    Z2 <= R0_Z;
                end

                point_add_start <= 1;
                point_double_start <= 1;
                state <= STAGE1;
            end

            FINALIZE: begin
                X_out <= R0_X;
                Y_out <= R0_Y;
                Z_out <= R0_Z;
                done <= 1;
                state <= IDLE;
            end
        endcase
    end
endmodule
