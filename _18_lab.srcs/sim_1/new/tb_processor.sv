`timescale 1ns / 1ps


module tb_processor;

    logic clk, rst; 

    processor RISC_V (
        .clk(clk),
        .rst(rst)
    );
    
    initial begin 
        clk = 1; 
        rst = 0;
          
        #10;
        rst = 1; 

        forever begin #5 clk = ~clk; end
        
        #60;
        $finish;
    end
endmodule
