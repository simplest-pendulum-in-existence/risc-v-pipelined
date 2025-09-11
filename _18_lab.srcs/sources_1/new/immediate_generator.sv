`timescale 1ns / 1ps

module immediate_generator (
    input logic [31:0] instr, 
    output logic [31:0] immExt
    );
    
    // the instr could be any type, the immExt would be 
    // calculated in all cases including for I type, but only
    // propagated if input is of I type.

    logic [6:0] opcode; 
    assign opcode = instr[6:0]; 
    
    typedef enum logic [6:0] { // src: RISC-V Summar manual provided
        
        I_TYPE = 7'd19,
        I_TYPE_LOAD = 7'd3,
        I_TYPE_JALR = 7'd103, 
        
        S_TYPE  = 7'd35, 
        
        B_TYPE =  7'd99,
        
        U_TYPE_LUI = 7'd55,
        U_TYPE_AUIPC = 7'd23, 
        
        J_TYPE = 7'd111 // just JAL instruction 
        
    } ImmediateInstrType;
    
    
    always_comb begin
        case (opcode) 
                I_TYPE,
                I_TYPE_LOAD,
                I_TYPE_JALR:  
                begin
                    immExt = { {20{instr[31]}}, instr[31:20] };
                end
                
                S_TYPE:
                begin 
                    immExt = { {20{instr[31]}} ,instr[31:25] , instr[11:7] };
                end
                
                B_TYPE: 
                begin                                     // 12       11           10 - 5            4 - 1              0
                    immExt = {  {19{instr[31]}}, instr[31], instr[7] , instr[30:25] , instr[11:8] , 1'b0};
                end       
                
                U_TYPE_LUI,
                U_TYPE_AUIPC: 
                begin
                    immExt = { instr[31:12], 12'b0 }; // upper add, zero extended
                end
                
                J_TYPE:
                begin                                    // 12      19-12            11           10 - 1            0 
                    immExt = { {11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; 
                end
                         
                default: immExt = 32'dz;
   
        endcase
        
    
    end
    
endmodule






















// end here the file
