`timescale 1ns / 1ps

module top_module(
    input [31:0]instruction,
    output wire [63:0]ReadData1, 
    output wire [63:0]ReadData2
    );
    
    wire [63:0]WriteData;
    wire RegWrite, clk, reset;
    
    
    wire [6:0]opcode;
    wire [4:0]rd;
    wire [2:0]funct3;
    wire [4:0]rs1;
    wire [4:0]rs2;
    wire [6:0]funct7;
    
    //calling instruction_parser
    instruction_parser IP (instruction, opcode,rd,funct3,rs1,rs2,funct7);
    
    //calling registerfile with rs1,rs2 and rd from the instruction parser fucntion
    registerfile RF(WriteData, rs1,rs2,rd,RegWrite,clk,reset,ReadData1,ReadData2);
    
endmodule
