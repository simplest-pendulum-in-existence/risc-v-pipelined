`timescale 1ns / 1ps


module tb_register_file; 
    // inputs
    logic clk; 
    logic RegWrite; 
    
    logic [4:0] addr_rs1, addr_rs2, addr_rd; 
    logic [31:0] data; 
    
    // outputs
    logic [31:0] rs1, rs2; 
    
    // instantiate 
    register_file    RF (
        .clk(clk),
        .RegWrite(RegWrite), 
        .addr_rs1(addr_rs1),
        .addr_rs2(addr_rs2),
        .addr_rd (addr_rd), 
        .data(data), 
        .rs1(rs1), 
        .rs2(rs2)
    );
    
  
    initial begin 
        clk = 0;
        RegWrite = 0; // no writing 
        
        addr_rs1 = 0; 
        addr_rs2 = 0;
        addr_rd  = 0; // won't be written
        
        data = 32;
        
        
        // test file writing
        #5 RegWrite = 1; 
             addr_rd   = 5'd2;
        #2 data = 10; 
             
        #3 RegWrite = 0; 
        // now read this data on rs1 and rs2 
        
        #3 RegWrite = 1; 
        
        addr_rs1 = 2; 
        addr_rs2 = 2; 
        
        #5 RegWrite = 0;
        
      
        
        #10 $finish;
    end    
    
    always begin 
        forever #5 clk = ~clk; 
    end
    
endmodule






































