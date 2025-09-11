`timescale 1ns / 1ps

// NOTE: for now I have made the mistake of forwarding the pc_plus_4 signal throughout the cycle, 

module EX_MEM_Stage (
    input clk, rst, 
    
    // INPUTS
    // control 
    input logic E_MemWrite,
    input logic E_MemRead,
    input logic E_RegWrite,
    
    input logic E_MemToReg,
    
    // data 
    input logic [31:0] E_ALUResult,
    input logic [31:0] E_rs2,  // to act as data to be written 
    input logic [ 2:0 ] E_funct3, 

    input logic [ 4:0 ] E_addr_rd, 
    input logic [31:0] E_pc_next, // pc + 4 basically.
    // NOTE: the pc won't proceed further from here, because 
    // the pc_target has already been fed back from this stage. 
    
    // OUTPUTS
    // control 
    output logic  M_MemWrite, 
    output  logic M_MemRead,
    output logic  M_RegWrite, 
    
    output logic  M_MemToReg, 
    
    // data 
    output logic [31:0] M_ALUResult,
    output logic [31:0] M_rs2, 
    output logic [ 2:0 ] M_funct3, 
    output logic [ 4:0 ] M_addr_rd,
    output logic [31:0] M_pc_next
    );
    
    always_ff @ (posedge clk or negedge rst)
    begin 
        if (!rst) begin 
            M_MemWrite <= 1'b0;
            M_MemRead <= 1'b0; 
            M_RegWrite <= 1'b0;
            M_MemToReg <= 1'b0; 
            M_ALUResult <= 32'b0; 
            M_rs2 <= 32'b0; 
            M_funct3 <= 3'b0;
            M_addr_rd <= 5'b0; 
            M_pc_next <= 32'b0;
        end 
        else begin
            M_MemWrite <= E_MemWrite;
            M_MemRead <= E_MemRead; 
            M_RegWrite <=   E_RegWrite;
            M_MemToReg <= E_MemToReg; 
            M_ALUResult <= E_ALUResult; 
            M_rs2 <=    E_rs2; 
            M_funct3 <= E_funct3;
            M_addr_rd <= E_addr_rd; 
            M_pc_next <= E_pc_next;
        end 
    end 
    
    
    
endmodule
