`timescale 1ns / 1ps

module data_memory (
    input logic clk, 
    input logic MemRd,  // signal to avoid unintentional reading 
    input logic MemWr,  // same but for writing
    input logic [31:0] addr, 
    input logic [31:0] dataW,  
    
    input logic   [2:0]   funct3, // to select which load is to be done
    
    output logic [31:0] dataR 
);
    
    // read some damned data from a file 
    logic [7:0] data_mem [0: 1023];   // byte addressable data memory 
    
    initial begin 
        $readmemh("data_mem.mem", data_mem);
    end
    
    // reads finna be combinational
    // so how do we decide whether it's a store or load command? 
    // well it's easy. we observe that only one of the signal (MemWrite/MemRead) 
    // can be active at a time, so we can distinguish based on this.
    // further, we can reuse the funct3 bits to distinguish among 
    
    enum logic [2:0] {
        LB      = 3'b000,
        LH      = 3'b001, 
        LW      = 3'b010, 
        LBU    = 3'b100, 
        LHU    = 3'b101
    } LOAD; 
    
    enum logic [2:0] {
        SB      = 3'b000,
        SH      = 3'b001,
        SW      = 3'b010
     } STORE;
    
    logic [31:0] out; 
    
    // combination reads/loads    
    always_comb begin 
        if (MemRd) begin // so we doing reads now ?
            
            case (funct3) 
                LB: begin    // byte reads don't have any restrictions 
                    // sign extend 
                    out = { { 24{data_mem[addr][7]}}, data_mem[addr] }; // ts worked
                end        
                
                LH: begin 
                    if (addr % 2 == 0) begin  
                        out = { {16 { data_mem[addr+1][7] }} , data_mem[addr+1], data_mem[addr]};
                    end            
                end
                
                LW: begin 
                    if (addr % 4 == 0) begin 
                        out = { data_mem[addr + 3], data_mem[addr +2], data_mem[addr + 1], data_mem[addr]};
                    end
                end 
                
                LBU: begin 
                    out = { { 24{ 1'b0 }}, data_mem[addr]}; // no sign extension, but zero extension
                end
                
                LHU: begin 
                    if (addr % 2 == 0) begin  
                        out = { {16 { 1'b0 }}, data_mem[addr+1], data_mem[addr]};
                    end  
                end
                
            
                // here's the design decision 
                // if the memory address requested isn't word or half word
                // aligned, the result would be <undefined>. src: Harris book
                
                default: 
                    out = 32'hffff_ffff;   // all negative stuff!
                    
            endcase
        end
    end
   
    assign dataR = out;

    always_ff @ (posedge clk) begin 
         if (MemWr) begin 
            case (funct3) 
            
                SB: begin 
                    data_mem[addr] <= dataW[7:0]; 
                end
                
                SH: begin 
                    if (addr %2 == 0) begin 
                        data_mem[addr] <= dataW[7:0]; 
                        data_mem[addr+1] <= dataW[15:8];
                    end
                end
                
                SW: begin 
                    if (addr %4 == 0) begin 
                        data_mem[addr] <= dataW[7:0]; 
                        data_mem[addr+1] <= dataW[15:8];
                        data_mem[addr+2] <= dataW[23:16];  
                        data_mem[addr+3] <= dataW[31:24]; 
                    end
                end
              
                default: data_mem[addr] <= 32'hffff_ffff;  
            endcase 
        end
        
    end
endmodule










// ....