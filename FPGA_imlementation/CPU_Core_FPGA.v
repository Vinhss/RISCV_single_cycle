// Top module FPGA implementation: Interfaces with external I/O (Switches, Keys, LEDs)
module CPU_Core_FPGA(
    input [17:0] SW,   // Switches for control inputs
    input [3:0] KEY,   // Push buttons
    output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, // 7-segment displays for Debug output
    output [17:0] LEDR, // Red LEDs to indicate Switch status
    output [7:0] LEDG   // Green LEDs
);
    assign LEDR = SW; // Display switch states on LEDs

    // Declare core CPU bus signals
    wire [31:0] W_PC_in, W_PC_out, W_instruction, W_rs1, W_rd_data1, W_rs2, W_rd_data2, W_imm, W_rd, W_alu_out;
    wire [31:0] W_mux_out1, W_mux_out2, W_mux_out3;

    // Map debug signals to 7-segment displays
    hex_ssd C0(W_mux_out3[3:0],   HEX0);
    hex_ssd C1(W_mux_out3[7:4],   HEX1);
    hex_ssd C2(W_mux_out3[11:8],  HEX2);
    hex_ssd C3(W_mux_out3[15:12], HEX3);
    hex_ssd C4(W_mux_out2[3:0],   HEX4);
    hex_ssd C5(W_mux_out2[7:4],   HEX5);
    hex_ssd C6(W_mux_out1[3:0],   HEX6);
    hex_ssd C7(W_mux_out1[7:4],   HEX7);

    // Instantiate CPU Core. SW[17] acts as a manual Clock, SW[0] as Reset
    CPU_Core_Main DUT(
        .clk(SW[17]), .reset(SW[0]), 
        .W_PC_in(W_PC_in), .W_PC_out(W_PC_out), 
        .W_instruction(W_instruction), 
        .W_rs1(W_rs1), .W_rd_data1(W_rd_data1), 
        .W_rs2(W_rs2), .W_rd_data2(W_rd_data2), 
        .W_imm(W_imm), .W_rd(W_rd), .W_alu_out(W_alu_out)
    );

    // MUX circuit allows using Switch[15:8] to select which internal data to display on 7-segment LEDs
    mux3to1 M1(.select(SW[15:14]), .in1(W_PC_in),  .in2(W_rs1), .in3(W_rd_data1), .out(W_mux_out1));
    mux3to1 M2(.select(SW[12:11]), .in1(W_imm),    .in2(W_rs2), .in3(W_rd_data2), .out(W_mux_out2));
    mux3to1 M3(.select(SW[9:8]),   .in1(W_PC_out), .in2(W_rd),  .in3(W_alu_out),  .out(W_mux_out3));

endmodule