`timescale 1ns / 1ps

module hazard_unit(
   
    input logic E_MemToReg,
    
    input logic [ 4:0 ] D_addr_rs1,
    input logic [ 4:0 ] D_addr_rs2,
    input logic [ 4:0 ] E_addr_rd,
    
    input logic PCSrc,
    
    output logic lwStall,
    output logic StallF,
    output logic StallD,
    
    output logic FlushD,
    
    output logic FlushE

    );
    // guard against lw x0 ... .could be introduced but later 
    
    assign lwStall =  E_MemToReg & 
                               ((D_addr_rs1 == E_addr_rd) |   // D stage source operands
                                (D_addr_rs2 == E_addr_rd) );   
    
    assign StallF =   lwStall; 
    assign StallD =  lwStall;
    assign FlushD = PCSrc; 
    assign FlushE = lwStall | PCSrc;
    
endmodule
