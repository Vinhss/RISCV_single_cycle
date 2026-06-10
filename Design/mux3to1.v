// 3-to-1 Multiplexer (32-bit): Selects 1 out of 3 32-bit signals
module mux3to1 (
    input [1:0] select,
    input [31:0] in1, in2, in3,
    output [31:0] out
);
    // select = 00 -> in1 | select = 01 -> in2 | select = 10 -> in3
    assign out = select[1] ? (select[0] ? 32'b0 : in3) : (select[0] ? in2 : in1);
endmodule 