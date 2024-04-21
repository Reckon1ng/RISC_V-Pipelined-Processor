`timescale 1ns / 1ps
module registerfile(

    input [63:0]WriteData,
    input [4:0]RS1,
    input [4:0]RS2,
    input [4:0]RD,
    input RegWrite, clk, reset,
    output reg [63:0]ReadData1,
    output reg [63:0]ReadData2
);   
reg [63:0] Registers [31:0];
integer i;

initial
    begin 
        for(i=0; i < 32; i=i+1)
            begin
                Registers[i]  = i;      
            end
    end 

always@(posedge clk)

begin
    if(RegWrite==1)
    begin
        Registers[RD] = WriteData;  
    end 
    
end 

always @(*)
begin
    if(reset)
    begin
         ReadData1 = 0;
         ReadData2 = 0;
    end
    
    else
    begin
        ReadData1 = Registers[RS1];
        ReadData2 = Registers[RS2]; 
    end
end
endmodule
