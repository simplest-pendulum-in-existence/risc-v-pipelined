`timescale 1ns / 1ps

module program_counter(
    input logic clk, 
    input logic rst, 
    input logic stall, 
    
    input logic [31:0] pc_next, // either we receive an offset or a 4
    
    output logic [31:0] pc
    );
    
    always @ (posedge clk or negedge rst) begin 
        if (!rst) 
            pc <= 32'd0; 
        else if (stall) 
            pc <= pc;   
        else
            pc <= pc_next; // retain value 
    end
endmodule
