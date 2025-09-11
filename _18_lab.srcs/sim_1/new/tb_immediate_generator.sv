`timescale 1ns / 1ps

module tb_immediate_generator; 

    logic [31:0] instr;
    logic [31:0] immExt; 
   
   immediate_generator ImmGen (
        .instr(instr),
        .immExt(immExt)
   ); 
   
    
   // let's test this 
   // the immediate extender expect the instruction without OpCode 7 bits
   // signed
   initial begin 
       // reset 
       instr = 32'b110011001111_0011001111001_0100011;
       
        // unsigned 
       #10 
       instr = 32'b010011001111_0011001111001_0010011;
    
       #10 $finish;

   end
endmodule
