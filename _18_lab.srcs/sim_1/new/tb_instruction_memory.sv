`timescale 1ns / 1ps

module tb_instruction_memory;
    logic rst;
    logic [31:0] addr; 
    logic [31:0] instr; 
    
    // let's say on reset, the instruction memory 
    // returns a valid but uselesss instruction,
    // like all zero thing 
    
    // instantiate the design 
    instruction_memory dut (
        .rst(rst), 
        .addr(addr), 
        .instr(instr)
    );
    
    initial begin 
        rst = 0;  // activate rst 
        #20 rst = 1; // deact
        
        #0      addr = 32'd0;  // first address 
        #10    addr = 32'd4; 
        #10    addr = 32'd8;
        #10 
        
        $finish;
    end
    
    
    
    
endmodule
