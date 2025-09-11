`timescale 1ns / 1ps

// gotta be a simple RISC-V instruction 
// storage unit right ?
// should it be clock operated ? what do you think ?
// i don't think so!! 

module instruction_memory(
    input logic rst,
    input logic [31:0] addr, 
    output logic [31:0] instr
    );
    
    // for now, read this memory from a file 
    logic [31:0]  instr_mem [0:255];    // quarter kb memory for now let's say
    initial begin
        $readmemh("memory.mem", instr_mem);
    end
    
    // let's say the file has been read 
    // so we just index into mem via the address and 
    // fetch the instruction 
    
    always_comb begin 
        if (!rst) 
             instr = 32'd0; 
        else   // 9:2 gives 8 bits, enough to address 0.25KB memory
             instr = instr_mem[addr[9:2]]; // this makes sense  0000 -> 0100 -> 1000 -> 1100  (word alignment)
    end
    
endmodule
