`timescale 1ns / 1ps

module ID_EX_Stage(
    input logic clk, 
    input logic rst,
    
    input logic clr,
    
    // INPUTS
    // control signals 
    input logic D_MemWrite, 
    input logic D_MemRead,
    input logic D_MemToReg,
    input logic D_RegWrite,
    input logic [3:0] D_ALUControl,  // coming from ALU_CONTROL Unit
    
    input logic D_Jump, 
    input logic D_JumpSrc, 
    input logic D_Branch, 
    
    input logic D_ALUSrc,   // select source of rs2
    input logic [1:0] D_rs1_sel,   // select source of rs1
    
    // data signals 
    input logic [31:0] D_rs1, 
    input logic [31:0] D_rs2,
    input logic [ 4:0 ] D_addr_rs1, 
    input logic [ 4:0 ] D_addr_rs2,
    input logic [ 4:0 ] D_addr_rd,   // the write register' addr for the WB stage 
    
    input logic [31:0] D_pc,  // we gotta retain this pc man!
    input logic [31:0] D_pc_plus_4,
    input logic [31:0] D_pc_next, // and + 4 
    input logic [ 2:0 ] D_funct3,
    input logic [31:0] D_immExt, // extended value that could be used in EX (ALU) stage
    
    // OUTPUTS
    // control signals 
    output logic E_MemWrite, 
    output logic E_MemRead,
    output logic E_MemToReg,
    output logic E_RegWrite,
    
    output logic [3:0] E_ALUControl, 
    
    output logic E_Jump, 
    output logic E_JumpSrc, 
    output logic E_Branch, 
    
    output logic E_ALUSrc,           // select source of rs2
    output logic [1:0] E_rs1_sel,   // select source of rs1

    // output signals 
    output logic [31:0] E_rs1, 
    output logic [31:0] E_rs2,
    output logic [ 4:0 ] E_addr_rs1, 
    output logic [ 4:0 ] E_addr_rs2,
    output logic [ 4:0 ] E_addr_rd,   // the write register' addr for the WB stage 
    
    output logic [31:0] E_pc,           // we gotta retain this pc man!
    output logic [31:0] E_pc_plus_4,
    output logic [31:0] E_pc_next,  // and + 4 
    output logic [ 2:0 ] E_funct3,
    output logic [31:0] E_immExt   // extended value that could be used in EX (ALU) stage
    
    );
    
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            // control
            E_MemWrite   <= 1'b0;
            E_MemRead    <= 1'b0;
            E_MemToReg   <= 1'b0;
            E_ALUControl <= 4'b0;
            E_Jump       <= 1'b0;
            E_JumpSrc    <= 1'b0;
            E_Branch     <= 1'b0;
            E_ALUSrc     <= 1'b0;
            E_rs1_sel    <= 2'b0;
            E_RegWrite <= 1'b0;
            
            // data
            E_rs1        <= 32'b0;
            E_rs2        <= 32'b0;
            E_addr_rs1 <= 5'b0;
            E_addr_rs2 <= 5'b0;
            E_addr_rd    <= 5'b0;
            E_pc         <= 32'b0;
            E_pc_plus_4 <= 32'b0;
            E_pc_next    <= 32'b0;
            E_funct3 <= 3'b0;
            E_immExt     <= 32'b0;
        
        end
        else if (clr) begin 
            // control
            E_MemWrite   <= 1'b0;
            E_MemRead    <= 1'b0;
            E_MemToReg   <= 1'b0;
            E_ALUControl <= 4'b0;
            E_Jump       <= 1'b0;
            E_JumpSrc    <= 1'b0;
            E_Branch     <= 1'b0;
            E_ALUSrc     <= 1'b0;
            E_rs1_sel    <= 2'b0;
            E_RegWrite <= 1'b0;
            
            // data
            E_rs1        <= 32'b0;
            E_rs2        <= 32'b0;
            E_addr_rs1 <= 5'b0;
            E_addr_rs2 <= 5'b0;
            E_addr_rd    <= 5'b0;
            E_pc         <= 32'b0;
            E_pc_plus_4 <= 32'b0;
            E_pc_next    <= 32'b0;
            E_funct3 <= 3'b0;
            E_immExt     <= 32'b0;
        
        end else begin
            // control
            E_MemWrite   <= D_MemWrite;
            E_MemRead    <= D_MemRead;
            E_MemToReg   <= D_MemToReg;
            E_ALUControl <= D_ALUControl;
            E_Jump       <= D_Jump;
            E_JumpSrc    <= D_JumpSrc;
            E_Branch     <= D_Branch;
            E_ALUSrc     <= D_ALUSrc;
            E_rs1_sel    <= D_rs1_sel;
            E_RegWrite <= D_RegWrite;
            
            // data
            E_rs1        <= D_rs1;
            E_rs2        <= D_rs2;
            E_addr_rs1 <= D_addr_rs1;
            E_addr_rs2 <= D_addr_rs2;
            E_addr_rd    <= D_addr_rd;
            E_pc   <= D_pc;
            E_pc_plus_4 <= D_pc_plus_4;
            E_pc_next    <= D_pc_next;
            E_funct3  <= D_funct3;
            E_immExt     <= D_immExt;
        end
    end
endmodule

// note: before i forget, i guess that cycle WILL take place 
// therefore i am not erasing the prefix F_ from the signal names
