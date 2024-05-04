`timescale 1ns / 1ps

module Program_Counter(
    input clk,
    input reset,
    input [63:0]PC_In,
    output reg [63:0]PC_Out
    );
    
    initial begin
    PC_Out = 0;
     end
   
    always @(posedge clk)
    begin
    if (reset)
     PC_Out = 0;
    
    else
      PC_Out = PC_In;
    
    end
    
endmodule
