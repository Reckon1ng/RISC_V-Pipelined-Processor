`timescale 1ns / 1ps



module Instruction_Parser(
    input [31:0] Instruction,
    output [6:0] Opcode,
    output [4:0] RD,
    output [2:0] Funct3,
    output [4:0] RS1,
    output [4:0] RS2,
    output [6:0] Funct7
    );
    assign Opcode = Instruction[6:0];
    assign RD = Instruction[11:7];
    assign Funct3 = Instruction[14:12];
    assign RS1 = Instruction[19:15];
    assign RS2 = Instruction[24:20];
    assign Funct7 = Instruction[31:25];
endmodule
