`timescale 1ns / 1ps

module FWD_LOGIC(
    input logic [4:0] E_addr_rs1, 
    input logic [4:0] E_addr_rs2, 
    
    input logic M_RegWrite, 
    input logic W_RegWrite, 
    input logic [ 4:0 ] M_addr_rd, 
    input logic [ 4:0 ] W_addr_rd,
    
    output logic [1:0] ForwardA,
    output logic [1:0] ForwardB
    );
    // forwarding x0 is a redundancy rather than a threat!  
    
    // x0 isn't to be forwarded, but why ?
    always_comb
    begin 
    
        if (((E_addr_rs1 == M_addr_rd) & M_RegWrite) & (E_addr_rs1 != 5'b0))
            ForwardA = 2'b00;   // m stage
        else 
        if (((E_addr_rs1 == W_addr_rd) & W_RegWrite) & (E_addr_rs1 != 5'b0))
            ForwardA = 2'b01;  // w stage
        else 
            ForwardA = 2'b10;  // original source register
        
        // the 2'b11 combination is invalid in this setting (should prompt an exception)
    end
    
    //for rs2 
    always_comb
    begin 
    
        if (((E_addr_rs2 == M_addr_rd) & M_RegWrite) & (E_addr_rs2 != 5'b0))
            ForwardB = 2'b00;   // m stage
        else 
        if (((E_addr_rs2 == W_addr_rd) & W_RegWrite) & (E_addr_rs2 != 5'b0))
            ForwardB = 2'b01;  // w stage
        else 
            ForwardB = 2'b10;  // original source register
        
        // the 2'b11 combination is invalid in this setting (should prompt an exception)
    end
    
    
    
endmodule
