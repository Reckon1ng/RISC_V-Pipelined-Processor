`timescale 1ns / 1ps

module ALU_1_bit(
    input wire a,
    input wire b,
    input wire CarryIn,
    input [3:0]ALUop,
    output wire Result,
    output wire CarryOut
    );
    
    // Carryout
    assign CarryOut = (a&CarryIn) | (b&CarryIn) | (a&b);	 

    wire mux1out, mux2out;
    wire ainvert = ALUop[3], binvert = ALUop[2];
    wire abar = ~a, bbar = ~b;
    
    //Use two mux for inverse
    assign mux1out = ainvert ? abar : a;
    assign mux2out = binvert ? bbar : b;
    
    // calculating result
    assign Result = ALUop[1] ? (mux1out + mux2out + CarryIn): ALUop[0] ? (mux1out || mux2out) : (mux1out & mux2out);

endmodule


