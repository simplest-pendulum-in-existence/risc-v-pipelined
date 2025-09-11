`timescale 1ns / 1ps

module main_control(
    input logic [6:0] OpCode, 
    
    output logic RegWrite,
    output logic ALUSrc, 
    output logic [1:0] ALUOp,
    
    // gonna be used in case of loads and stores
    output logic MemWrite, 
    output logic MemRead,
    output logic MemToReg,
    
    // jump case signals 
    output logic Jump,
    output logic JumpSrc,  // if about to make a jump, which source to employ? 0 for PC, 1 for ALUResult
    output logic Branch,
    output logic [1:0] rs1_sel
    );
    
    // operation types based on ALUOp 
    enum logic [1:0] {
        LOAD_STORE = 2'b00,
        BRANCH =         2'b01,
        TYPE_RI  =         2'b10,
        TYPE_UJ =         2'b11 // TBD
    } OperationType;
    
//    // instruction types
//    localparam int TYPE_R = 7'b0110011;             // d (51)
        
//    localparam int TYPE_I  = 7'b0010011;            // d (19)
//    localparam int TYPE_I_LOAD  = 7'b0000011;  // d (3)
//    localparam unsigned TYPE_I_JALR = 7'b1100111;
    
//    localparam int TYPE_S = 7'b0100011; // d (35) 
    
//    localparam int TYPE_J = 7'b1101111;

    enum logic [6:0] {
        TYPE_R = 7'b0110011,
        TYPE_I  = 7'b0010011,
        TYPE_I_LOAD  = 7'b0000011,
        TYPE_I_JALR = 7'b1100111,
        TYPE_S = 7'b0100011,
        TYPE_J = 7'b1101111,
        TYPE_B = 7'b1100011,
        TYPE_U_LUI = 7'd55,
        TYPE_U_AUIPC = 7'd23
    } opcode;
     
     
    always_comb begin 
        case (OpCode)
            // U type 
            TYPE_U_AUIPC: 
            begin 
                // generate the respective signals 
                RegWrite = 1;               // we shall store the computed result in rd
                ALUSrc    = 1;              // 2nd source would be a register
                ALUOp     = TYPE_UJ;    // just need adds anyway 
                
                // no memory reading or writing in this case so: 
                MemWrite = 0; 
                MemRead = 0; 
                MemToReg = 0;
                
                Jump = 0;
                JumpSrc = 0;  //x
                Branch = 0;
                
                rs1_sel = 2'b01;  // PC + rs2_src
                
            end
            // end U Type
            TYPE_U_LUI: 
            begin 
                // generate the respective signals 
                RegWrite = 1;               // we shall store the computed result in rd
                ALUSrc    = 1;              // 2nd source would be a register
                ALUOp    = TYPE_UJ;   // add only
                
                // no memory reading or writing in this case so: 
                MemWrite = 0; 
                MemRead = 0; 
                MemToReg = 0;
                
                Jump = 0;
                JumpSrc = 0;  //x
                Branch = 0;
                
                rs1_sel = 2'b00;  //  32'b0 + rs2_src
            end
            
            TYPE_R:  // same for type I and R
            begin 
                // generate the respective signals 
                RegWrite = 1;               // we shall store the computed result in rd
                ALUSrc    = 0;              // 2nd source would be a register
                ALUOp    = TYPE_RI;    // R-Type indicator  
                
                // no memory reading or writing in this case so: 
                MemWrite = 0; 
                MemRead = 0; 
                MemToReg = 0;
                
                Jump = 0;
                JumpSrc = 0;  //x
                Branch = 0;
                
                rs1_sel = 2'b10;

            end
            
            TYPE_I: 
            begin 
                 // generate the respective signals 
                RegWrite = 1;               // we shall store the computed result in rd
                ALUSrc    = 1;              // 2nd source would be an immediate value
                ALUOp    = TYPE_RI;    // R-Type indicator  
                
                // no memory reading or writing in this case so: 
                MemWrite = 0; 
                MemRead = 0; 
                MemToReg = 0;
                
                Jump = 0;
                JumpSrc = 0;  // x    don't care in this case
                Branch = 0;
                
                rs1_sel = 2'b10;

            end
            
            TYPE_I_JALR: 
            begin 
            
                RegWrite = 1;               // the PC+4 to be written to target register
                ALUSrc = 1;                 // imm needed
                ALUOp = TYPE_RI;       // only addition needed. could be LOAD_STORE too. funct3 is always 3'b000 here!
                
                MemWrite = 0;       
                MemRead = 0;
                MemToReg = 0; 
                
                Jump = 1; 
                JumpSrc = 1;          // source should be PC here
                Branch = 0;
                
                // rs1_sel = 0;
                rs1_sel = 2'b10;

            end

            TYPE_I_LOAD: 
            begin 
                RegWrite = 1; // yes storing value from data memory onto dest reg
                ALUSrc = 1;    // the immediate value for offsetting ofcourse
                ALUOp = LOAD_STORE; // 10
                
                MemWrite = 0; 
                MemRead = 1; // reading from data memory
                MemToReg = 1; // yeah
                
                Jump = 0;
                JumpSrc = 0;  // x
                Branch = 0;
                
                // rs1_sel = 0;
                rs1_sel = 2'b10;

            end
            
            TYPE_S: 
            begin 
                RegWrite = 0; 
                ALUSrc = 1;
                ALUOp  = LOAD_STORE;
                
                MemWrite = 1;
                MemRead = 0; 
                MemToReg = 0;
                
                Jump = 0;
                JumpSrc = 0;   // x
                Branch = 0;
                
                // rs1_sel = 0;
                rs1_sel = 2'b10;

            end
            
            TYPE_J: // JAL
            begin 
                // so i want to store the PC + 4 into the target register ? 
                // gotta employ the write back datapath 
                RegWrite = 1; 
                ALUSrc = 1; // for immediate value's selection 
                ALUOp = TYPE_UJ;
                
                MemWrite = 0;
                MemRead = 0; 
                MemToReg = 0; // no loading of no sort 
 
                Jump = 1;
                JumpSrc = 0;  // ALUResult in this case
                Branch = 0;
                
                // rs1_sel = 0;
                rs1_sel = 2'b10;

            end
             
            TYPE_B: begin 
                RegWrite = 0;   // don't store the  
                ALUSrc = 0;    // should not select immediate, sh*t
                ALUOp = BRANCH; 
                
                MemWrite = 0; 
                MemRead = 0; 
                MemToReg = 0; 
                
                Jump = 0; 
                JumpSrc = 0; // don't care in this case 
                Branch = 1; // yes, do take the branch
                                
                // rs1_sel = 0;
                rs1_sel = 2'b10;

            end
            
            default: begin 
                RegWrite =1'bz; 
                ALUSrc = 1'bz;
                ALUOp = 2'bzz; // invalid in this context
                
                MemWrite =1'bz; 
                MemRead = 1'bz; // reading from data memory
                MemToReg = 1'bz; // yeah
                
                Jump = 1'bz;
                JumpSrc = 1'bz; 
                Branch = 1'bz;
                
                 rs1_sel = 2'bz;
            end
        endcase
        
    end
    
endmodule
