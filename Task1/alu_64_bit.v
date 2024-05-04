module ALU64bit(
    input [63:0] A,
    input [63:0] B,
    input [3:0] ALUOp,
    output reg [63:0] Result
    );
    
always @(*) begin
    case (ALUOp)
        4'b0000: Result = A & B; //AND
        4'b0001: Result = A | B; //OR
        4'b0010: Result = A + B; //ADD
        4'b0110: Result = A - B; //SUB
        4'b1100: Result = ~(A | B); //NOR
        4'b1000: Result = A * (2 ** B); // SLLI
    endcase
    
end
endmodule