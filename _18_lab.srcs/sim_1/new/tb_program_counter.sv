`timescale 1ns / 1ps

module tb_program_counter; 

    logic clk; 
    logic rst; 
    logic [31:0] pc_next;
    
    logic [31:0] pc; 
   
    // instantiate the counter 
    program_counter dut (
        .clk(clk),
        .rst(rst), 
        .pc_next(pc_next),
        .pc(pc));
        
       
    // clock generation 
    initial begin
        rst = 0; // activate reset 
        clk = 0; 
        
        #10 rst = 1; // deactivate rst 
        
        
        pc_next = 4;
        #10 pc_next = 8; 
        #10 pc_next = 12; 
        #10 pc_next = 16;
        #10;
        $finish;
    end
    
    always begin 
        forever begin 
            #5 clk = ~clk;
        end
    end
   
endmodule






















