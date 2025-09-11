`timescale 1ns/1ps

module MEM_WB_Stage (

    input logic clk, rst,
    
    // INPUTS
    // control 
    input logic M_RegWrite,
    input logic M_MemToReg, // the mux signal 
    
    // data
    input logic [31:0] M_dataR, 
    input logic [ 4:0 ] M_addr_rd,
    input logic [31:0] M_pc_next, // to cater the JUMP case 
    
    // OUTPUTs
    // control
    output logic W_RegWrite,
    output logic W_MemToReg,
    
    // data
    output logic [31:0] W_dataR, 
    output logic [ 4:0 ] W_addr_rd,
    output logic [31:0] W_pc_next
); 

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            W_RegWrite <= 1'b0;
            W_MemToReg <= 1'b0;
            W_dataR    <= 32'b0;
            W_addr_rd  <= 5'b0;
            W_pc_next  <= 32'b0;
        end else begin
            W_RegWrite <= M_RegWrite;
            W_MemToReg <= M_MemToReg;
            W_dataR    <= M_dataR;
            W_addr_rd  <= M_addr_rd;
            W_pc_next  <= M_pc_next;
        end
    end   

endmodule