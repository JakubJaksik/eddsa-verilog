module bit_reverse(
    input wire [455:0] in,
    output wire [455:0] out
);
    genvar i;
    
    generate
        for (i = 0; i < 456; i = i + 1) begin : reverse_bits
            assign out[i] = in[455 - i];
        end
    endgenerate
endmodule
