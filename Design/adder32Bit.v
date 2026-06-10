// 32-bit Adder: Primarily used to calculate PC + 4
module adder32Bit(
    input clk, reset,
    input [31:0] input1, input2,
    output reg [31:0] out
);
    always @(posedge reset or posedge clk) begin
        if(reset) 
            out <= input1; // On reset, keep the initial input (usually the base PC)
        else
            out <= input1 + input2; // Perform addition
    end
endmodule 