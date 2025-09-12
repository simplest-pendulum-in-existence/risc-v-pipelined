`timescale 1ns/1ps


module alu(
    input logic [31:0] rs1, 
    input logic [31:0] rs2,
    input logic [3:0]  ALUControl,

    output logic [31:0] data,
    output logic Zero  // BEQ and BNE support
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

    logic [31:0] out;

    always_comb begin 
    case (ALUControl) 
        _AND:    out = rs1 & rs2;
        _OR:     out = rs1 | rs2;
        _ADD:    out = rs1 + rs2;
        _SRA:    out = $signed(rs1) >>> rs2[4:0]; // arithmetic right shift (signed)
        _SLL:    out = rs1 << rs2[4:0];           // logical left shift
        _SLT:    out = ($signed(rs1) < $signed(rs2)) ? 32'd1 : 32'd0;
        _SUB:
        begin 
            out = rs1 - rs2;
            
            if (out == 32'b0) 
                Zero = 1'b1;
            else 
                Zero = 1'b0;
                
        end
        _SLTU:   out = (rs1 < rs2) ? 32'd1 : 32'd0; // unsigned comparison
        _SRL:    out = rs1 >> rs2[4:0];            // logical right shift
        _XOR:    out = rs1 ^ rs2;
        default: out = 32'hFEEDDEAD; // Or 32'd0 or 'x depending on your preference
    endcase
    
    end

    assign data = out;

endmodule