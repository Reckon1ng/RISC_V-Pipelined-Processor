`timescale 1ns / 1ps



module Instruction_Fetch(
    input clk,
    input reset,
    output [31:0] Instruction
    );
    
    wire [63:0] PC_In;
    wire [63:0] PC_Out;
    
    Program_Counter PC(clk, reset, PC_In, PC_Out);
    Adder adder(PC_Out, 4, PC_In);
    Instruction_Memory IM(PC_Out,Instruction);
    
    
endmodule

