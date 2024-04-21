`timescale 1ns / 1ps

module immediate_data(
    input [31:0] instruction,
    output reg [63:0] imm_data
    );
    wire [1:0] selbit ;
    reg [11:0] i_imm;
    reg [11:0] s_imm;
    reg [11:0] sb_imm;
    assign selbit = instruction[6:5];
    
    always@(instruction)
    begin
    case(selbit)
    2'b00:
     begin
     //loading the format
     i_imm = instruction[31:20];
     imm_data = {{52{i_imm[11]}}, i_imm[11:0]};
     end
       
    2'b01: 
    begin
     // storing the format
     s_imm = {instruction[31:25], instruction[11:7]};
     imm_data = {{52{s_imm[11]}}, s_imm[11:0]};
     end
    
    2'b11: 
    begin
    // conditional format
     sb_imm = {instruction[31], instruction[7],instruction[30:25],instruction[11:8]};
     imm_data = {{52{sb_imm[11]}}, sb_imm[11:0]};
     end
   endcase
   end
endmodule
