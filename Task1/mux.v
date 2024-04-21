`timescale 1ns / 1ps

module Mux_2x1(
    input [63:0] A,
    input [63:0] B,
    input S,
    output [63:0] Out
    );
    assign Out = (S == 1'b0) ? A : B;
endmodule
