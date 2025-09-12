`timescale 1ns / 1ps

// the register file would be 
// combinationally read from 
// and sequentially written into.

module register_file(
    input logic clk,rst,
    input logic RegWrite,
    
    input logic [4:0] addr_rs1, 
    input logic [4:0] addr_rs2, 
    input logic [4:0] addr_rd , 
    
    input logic [31:0] data,
    
    output logic [31:0] rs1,
    output logic [31:0] rs2
    );
    
    // let's think it through
    logic [31:0] reg_file [0:31];   // RISC-V RV32I variant features 32 registers 
   
    initial begin
            for(int i=0; i<32; i++) 
                reg_file[i]=0;
    end
    
    assign rs1 = reg_file[addr_rs1]; 
    assign rs2 = reg_file[addr_rs2]; 

    // x0 is a black hole register, shouldn't be addressed
    // addr_rd can't be zero during data writing
    
    // now about writing, it's a clocked operation so: 
  
    
    assign reg_file[5'd0] = 0;
    
    always_ff @ (negedge clk) begin 
        
        if (RegWrite) begin  
            reg_file[addr_rd] <= data;
        end
    end
    
endmodule















