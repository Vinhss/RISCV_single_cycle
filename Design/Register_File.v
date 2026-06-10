// Register File: Contains the 32 general-purpose RISC-V registers
module Register_File (
    input clk, wr_en, rd_en1, rd_en2,
    input [4:0] wr_addr, rd_addr1, rd_addr2,
    input [31:0] wr_data,
    output reg [31:0] rd_data1, rd_data2
);
    reg [31:0] Regfile [31:0];
    integer k;

    // Initialize default values for registers
    initial begin
        for (k=0; k<32; k=k+1) begin
            Regfile[k] = 32'b0;
        end
        // Pre-load some test values
        Regfile[5] = 32'd1;  // $t0 = 1
        Regfile[6] = 32'd2;  // $t1 = 10
        Regfile[7] = 32'd3;  // $t2 = 11
    end
    
    // Read Channel 1: Read rs1
    always @(rd_data1 or Regfile[rd_addr1]) begin
        if (rd_addr1 == 5'b0) rd_data1 = 32'b0; // Register x0 is hardwired to 0
        else if (rd_en1) rd_data1 = Regfile[rd_addr1];
    end
        
    // Read Channel 2: Read rs2
    always @(rd_data2 or Regfile[rd_addr2]) begin
        if (rd_addr2 == 5'b0) rd_data2 = 32'b0; // Register x0 is hardwired to 0
        else if (rd_en2) rd_data2 = Regfile[rd_addr2];
    end
        
    // Write Channel: Synchronous write on positive clock edge
    always @(posedge clk) begin
        if (wr_en == 1'b1) begin 
            Regfile[wr_addr] = wr_data;
        end
    end
endmodule 