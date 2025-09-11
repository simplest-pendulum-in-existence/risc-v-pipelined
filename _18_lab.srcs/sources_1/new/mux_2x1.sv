`timescale 1ns / 1ps

module mux_2x1(
    input logic [31:0] a, b,
    input logic sel, 
    
    output [31:0] out
    );
    
    assign out = sel ?  b : a; 
    
endmodule
