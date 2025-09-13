`timescale 1ns/1ps

module IF_ID_Stage (
    input logic clk, 
    input logic rst,
    
    input logic en, 
    input logic clr,
    
    input logic [31:0] F_pc, 
    input logic [31:0] F_pc_plus_4,
    input logic [31:0] F_pc_next,
    input logic [31:0] F_instr, 
    
    output logic [31:0] D_pc,
    output logic [31:0] D_pc_plus_4,
    output logic [31:0] D_pc_next,
    output logic [31:0] D_instr
);
    
    // so just forward these signal upon the next clock edge ?
    // so an underscore in my design would specify output 
    // of a pipeline register
    
    always_ff @ (posedge clk or negedge rst)
    begin 
        if (!rst) begin 
        D_pc      <= 32'b0; 
        D_pc_plus_4 <= 32'b0;
        D_pc_next <= 32'b0;
        D_instr   <= 32'b0; 
    end 
    else if (clr) begin
        D_pc      <= 32'b0; 
        D_pc_plus_4 <= 32'b0;
        D_pc_next <= 32'b0;
        D_instr   <= 32'b0; 
    end
    else if (!en) begin  // active low 
        D_pc      <= F_pc; 
        D_pc_next <= F_pc_next; 
        D_pc_plus_4 <= F_pc_plus_4;
        D_instr   <= F_instr; 
    end
    else begin // simply not assigning would have it hold the prev values anyway in SV
        D_pc      <= D_pc;       // explicitly hold   
        D_pc_plus_4 <= D_pc_plus_4;
        D_pc_next <= D_pc_next; 
        D_instr   <= D_instr;     
    end
    end 
    
endmodule 
    