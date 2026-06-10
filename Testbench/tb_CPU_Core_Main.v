`timescale 1ns / 1ps

module tb_CPU_Core_Main();

    reg clk;
    reg reset;
    wire [31:0] W_PC_in;
    wire [31:0] W_rs1;
    wire [31:0] W_rs2;
    wire [31:0] W_rd;
    wire [31:0] W_rd_data1;
    wire [31:0] W_rd_data2;
    wire [31:0] W_imm;
    wire [31:0] W_PC_out;
    wire [31:0] W_alu_out;
    wire [31:0] W_instruction;

    CPU_Core_Main uut (
        .clk(clk),
        .reset(reset),
        .W_PC_in(W_PC_in),
        .W_PC_out(W_PC_out),
        .W_instruction(W_instruction),
        .W_rs1(W_rs1),
        .W_rd_data1(W_rd_data1),
        .W_rs2(W_rs2),
        .W_rd_data2(W_rd_data2),
        .W_imm(W_imm),
        .W_rd(W_rd),
        .W_alu_out(W_alu_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin

        reset = 1; 
        #15;
        reset = 0; 
        #150;

        $display("------------------------------------------------");
      $display("simulation complete!");
        $display("------------------------------------------------");
        $finish;
    end

    initial begin
        $display("Time(ns)\t PC_Addr\t Instruction(Hex)\t ALU_Output");
        $display("----------------------------------------------------------------------");
        $monitor("%0t\t\t %d\t\t %h\t\t %d", $time, W_PC_in, W_instruction, W_alu_out);
    end


    initial begin
        $dumpfile("riscv_core_waveform.vcd"); 
        $dumpvars(0, tb_CPU_Core_Main);      
    end

endmodule