`timescale 1ns / 1ps

 module ALU_8_bit(
    input wire [7:0]a,
    input wire [7:0]b,
    input wire CarryIn,
    input [3:0]ALUop,
    output wire [7:0]Result,
    output wire CarryOut
    );

    wire Carry0, Carry1, Carry2, Carry3, Carry4, Carry5, Carry6, Carry7;
    
    // instantiating the ALU 1-bit module 8 times with different carry outs
    ALU_1_bit A0(a[0], b[0],CarryIn, ALUop,Result[0], Carry0);
    
    ALU_1_bit A1(a[1], b[1],Carry1, ALUop,Result[1], Carry1);
    
    ALU_1_bit A2(a[2], b[2],Carry1, ALUop,Result[2], Carry2);
    
    ALU_1_bit A3(a[3], b[3],Carry2, ALUop,Result[3], Carry3);
    
    ALU_1_bit A4(a[4], b[4],Carry3, ALUop,Result[4], Carry4);
    
    ALU_1_bit A5(a[5], b[5],Carry4, ALUop,Result[5], Carry5);
    
    ALU_1_bit A6(a[6], b[6],Carry5, ALUop,Result[6], Carry6);
    
    ALU_1_bit A7(a[7], b[7],Carry6, ALUop,Result[7], CarryOut);
    

endmodule


