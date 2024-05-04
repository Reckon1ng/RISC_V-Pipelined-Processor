module top_control(
input [6:0]Opcode,
input [3:0]Funct,
output Branch,
output MemRead,
output MemtoReg,
output MemWrite,
output ALUSrc,
output RegWrite,
output [3:0]Operation
);
//carry

wire [1:0]ALUop;

Control_Unit CU(Opcode,Branch,MemRead, MemtoReg,ALUop, MemWrite, ALUSrc, RegWrite);
ALU_Control AC(ALUop,Funct,Operation);

endmodule