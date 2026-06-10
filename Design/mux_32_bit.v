// 2-to-1 Multiplexer (32-bit): Selects write data from ALU or Data Memory
module mux_32_bit (
    input [31:0] in0, in1,
    input select,
    output [31:0] mux_out
);
    // select = 1 chooses in1, select = 0 chooses in0
    assign mux_out = select ? in1 : in0; 
endmodule 