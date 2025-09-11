`timescale 1ns / 1ps

module alu_control(
    input logic [2:0] funct3, 
    input logic [6:0] funct7, 
    input logic [1:0] ALUOp,
    
    input logic OpCode_bit6,
    
    output logic [3:0] ALUControl
    );

    typedef enum logic [3:0] {
        _AND  = 4'd0,
        _OR  = 4'd1, 
        _ADD  = 4'd2,  // 0010
        _SRA  = 4'd3,
        _SLL  = 4'd4, 
        _SLT  = 4'd5, 
        _SUB = 4'd6,  // 0110 
        _SLTU = 4'd7, 
        _SRL = 4'd8, 
        _XOR = 4'd9,
        _undefined = 4'b1111 // -1
    } Operation;
    
    // instruction types     
    localparam TYPE_LS = 2'b00; // load store
    localparam TYPE_B   = 2'b01;
    localparam TYPE_RI  = 2'b10; // recv from main control unit
    localparam TYPE_J   = 2'b11; 
    
    logic [3:0] out;
    
    always_comb 
    begin 
        // for R and I Type
        
        // so ALU control lines decoding is implementation dependent and 
        // is upto the microarchitecture designer
        
        // NOTE: the order of case statements for operation selection 
        // is sorted by ascending order of ALUControl starting from 0
        
        case (ALUOp)
             
            TYPE_J,
            TYPE_LS:  // only perform addition 
            begin        // regardless of funct3 
                out = _ADD;        
            end   
            
            // for branching 
            TYPE_B: begin 
                out = _SUB;
            end
            
            TYPE_RI: 
            begin // begin TypeRI
                case (funct3)  
                    3'b111: begin  
                        if (funct7[5] == 1'b0) out = _AND; 
                    end
                    
                    3'b110: begin 
                        if (funct7[5] == 1'b0) out = _OR; 
                    end      
                    
                    3'b000: begin 
                        if ( OpCode_bit6 )  // RType/IType classifier
                            if (funct7[5]) out = _SUB; 
                            else              out = _ADD; 
                        else 
                            out = _ADD;
                    end
                    
                    3'b101: begin 
                        if      (funct7[5]) out = _SRA;
                        else                   out = _SRL; 
                    end
                    
                    3'b001: begin 
                        if (funct7[5] == 1'b0) out = _SLL; 
                    end
                    
                    3'b010: begin 
                        if (funct7[5] == 1'b0) out = _SLT;
                    end
                   
                    3'b011: begin 
                        out = _SLTU;
                    end
                    
                    3'b100: begin 
                        if (funct7[5] == 1'b0) out = _XOR;
                    end
  
                    default: out = _undefined;
                endcase  

            end // end TypeRI
            
            default: out = _undefined;
        endcase 
    
    end
    
    assign ALUControl = out; 
        
endmodule

