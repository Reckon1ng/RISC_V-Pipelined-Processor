`timescale 1ns / 1ps


module Adder(
    input [63:0] a, b,
    output reg [63:0] out
);
always@(*)
    out = a + b; // add elements a and b
endmodule

module alu_64
(
    input [63:0] a, b,
    input [3:0] ALUOp,
    output reg [63:0] Result,
    output reg Zero,
    output reg is_greater
);
    localparam [3:0]
    AND = 4'b0000,
    OR	= 4'b0001,
    ADD	= 4'b0010,
    Sub	= 4'b0110,
    NOR = 4'b1100,
    Lesser=4'b0100,
    LeftShift=4'b0111;
    assign ZERO = (Result == 0);
    
    always @ (ALUOp, a, b)
    begin
        case (ALUOp)
            AND: Result = a & b;
            OR:	 Result = a | b;
            ADD: Result = a + b;
            Sub: Result = a - b;
            NOR: Result = ~(a | b);
            Lesser: Result = ( a < b)? 0: 1;
            LeftShift: Result = a << b; // for left shifting all values
            default: Result = 0;
        endcase
         // Check if the Result is zero
        Zero = (Result == 64'd0) ? 1'b1 : 1'b0;

        // Check if a is greater than b
        is_greater = (a > b) ? 1'b1 : 1'b0;
    end
    
endmodule

module ALU_Control
(
    input [1:0] ALUOp,
    input [3:0] Funct,
    output reg [3:0] Operation
);
always @(*)
begin
case(ALUOp)
    2'b00: // ALUOp = 00, R-type instruction
    begin
        Operation = 4'b0010; // Add
    end
    
    2'b01: // ALUOp = 01, branch type instructions
    begin
        case(Funct[2:0])
            3'b000: // Funct = 000, beq
            begin
                Operation = 4'b0110; // Subtract
            end
            
            3'b100: // Funct = 100, blt
            begin
                Operation = 4'b0100; // Less than
            end
        endcase
    end

    2'b10: // ALUOp = 10, immediate type instructions
    begin
        case(Funct)
            4'b0000: // Funct
            begin
                Operation = 4'b0010; // Add
            end
            
            4'b1000: // Funct = 1000
            begin
                Operation = 4'b0110; // Subtract
            end
            
            4'b0111: // Funct = 0111
            begin
                Operation = 4'b0000; // AND
            end
            
            4'b0110: // Funct = 0110
            begin
                Operation = 4'b0001; // OR
            end
        endcase
    end
endcase
end

endmodule

module Branch_Control
(
input Branch, Zero, Is_Greater_Than,
input [3:0] funct,
output reg switch, Flush
);


always @(*) begin
// Check if Branch signal is 1 then we swithc branch and flush else not
if (Branch) begin

    // Use a case statement based on funct[2:0] value
    case ({funct[2:0]})

        // Case when funct[2:0] is 3'b000
        3'b000: begin
            // Check if Zero signal is active
            if (Zero)
                switch = 1;  // Set switch_branch to 1
            else
                switch = 0;  // Set switch_branch to 0
        end

        // Case when funct[2:0] is 3'b001
        3'b001: begin
            // Check if Zero signal is active
            if (Zero)
                switch = 0;  // Set switch_branch to 0
            else
                switch = 1;  // Set switch_branch to 1
        end

        // Case when funct[2:0] is 3'b101
        3'b101: begin
            // Check if Is_Greater_Than signal is active
            if (Is_Greater_Than)
                switch = 1;  // Set switch_branch to 1
            else
                switch = 0;  // Set switch_branch to 0
        end

        // Case when funct[2:0] is 3'b100
        3'b100: begin
            // Check if Is_Greater_Than signal is active
            if (Is_Greater_Than)
                switch = 0;  // Set switch_branch to 0
            else
                switch = 1;  // Set switch_branch to 1
        end

        // Default case
        default: switch = 0;  // Set switch_branch to 0

    endcase

end

else
    switch = 0;  // Set switch_branch to 0 if Branch signal is inactive
end

always @(switch) begin
    // Based on the switch_branch value
    if (switch)
        Flush = 1;  // switch_branch is 1
    else
        Flush = 0;  // switch_branch is 0
    
end

endmodule

module Control_Unit (
    input [6:0] Opcode,
    output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output reg [1:0] ALUOp 
);

    // logic block
    always @(*) begin
        // Opcode-based case statement
case (Opcode)
    7'b0110011: // R-type (add/sub)
        begin
            // outputs according to R-type instruction
            ALUSrc = 1'b0;
            MemtoReg = 1'b0;
            RegWrite = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            Branch = 1'b0;
            ALUOp = 2'b10;
        end
    7'b0000011: // I-type 
        begin
            // outputs according to I-type instruction
            ALUSrc = 1'b1;
            MemtoReg = 1'b1;
            RegWrite = 1'b1;
            MemRead = 1'b1;
            MemWrite = 1'b0;
            Branch = 1'b0;
            ALUOp = 2'b00;
        end
    7'b0100011: // S-type 
        begin
            // outputs according to S-type instruction
            ALUSrc = 1'b1;
            MemtoReg = 1'bx; // 'x' = value
            RegWrite = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b1;
            Branch = 1'b0;
            ALUOp = 2'b00;
        end
    7'b1100011: // Branch instruction
        begin
            // Set output signals for branch instruction
            ALUSrc = 0;
            MemtoReg = 1'bX; // X = unknown
            RegWrite = 0;
            MemRead = 0;
            MemWrite = 0;
            Branch = 1;
            ALUOp = 2'b01;
        end
    7'b0010011: // I-type
        begin
            // I-type instruction (other)
        Branch = 1'b0;
        MemRead = 1'b0;
        MemtoReg = 1'b0;
        MemWrite = 1'b0;
        ALUSrc = 1'b1;
        RegWrite = 1'b1;
        ALUOp = 2'b00;
        end
    default:
        begin
    // case for invalid type
    Branch = 1'b0;
    MemRead = 1'b0;
    MemtoReg = 1'b0;
    MemWrite = 1'b0;
    ALUSrc = 1'b0;
    RegWrite = 1'b0;
    ALUOp = 2'b00;
        end
endcase
    end

endmodule

module Data_Memory
(
input [63:0] Mem_Addr,
input [63:0] Write_Data,
input clk, MemWrite, MemRead,
output reg [63:0] Read_Data,
output [63:0] ele1,
output [63:0] ele2,
output [63:0] ele3,
output [63:0] ele4,
output [63:0] ele5
);

reg [7:0] DataMemory [512:0];

assign  ele1  = DataMemory[256];
assign  ele2 = DataMemory[264];
assign  ele3 = DataMemory[272];                      
assign  ele4 = DataMemory[280];
assign  ele5 = DataMemory[288];
integer i;

initial  
begin 
for (i = 0; i < 512; i = i + 1)
begin 
DataMemory[256] = 8'd20;
 DataMemory[264]=  8'd10;
 DataMemory[272]= 8'd30;
 DataMemory[280] = 8'd40;
 DataMemory[288]= 8'd50;
 DataMemory[296]= 8'd100;

end
end    

	
always @ (posedge clk)
begin
if (MemWrite)
begin
    DataMemory[Mem_Addr] = Write_Data[7:0];
    DataMemory[Mem_Addr+1] = Write_Data[15:8];
    DataMemory[Mem_Addr+2] = Write_Data[23:16];
    DataMemory[Mem_Addr+3] = Write_Data[31:24];
    DataMemory[Mem_Addr+4] = Write_Data[39:32];
    DataMemory[Mem_Addr+5] = Write_Data[47:40];
    DataMemory[Mem_Addr+6] = Write_Data[55:48];
    DataMemory[Mem_Addr+7] = Write_Data[63:56];
end
end

	always @ (*)
	begin
		if (MemRead)
Read_Data = {DataMemory[Mem_Addr+7],DataMemory[Mem_Addr+6],DataMemory[Mem_Addr+5],DataMemory[Mem_Addr+4],DataMemory[Mem_Addr+3],DataMemory[Mem_Addr+2],DataMemory[Mem_Addr+1],DataMemory[Mem_Addr]};
	end
endmodule

module EX_MEM(
    input clk,                     // Clock signal
    input Flush,                   // Flush control signal
    input RegWrite,                // Control signal for enabling register write
    input MemtoReg,                // Control signal for selecting memory or ALU result for register write
    input Branch,                  // Control signal for branch instruction
    input Zero,                    // Control signal indicating the ALU result is zero
    input MemWrite,                // Control signal for memory write
    input MemRead,                 // Control signal for memory read
    input is_greater,              // Control signal indicating the comparison result of the ALU operation
    input [63:0] immvalue_added_pc, // Immediate value added to the program counter
    input [63:0] ALU_result,       // Result of the ALU operation
    input [63:0] WriteData,        // Data to be written to memory or register file
    input [3:0] function_code,     // Function code for ALU operation
    input [4:0] destination_reg,   // Destination register for register write

    output reg RegWrite_out,       // Output signal for enabling register write
    output reg MemtoReg_out,       // Output signal for selecting memory or ALU result for register write
    output reg Branch_out,         // Output signal for branch instruction
    output reg Zero_out,           // Output signal indicating the ALU result is zero
    output reg MemWrite_out,       // Output signal for memory write
    output reg MemRead_out,        // Output signal for memory read
    output reg is_greater_out,     // Output signal indicating the comparison result of the ALU operation
    output reg [63:0] immvalue_added_pc_out, // Output signal for immediate value added to the program counter
    output reg [63:0] ALU_result_out,       // Output signal for the ALU result
    output reg [63:0] WriteData_out,        // Output signal for data to be written to memory or register file
    output reg [3:0] function_code_out,     // Output signal for function code for ALU operation
    output reg [4:0] destination_reg_out    // Output signal for destination register for register write
);

    // Assign output values based on control signals
    always @(posedge clk) begin
        if (Flush) begin
            // Reset output values when flush signal is active
            RegWrite_out = 0;
            MemtoReg_out = 0;
            Branch_out = 0;
            Zero_out = 0;
            is_greater_out = 0;
            MemWrite_out = 0;
            MemRead_out = 0;
            immvalue_added_pc_out = 0;
            ALU_result_out = 0;
            WriteData_out = 0;
            function_code_out = 0;
            destination_reg_out = 0;
        end 
        else begin
            // Assign output values based on input signals
            RegWrite_out = RegWrite;
            MemtoReg_out = MemtoReg;
            Branch_out = Branch;
            Zero_out = Zero;
            is_greater_out = is_greater;
            MemWrite_out = MemWrite;
            MemRead_out = MemRead;
            immvalue_added_pc_out = immvalue_added_pc;
            ALU_result_out = ALU_result;
            WriteData_out = WriteData;
            function_code_out = function_code;
            destination_reg_out = destination_reg;
        end
    end

endmodule

module Forwarding_Unit
(
    input [4:0] EXMEM_rd, MEMWB_rd,
    input [4:0] IDEX_rs1, IDEX_rs2,
    input EXMEM_RegWrite, EXMEM_MemtoReg,
    input MEMWB_RegWrite,

    output reg [1:0] fwd_A, fwd_B
);

always @(*) begin
    // Forwarding logic for operand A
    if (EXMEM_rd == IDEX_rs1 && EXMEM_RegWrite && EXMEM_rd != 0) begin
        fwd_A = 2'b10;  // Forward value from the EX/MEM pipeline stage
    end else if ((MEMWB_rd == IDEX_rs1) && MEMWB_RegWrite && (MEMWB_rd != 0) &&
               !(EXMEM_RegWrite && (EXMEM_rd != 0) && (EXMEM_rd == IDEX_rs1))) begin
        fwd_A = 2'b01;  // Forward value from the MEM/WB pipeline stage
    end else begin
        fwd_A = 2'b00;  // No forwarding for operand A
    end
    
    // Forwarding logic for operand B
    if ((EXMEM_rd == IDEX_rs2) && EXMEM_RegWrite && EXMEM_rd != 0) begin
        fwd_B = 2'b10;  // Forward value from the EX/MEM pipeline stage
    end else if ((MEMWB_rd == IDEX_rs2) && (MEMWB_RegWrite == 1) && (MEMWB_rd != 0) &&
               !(EXMEM_RegWrite && (EXMEM_rd != 0) && (EXMEM_rd == IDEX_rs2))) begin
        fwd_B = 2'b01;  // Forward value from the MEM/WB pipeline stage
    end else begin
        fwd_B = 2'b00;  // No forwarding for operand B
    end
end

endmodule

module Hazard_Detection
(
    input [4:0] current_rd, previous_rs1, previous_rs2,
    input current_MemRead,
    output reg mux_out,
    output reg enable_Write, enable_PCWrite
);

always @(*) begin
    // Hazard detection logic
    if (current_MemRead && (current_rd == previous_rs1 || current_rd == previous_rs2)) begin
        // Hazard detected: Set control signals accordingly
        mux_out = 0;             //NO the multiplexer output
        enable_Write = 0;       // no write to the next pipeline stage
        enable_PCWrite = 0;    // no PC write
    end else begin
        // No hazard detected: Set control signals accordingly
        mux_out = 1;             // Enable the multiplexer output
        enable_Write = 1;       // Enable write to the next pipeline stage
        enable_PCWrite = 1;    // Enable PC write
    end
end

endmodule

module ID_EX(
input        clk,                            // Clock signal
input        Flush,                          // Flush control signal
input [63:0] program_counter_addr,    // Program counter address input
input [63:0] read_data1,               // Data 1 input
input [63:0] read_data2,               // Data 2 input
input [63:0] immediate_value,          // Immediate value input
input [3:0]  function_code,             // Function code input
input [4:0]  destination_reg,           // Destination register input
input [4:0]  source_reg1,                // Source register 1 input
input [4:0]  source_reg2,               // Source register 2 input
input        MemtoReg,                        // Memory-to-register control signal
input        RegWrite,                        // Register write control signal
input        Branch,                           // Branch control signal
input        MemWrite,                         // Memory write control signal
input        MemRead,                          // Memory read control signal
input        ALUSrc,                           // ALU source control signal
input [1:0]  ALU_op,                     // ALU operation control signal

output reg [63:0] program_counter_addr_out,    // Output: Stored program counter address
output reg [63:0] read_data1_out,               // Output: Stored Data 1
output reg [63:0] read_data2_out,               // Output: Stored Data 2
output reg [63:0] immediate_value_out,          // Output: Stored Immediate value
output reg [3:0] function_code_out,             // Output: Stored Function code
output reg [4:0] destination_reg_out,           // Output: Stored Destination register
output reg [4:0] source_reg1_out,                     // Output: Stored Source register 1
output reg [4:0] source_reg2_out,                     // Output: Stored Source register 2
output reg MemtoReg_out,                        // Output: Stored Memory-to-register control
output reg RegWrite_out,                            // Output: Stored Register write control
output reg Branch_out,                               // Output: Stored Branch control
output reg MemWrite_out,                            // Output: Stored Memory write control
output reg MemRead_out,                         // Output: Stored Memory read control
output reg ALUSrc_out,                               // Output: Stored ALU source control
output reg [1:0] ALU_op_out                     // Output: Stored ALU operation control

);

always @(posedge clk) begin
if (Flush) 
begin
// Reset all output registers to 0
program_counter_addr_out = 0;
read_data1_out = 0;
read_data2_out = 0;
immediate_value_out = 0;
function_code_out = 0;
destination_reg_out = 0;

source_reg1_out = 0;
source_reg2_out = 0;
MemtoReg_out = 0;

RegWrite_out = 0;
Branch_out = 0;
MemWrite_out = 0;

MemRead_out = 0;
ALUSrc_out = 0;
ALU_op_out = 0;
    end 
    
    else 
    begin
        // Pass input values to output registers
    program_counter_addr_out = program_counter_addr;
    read_data1_out = read_data1;
    read_data2_out = read_data2;
    
    immediate_value_out = immediate_value;
    function_code_out = function_code;
    destination_reg_out = destination_reg;
    
    source_reg1_out = source_reg1;
    source_reg2_out = source_reg2;
    RegWrite_out = RegWrite;
    MemtoReg_out = MemtoReg;
    Branch_out = Branch;
    MemWrite_out = MemWrite;
    
    MemRead_out = MemRead;
    ALUSrc_out = ALUSrc;
    ALU_op_out = ALU_op;
    end
end

endmodule 

module IF_ID(
    input clk, IFID_Write, Flush,
    input [63:0] PC_addr,
    input [31:0] Instruc,
    output reg [63:0] PC_store,
    output reg [31:0] Instr_store
);

always @(posedge clk) begin
    // Check if Flush signal is active
    if (Flush) begin
        // Reset stored values
        PC_store <= 0;
        Instr_store <= 0;
    end else if (!IFID_Write) begin
        // Preserve stored values
        PC_store <= PC_store;
        Instr_store <= Instr_store;
    end else begin
        // IF/ID pipeline registers
        PC_store <= PC_addr;
        Instr_store <= Instruc;
    end
end

endmodule

module data_extractor (
    input [31:0] instruction,
    output reg [63:0] imm_data
);

  wire [6:0] opcode;  // Wire to hold the opcode 
  assign opcode = instruction[6:0];  // Assign the lower 7 bits to opcode wire

  always @(*)  
  begin
      case (opcode)
          7'b0000011: imm_data =  {{52{instruction[31]}}, instruction[31:20]};  // I-type instruction with 12-bit immediate
          7'b0100011: imm_data = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};  // S-type instruction with 12-bit immediate
          7'b1100011: imm_data = {{52{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8]};  // B-type instruction with 13-bit immediate
          7'b0010011: imm_data = {{52{instruction[31]}}, instruction[31:20]};  // I-type instruction with 12-bit immediate
          default : imm_data = 64'd0;  // No immediate value for other opcode values
      endcase
  end

endmodule

module Instruction_Parser(
    input [31:0] instruction,
    output [6:0] opcode, funct7,
    output [4:0] rd , rs1 , rs2,
    output [2:0] funct3 

);

assign opcode = instruction[6:0];
assign rd = instruction[11:7];
assign funct3 = instruction[14:12];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign funct7 = instruction[31:25];
    
    endmodule

module Instruction_Memory
(
	input [63:0] Inst_Address,
	output reg [31:0] Instruction
);
	reg [7:0] inst_mem [147:0];
	
initial
	begin
		inst_mem[0]  = 8'h93; // more explanation of code in part 1
		inst_mem[1]  = 8'h05;
		inst_mem[2]  = 8'h60;
		inst_mem[3]  = 8'h00;
		inst_mem[4]  = 8'h93;
		inst_mem[5]  = 8'h0E;
		inst_mem[6]  = 8'h60;
		inst_mem[7]  = 8'h00;
		inst_mem[8]  = 8'h13;
		inst_mem[9]  = 8'h0F;
		inst_mem[10] = 8'h00;
		inst_mem[11] = 8'h00;
		inst_mem[12] = 8'h13;
		inst_mem[13] = 8'h0F;
		inst_mem[14] = 8'h00;
		inst_mem[15] = 8'h00;
		inst_mem[16] = 8'h13;
		inst_mem[17] = 8'h0E;
		inst_mem[18] = 8'h60;
		inst_mem[19] = 8'h00;
		inst_mem[20] = 8'h23;
		inst_mem[21] = 8'h20;
		inst_mem[22] = 8'hBF;
		inst_mem[23] = 8'h10;
		inst_mem[24] = 8'h93;
		inst_mem[25] = 8'h8F;
		inst_mem[26] = 8'h1F;
		inst_mem[27] = 8'h00;
		inst_mem[28] = 8'h13;
		inst_mem[29] = 8'h0F;
		inst_mem[30] = 8'h8F;
		inst_mem[31] = 8'h00;
		inst_mem[32] = 8'h93;
		inst_mem[33] = 8'h85;
		inst_mem[34] = 8'hF5;
		inst_mem[35] = 8'hFF;
		inst_mem[36] = 8'h63;
		inst_mem[37] = 8'h04;
		inst_mem[38] = 8'hFE;
		inst_mem[39] = 8'h01;
		inst_mem[40] = 8'hE3;
		inst_mem[41] = 8'h06;
		inst_mem[42] = 8'h00;
		inst_mem[43] = 8'hFE;
		inst_mem[44] = 8'h13;
		inst_mem[45] = 8'h0F;
		inst_mem[46] = 8'h00;
		inst_mem[47] = 8'h00;
		inst_mem[48] = 8'h93;
		inst_mem[49] = 8'h0F;
		inst_mem[50] = 8'h0F;
		inst_mem[51] = 8'h00;
		inst_mem[52] = 8'h93;
		inst_mem[53] = 8'h0E;
		inst_mem[54] = 8'h00;
		inst_mem[55] = 8'h00;
		inst_mem[56] = 8'h93;
		inst_mem[57] = 8'h05;
		inst_mem[58] = 8'h60;
		inst_mem[59] = 8'h00;
		inst_mem[60] = 8'h63;
		inst_mem[61] = 8'h8C;
		inst_mem[62] = 8'hE5;
		inst_mem[63] = 8'h05;
		inst_mem[64] = 8'h33;
		inst_mem[65] = 8'h85;
		inst_mem[66] = 8'h0E;
		inst_mem[67] = 8'h00;
		inst_mem[68] = 8'h93;
		inst_mem[69] = 8'h0F;
		inst_mem[70] = 8'h1F;
		inst_mem[71] = 8'h00;
		inst_mem[72] = 8'h13;
		inst_mem[73] = 8'h8E;
		inst_mem[74] = 8'h8E;
		inst_mem[75] = 8'h00;
		inst_mem[76] = 8'h63;
		inst_mem[77] = 8'h88;
		inst_mem[78] = 8'hBF;
		inst_mem[79] = 8'h02;
		inst_mem[80] = 8'h83;
		inst_mem[81] = 8'h27;
		inst_mem[82] = 8'h0E;
		inst_mem[83] = 8'h10;
		inst_mem[84] = 8'h03;
		inst_mem[85] = 8'h28;
		inst_mem[86] = 8'h05;
		inst_mem[87] = 8'h10;
		inst_mem[88] = 8'h63;
		inst_mem[89] = 8'hCE;
		inst_mem[90] = 8'h07;
		inst_mem[91] = 8'h01;
		inst_mem[92] = 8'h93;
		inst_mem[93] = 8'h8F;
		inst_mem[94] = 8'h1F;
		inst_mem[95] = 8'h00;
		inst_mem[96] = 8'h13;
		inst_mem[97] = 8'h0E;
		inst_mem[98] = 8'h8E;
		inst_mem[99] = 8'h00;
		inst_mem[100] = 8'hE3;
		inst_mem[101] = 8'h04;
		inst_mem[102] = 8'h00;
		inst_mem[103] = 8'hFC;
		inst_mem[104] = 8'h13;
		inst_mem[105] = 8'h0F;
		inst_mem[106] = 8'h1F;
		inst_mem[107] = 8'h00;
		inst_mem[108] = 8'h13;
		inst_mem[109] = 8'h0E;
		inst_mem[110] = 8'h8E;
		inst_mem[111] = 8'h00;
		inst_mem[112] = 8'hE3;
		inst_mem[113] = 8'h06;
		inst_mem[114] = 8'h00;
		inst_mem[115] = 8'hFC;
		inst_mem[116] = 8'h13;
		inst_mem[117] = 8'h05;
		inst_mem[118] = 8'h0E;
		inst_mem[119] = 8'h00;
		inst_mem[120] = 8'hE3;
		inst_mem[121] = 8'h02;
		inst_mem[122] = 8'h00;
		inst_mem[123] = 8'hFE;
		inst_mem[124] = 8'h83;
		inst_mem[125] = 8'h26;
		inst_mem[126] = 8'h05;
		inst_mem[127] = 8'h10;
		inst_mem[128] = 8'h03;
		inst_mem[129] = 8'hA7;
		inst_mem[130] = 8'h0E;
		inst_mem[131] = 8'h10;
		inst_mem[132] = 8'h23;
		inst_mem[133] = 8'hA0;
		inst_mem[134] = 8'hDE;
		inst_mem[135] = 8'h10;
		inst_mem[136] = 8'h23;
		inst_mem[137] = 8'h20;
		inst_mem[138] = 8'hE5;
		inst_mem[139] = 8'h10;
		inst_mem[140] = 8'h93;
		inst_mem[141] = 8'h8E;
		inst_mem[142] = 8'h8E;
		inst_mem[143] = 8'h00;
		inst_mem[144] = 8'hE3;
		inst_mem[145] = 8'h06;
		inst_mem[146] = 8'h00;
		inst_mem[147] = 8'hFC;
	end
	
	always @(Inst_Address)
	begin
		Instruction={inst_mem[Inst_Address+3],inst_mem[Inst_Address+2],inst_mem[Inst_Address+1],inst_mem[Inst_Address]};
	end
endmodule

module MEM_WB(
    input clk,                      // Clock sig
    input RegWrite,                 // enabling register write
    input MemtoReg,                 //  ALU resullt for register write
    input [63:0] ReadData,          // Data read from memory or register file
    input [63:0] ALU_result,        // Result of the ALU operation
    input [4:0] destination_reg,    // Destination register for register write

    output reg RegWrite_out,        // enabling reg write
    output reg MemtoReg_out,        // ALU result for register write
    output reg [63:0] ReadData_out, // Output signal for memory or register file
    output reg [63:0] ALU_result_out, // Output signal for the ALU result
    output reg [4:0] destination_reg_out // Output signal for destination register for register write
    // dest reg will be the reg where the finakl result goes
);

    // Assign output values based on input signals
    always @(posedge clk) begin
        RegWrite_out = RegWrite;
        MemtoReg_out = MemtoReg;
        ReadData_out = ReadData;
        ALU_result_out = ALU_result;
        destination_reg_out = destination_reg;
    end

endmodule

module mux2x1
(
    input [63:0] a,b,
    input sel ,
    output [63:0] data_out
);

assign data_out = sel ? a : b; //select b or a based on the sel bit

endmodule 

module mux3x1(
    input [63:0] a, b, c,
    input [1:0] sel,
    output reg [63:0] data_out   
);

always @(*) begin
    if (sel == 2'b00) begin    // If sel is 00, select input A
        data_out = a;
    end
    else if (sel == 2'b01) begin    // If sel is 01, select input B
        data_out = b;
    end
    else if (sel == 2'b10) begin    // If sel is 10, select input C
        data_out = c;
    end
    else begin    // For all other cases, output X (undefined)
        data_out = 2'bX;
    end
end


endmodule

module Program_Counter 
(
    input clk, reset, PCWrite,
    input [63:0] PC_In,
    output reg [63:0] PC_Out
);

    reg reset_force; // Variable to force 0th value after reset

    initial
    begin
        PC_Out <= 64'd0; // Initialize PC_Out to 0
    end
    
    always @(negedge reset)
    begin
        reset_force <= 1; // Set reset_force to 1 on the falling edge of reset signal
    end
    
    always @(posedge clk or posedge reset)
    begin
        if (reset || reset_force)
        begin
            PC_Out <= 64'd0; // Reset PC_Out to 0 when reset or reset_force is active
            reset_force <= 0; // Reset the reset_force variable
        end
        else if (!PCWrite) // holding the last instruction if PCwrite is low
        begin
            PC_Out <= PC_Out; // Hold the current value of PC_Out if PCWrite is not enabled
        end
        else
        begin
            PC_Out <= PC_In; // Update PC_Out with the value from PC_In when PCWrite is enabled
        end
    end

endmodule

module registerFile
(
    input clk, reset, RegWrite,
    input [63:0] WriteData,
    input [4:0] RS1, RS2, RD,
    output reg [63:0] ReadData1, ReadData2,
    output [63:0] r1,
    output [63:0] r2,
    output [63:0] r3,
    output [63:0] r4,
    output [63:0] r5
);

reg [63:0] Registers [31:0];
integer i;

initial
begin
    for (i = 0; i < 32; i = i + 1)
            Registers[i] = 64'd0;
    Registers[12] = 64'd7;
    Registers[13] = 64'd8;
end


always @(negedge clk ) begin
    
    if (RegWrite) begin
        Registers[RD] = WriteData;
    end
end

always@(*) begin
    ReadData1 = reset ? 0 : Registers[RS1];
    ReadData2 = reset ? 0 : Registers[RS2];
end

  assign r1 = Registers[11];
  assign r2 = Registers[12];
  assign r3 = Registers[13];
  assign r4 = Registers[14];
  assign r5 = Registers[15];

endmodule

module RISC_V_Processor 
(
    input clk, reset,
   output wire [63:0] r1, r2, r3, r4, r5,
    output wire [63:0] ele1, ele2, ele3, ele4, ele5
);
// Input and output wires
wire [63:0] r1, r2, r3, r4, r5;
wire [63:0] PC_to_IM;
wire [31:0] IM_to_IFID;
wire [6:0] opcode_out;
wire [4:0] rd_out;
wire [2:0] funct3_out;
wire [6:0] funct7_out;
wire [4:0] rs1_out, rs2_out;
wire Branch_out, MemRead_out, MemtoReg_out, MemWrite_out, ALUSrc_out, RegWrite_out;
wire Is_Greater_out;
wire [1:0] ALUOp_out;
wire [63:0] mux_to_reg;
wire [63:0] mux_to_pc_in;
wire [3:0] ALU_C_Operation;
wire [63:0] ReadData1_out, ReadData2_out;
wire [63:0] imm_data_out;

// Wires used for calculations
wire [63:0] fixed_4 = 64'd4;
wire [63:0] PC_plus_4_to_mux;
wire [63:0] alu_mux_out;
wire [63:0] alu_result_out;
wire zero_out;
wire [63:0] imm_to_adder;
wire [63:0] imm_adder_to_mux;
wire [63:0] DM_Read_Data_out;
wire pc_mux_sel_wire;
wire PCWrite_out;

// Control signals for IDEX stage
wire IDEX_Branch_out, IDEX_MemRead_out, IDEX_MemtoReg_out,
     IDEX_MemWrite_out, IDEX_ALUSrc_out, IDEX_RegWrite_out;

// IDEX stage wires
wire [63:0] IDEX_PC_addr, IDEX_ReadData1_out, IDEX_ReadData2_out,
            IDEX_imm_data_out;
wire [3:0] IDEX_funct_in;
wire [4:0] IDEX_rd_out, IDEX_rs1_out, IDEX_rs2_out;
wire [1:0] IDEX_ALUOp_out;

// Calculate the immediate value for branching
assign imm_to_adder = IDEX_imm_data_out << 1;

// Control signals and wires for EXMEM stage
wire EXMEM_Branch_out, EXMEM_MemRead_out, EXMEM_MemtoReg_out,
     EXMEM_MemWrite_out, EXMEM_RegWrite_out; 
wire EXMEM_zero_out, EXMEM_Is_Greater_out;
wire [63:0] EXMEM_PC_plus_imm, EXMEM_alu_result_out,
            EXMEM_ReadData2_out;
wire [3:0] EXMEM_funct_in;
wire [4:0] EXMEM_rd_out;
wire Flush_out;

// Control signals and wires for MEMWB stage
wire MEMWB_MemtoReg_out, MEMWB_RegWrite_out;
wire [63:0] MEMWB_DM_Read_Data_out, MEMWB_alu_result_out;
wire [4:0] MEMWB_rd_out;


mux2x1 pcsrcmux
(
    .a(EXMEM_PC_plus_imm),   //value when sel is 1
    .b(PC_plus_4_to_mux),
    .sel(pc_mux_sel_wire), 
    .data_out(mux_to_pc_in)
);

Program_Counter PC (
    .clk(clk),
    .reset(reset),
    .PCWrite(PCWrite_out),
    .PC_In(mux_to_pc_in),
    .PC_Out(PC_to_IM)
);

Adder pcadder
(
    .a(PC_to_IM),
    .b(fixed_4),
    .out(PC_plus_4_to_mux)
);

Instruction_Memory insmem
(
    .Inst_Address(PC_to_IM),
    .Instruction(IM_to_IFID)
);

wire [63:0] IFID_PC_addr;
wire [31:0] IFID_IM_to_parse;
wire IFID_Write_out;


IF_ID IF_ID
(
    .clk(clk),
    .Flush(Flush_out),
    .IFID_Write(IFID_Write_out),
    .PC_addr(PC_to_IM),
    .Instruc(IM_to_IFID),
    .PC_store(IFID_PC_addr),
    .Instr_store(IFID_IM_to_parse)
);


wire control_mux_sel;

Hazard_Detection hu
(
    .current_rd(IDEX_rd_out),
    .previous_rs1(rs1_out),
    .previous_rs2(rs2_out),
    .current_MemRead(IDEX_MemRead_out),
    .mux_out(control_mux_sel),
    .enable_Write(IFID_Write_out),
    .enable_PCWrite(PCWrite_out)
);


Instruction_Parser ip
(
    .instruction(IFID_IM_to_parse),
    .opcode(opcode_out),
    .rd(rd_out),
    .funct3(funct3_out),
    .rs1(rs1_out),
    .rs2(rs2_out),
    .funct7(funct7_out)
);

wire [3:0] funct_in;
assign funct_in = {IFID_IM_to_parse[30],IFID_IM_to_parse[14:12]};
//assign [63:0] nop_to_mux = 64'd0;

Control_Unit Ctrlunit
(
    .Opcode(opcode_out),
    .Branch(Branch_out), 
    .MemRead(MemRead_out), 
    .MemtoReg(MemtoReg_out),
    .MemWrite(MemWrite_out), 
    .ALUSrc(ALUSrc_out),
    .RegWrite(RegWrite_out),
    .ALUOp(ALUOp_out)
);

registerFile regfile
(
    .clk(clk),
    .reset(reset),
    .RegWrite(MEMWB_RegWrite_out), //change
    .WriteData(mux_to_reg),//??
    .RS1(rs1_out),
    .RS2(rs2_out),
    .RD(MEMWB_rd_out),    //??
    .ReadData1(ReadData1_out),
    .ReadData2(ReadData2_out),
    .r1(r1),
    .r2(r2),
    .r3(r3),
    .r4(r4),
    .r5(r5)
);


data_extractor Imm_gen
(
    .instruction(IFID_IM_to_parse),
    .imm_data(imm_data_out)
);

assign MemtoReg_IDEXin = control_mux_sel ? MemtoReg_out : 0;
assign RegWrite_IDEXin = control_mux_sel ? RegWrite_out : 0;
assign Branch_IDEXin = control_mux_sel ? Branch_out : 0;
assign MemWrite_IDEXin = control_mux_sel ? MemWrite_out : 0;
assign MemRead_IDEXin = control_mux_sel ? MemRead_out : 0;
assign ALUSrc_IDEXin = control_mux_sel ? ALUSrc_out : 0;
wire [1:0] ALUop_IDEXin;
assign ALUop_IDEXin = control_mux_sel ? ALUOp_out : 2'b00;


ID_EX ID_EX_Stage
(
    .clk              (clk),
    .Flush              (Flush_out),
    .program_counter_addr (IFID_PC_addr),
    .read_data1          (ReadData1_out),
    .read_data2          (ReadData2_out),
    .immediate_value     (imm_data_out),
    .function_code       (funct_in),
    .destination_reg     (rd_out),
    .source_reg1         (rs1_out),
    .source_reg2         (rs2_out),
    .MemtoReg            (RegWrite_IDEXin),
    .RegWrite             (MemtoReg_IDEXin),
    .Branch                (Branch_IDEXin),
    .MemWrite            (MemWrite_IDEXin),
    .MemRead             (MemRead_IDEXin),
    .ALUSrc              (ALUSrc_IDEXin),
    .ALU_op              (ALUop_IDEXin),

    .program_counter_addr_out       (IDEX_PC_addr),
    .read_data1_out             (IDEX_ReadData1_out),
    .read_data2_out             (IDEX_ReadData2_out),
    .immediate_value_out     (IDEX_imm_data_out),
    .function_code_out       (IDEX_funct_in),
    .destination_reg_out        (IDEX_rd_out),
    .source_reg1_out           (IDEX_rs1_out),
    .source_reg2_out            (IDEX_rs2_out),
    .MemtoReg_out               (IDEX_RegWrite_out),
    .RegWrite_out               (IDEX_MemtoReg_out),
    .Branch_out                 (IDEX_Branch_out),
    .MemWrite_out               (IDEX_MemWrite_out),
    .MemRead_out               (IDEX_MemRead_out),
    .ALUSrc_out                 (IDEX_ALUSrc_out),
    .ALU_op_out                 (IDEX_ALUOp_out)

);

ALU_Control ALU_Control1
(
    .ALUOp(IDEX_ALUOp_out),
    .Funct(IDEX_funct_in),
    .Operation(ALU_C_Operation)
);

wire [1:0] fwd_A_out, fwd_B_out;

wire [63:0] triplemux_to_a, triplemux_to_b;

mux2x1 ALU_mux
(
    .a(IDEX_imm_data_out), //value when sel is 1
    .b(triplemux_to_b),
    .sel(IDEX_ALUSrc_out),
    .data_out(alu_mux_out)
);



mux3x1 muxFwd_a
(
    .a(IDEX_ReadData1_out), //00
    .b(mux_to_reg), //01
    .c(EXMEM_alu_result_out),   //10
    .sel(fwd_A_out),
    .data_out(triplemux_to_a)  
);

mux3x1 muxFwd_b
(
    .a(IDEX_ReadData2_out), //00
    .b(mux_to_reg), //01
    .c(EXMEM_alu_result_out),   //10
    .sel(fwd_B_out),
    .data_out(triplemux_to_b)  
);

alu_64 ALU64
(
    .a(triplemux_to_a),
    .b(alu_mux_out), 
    .ALUOp(ALU_C_Operation),
    .Result(alu_result_out),
    .Zero(zero_out),
    .is_greater(Is_Greater_out)
);



Forwarding_Unit Fwd_unit
(
    .EXMEM_rd(EXMEM_rd_out),
    .MEMWB_rd(MEMWB_rd_out),
    .IDEX_rs1(IDEX_rs1_out),
    .IDEX_rs2(IDEX_rs2_out),
    .EXMEM_RegWrite(EXMEM_RegWrite_out),
    .EXMEM_MemtoReg(EXMEM_MemtoReg_out),
    .MEMWB_RegWrite(MEMWB_RegWrite_out),
    .fwd_A(fwd_A_out),
    .fwd_B(fwd_B_out)
);


wire [63:0] pcplusimm_to_EXMEM;

Adder PC_plus_imm
(
    .a(IDEX_PC_addr),
    .b(imm_to_adder),
    .out(pcplusimm_to_EXMEM) 
);

EX_MEM EX_MEM
(
    .clk(clk),
    .Flush(Flush_out),
    .RegWrite(IDEX_RegWrite_out),
    .MemtoReg(IDEX_MemtoReg_out),
    .Branch(IDEX_Branch_out),
    .Zero(zero_out),
    .is_greater(Is_Greater_out),
    .MemWrite(IDEX_MemWrite_out),
    .MemRead(IDEX_MemRead_out),
    .immvalue_added_pc(pcplusimm_to_EXMEM),
    .ALU_result(alu_result_out),
    .WriteData(triplemux_to_b),
    .function_code(IDEX_funct_in),
    .destination_reg(IDEX_rd_out),

    .RegWrite_out(EXMEM_RegWrite_out),
    .MemtoReg_out(EXMEM_MemtoReg_out),
    .Branch_out(EXMEM_Branch_out),
    .Zero_out(EXMEM_zero_out),
    .is_greater_out(EXMEM_Is_Greater_out),
    .MemWrite_out(EXMEM_MemWrite_out),
    .MemRead_out(EXMEM_MemRead_out),
    .immvalue_added_pc_out(EXMEM_PC_plus_imm),
    .ALU_result_out(EXMEM_alu_result_out),
    .WriteData_out(EXMEM_ReadData2_out),
    .function_code_out(EXMEM_funct_in),
    .destination_reg_out(EXMEM_rd_out)
);

Branch_Control Branch_Control
(
    .Branch(EXMEM_Branch_out),
    .Flush(Flush_out),
    .Zero(EXMEM_zero_out),
    .Is_Greater_Than(EXMEM_Is_Greater_out),
    .funct(EXMEM_funct_in),
    .switch(pc_mux_sel_wire)
);


Data_Memory dm
(
	EXMEM_alu_result_out,
	EXMEM_ReadData2_out,
	clk,EXMEM_MemWrite_out,EXMEM_MemRead_out,
	DM_Read_Data_out
, 
ele1,
ele2,
ele3,
ele4,
ele5
);



MEM_WB MEM_WBStage // stage 4-5
(
    .clk(clk),
    .RegWrite(EXMEM_RegWrite_out),
    .MemtoReg(EXMEM_MemtoReg_out),
    .ReadData(DM_Read_Data_out),
    .ALU_result(EXMEM_alu_result_out),
    .destination_reg(EXMEM_rd_out),

    .RegWrite_out(MEMWB_RegWrite_out),
    .MemtoReg_out(MEMWB_MemtoReg_out),
    .ReadData_out(MEMWB_DM_Read_Data_out),
    .ALU_result_out(MEMWB_alu_result_out),
    .destination_reg_out(MEMWB_rd_out)
);

mux2x1 mux2
(
    .a(MEMWB_DM_Read_Data_out), 
    .b(MEMWB_alu_result_out),
    .sel(MEMWB_MemtoReg_out),
    .data_out(mux_to_reg)
);

endmodule 
