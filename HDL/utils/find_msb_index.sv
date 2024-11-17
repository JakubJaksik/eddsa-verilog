module find_msb_index(
    input logic [455:0] scalar,
    output logic [8:0] msb_index
);
    integer i;
    
    always_comb begin
        msb_index = 0;
        for (i = 455; i >= 0; i = i - 1) begin
            if (scalar[i] == 1) begin
                msb_index = i;
                break;
            end
        end
    end
endmodule
