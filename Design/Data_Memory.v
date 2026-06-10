// Data Memory: RAM for storing computational data
module Data_Memory (
    input clk, wr_en, rd_en,
    input [4:0] addr,       // 5-bit address (for 32 memory locations)
    input [31:0] wr_data,
    output [31:0] rd_data
);
    reg [31:0] DMemory [31:0]; // 32x32-bit RAM
    integer k;
    
    // Read data if rd_en flag is active
    assign rd_data = (rd_en) ? DMemory[addr] : 32'b0;

    // Initialize memory with zeros
    initial begin
        for (k=0; k<32; k=k+1) begin
            DMemory[k] = 32'b0;
        end
    end
        
    // Synchronous write on the positive edge of the clock
    always @(posedge clk) begin
        if (wr_en) DMemory[addr] = wr_data; // Write data if wr_en is active
    end
endmodule 