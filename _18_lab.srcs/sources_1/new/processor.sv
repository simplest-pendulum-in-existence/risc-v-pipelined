`timescale 1ns / 1ps

    module processor(input logic clk, input logic rst); // acts as whole processor module 
        
        /* 
        // Pipelining 
        // where do I add the IF/ID register ? 
        // NOTE: an underscore in my design would specify output 
        // of a pipeline register
        */ 
        
        /* IF/ID start*/

        // 1. program counter 
        
        // Hazard Unit signals        
        logic lwStall, StallF, StallD, FlushE;
        // end signals 
        
        logic [31:0] pc, pc_next;  // this signal will be routed back onto via another signal
   
        program_counter  PC (
            .clk(clk), 
            .rst(rst), 
            .stall(StallF),
            .pc_next(pc_next),
            .pc(pc)
        );
      
        // 2. instruction memory (word addressed) 
        logic [31:0] instr;
        
        instruction_memory IMEM (
            .rst(rst),  // just outputs invalid (all zero) instruction 
            .addr(pc), // pc dictates the address 
            .instr(instr)  // the instruction
        );
        
        // pipeline register
        logic [31:0] D_pc, D_pc_next, D_instr;
        
        IF_ID_Stage STAGE_1 (
            .clk(clk), 
            .rst(rst),
            .en(StallD),
            .clr(1'b0), // don't clr for now
            .F_pc(pc),
            .F_pc_next(pc_next),
            .F_instr(instr),
            .D_pc(D_pc),
            .D_pc_next(D_pc_next),
            .D_instr(D_instr)
        );

        /* IF/ID end*/
        
        /* ID/EX start */
        
        // so when previous units in the pipeline are being occupied,
        // i would need to store the splitted instruction to account 
        // for previously intended source and destination registers 
        // along with the type of instruction that was supposed to be 
        // executed, via storing the opcode ?
        // Main Control Unit happens to be part of this stage as well.
        
        // 2.5 gotta split this fetched instruction
        logic [6:0] OpCode;  
        logic [4:0] addr_rs1, addr_rs2, addr_rd;
        logic [2:0] funct3; 
        logic [6:0] funct7;
        
        assign OpCode = D_instr[6:0]; 
        assign addr_rd = D_instr[11:7];      // proceeds
        assign funct3 =  D_instr[14:12]; 
        assign addr_rs1 = D_instr[19:15]; 
        assign addr_rs2 = D_instr[24:20]; 
        assign funct7 = D_instr[31:25];
        
        // Control unit for signal generation 
        logic RegWrite; 
        logic ALUSrc;               // proceeds
        logic [1:0] ALUOp;
        
        logic MemWrite, MemRead, MemToReg; // data memory related stuff  <--- proceed
        logic Jump, JumpSrc;  // proceed
        logic Branch;                // proceeds
        logic [1:0] rs1_sel;        // AUIPC + LUI + normal case  <--- proceeds
        
        main_control MCU (
                .OpCode(OpCode),
                .RegWrite(RegWrite), 
                .ALUSrc(ALUSrc),  // alu_src_1 sel signal
                .ALUOp(ALUOp),
                .MemWrite(MemWrite), 
                .MemRead(MemRead), 
                .MemToReg(MemToReg),
                .Jump(Jump),    
                .JumpSrc(JumpSrc),
                .Branch(Branch),
                .rs1_sel(rs1_sel)   // alu_src_2 sel signal
        );
        
        // 3. register file, by now we have the control signal
        // to proceed with the data path
        logic [31:0] result;  // either ALUResult or dataR 
        
        logic [31:0] ALUResult; 
        logic [31:0] rs1, rs2; 
        
        // should the result go to register file or PC + 4, depending on Jump ?
        logic W_Jump; // from the write back stage
        
        logic [31:0] pc_plus_4;
        logic [31:0] write_data_src; 

        assign pc_plus_4 = pc + 4; 
        
        mux_2x1 RESULT_OR_NEXT_INSTR_ADDR_MUX (
            .sel(W_Jump), 
            .a   (result),  // it's part of the write back loop
            .b   (pc_plus_4),  
            .out(write_data_src)  
        );
        
        // signals coming from advanced stages 
        logic W_RegWrite;
        logic [4:0] W_addr_rd;
        
        register_file RF (
            .clk(clk), .rst(rst),
            .RegWrite(W_RegWrite),
            .addr_rs1(addr_rs1), 
            .addr_rs2(addr_rs2),                 // in case of JAL and JALR (for learning), this output/reg is x (don't care), cause we reading imm20 (or 21)
            .addr_rd(W_addr_rd),             // that 'ra' register for example (coming from WB cycle)
            .data (write_data_src),              // goes in here, comes from either the ALU/data memory or PC+4
            .rs1(rs1),
            .rs2(rs2)
        );
        
        // 4. Immediate generation: extend immediate (with this, we would be prepared 
        // to prompt our ALU into computing some useful stuff 
        logic [31:0] immExt; 
 
        immediate_generator IMM_GEN (
            .instr(D_instr),   //receives whole instruction 
            .immExt(immExt)
        );

        // 5. the operands are ready for ALU, 
        // we need ALUControl signals to get our ALU to 
        // perform the desired operation 
        logic [3:0] ALUControl; 
        
        alu_control ALU_CTRL (
            .funct3(funct3), 
            .funct7(funct7), 
            .ALUOp(ALUOp), 
            .OpCode_bit6(OpCode[5]),         // to disable subtraction operation for I type instructions only.
            .ALUControl(ALUControl)
        );
        
        // pipeline register
        // ID/EX pipeline register signals
        // control
        logic        E_MemWrite;
        logic        E_MemRead;
        logic        E_MemToReg;
        logic        E_RegWrite;
        
        logic [3:0]  E_ALUControl;
        
        logic        E_Jump;
        logic        E_JumpSrc;
        logic        E_Branch;
        
        logic          E_ALUSrc;
        logic [1:0]  E_rs1_sel;
        
        // data
        logic [31:0] E_rs1;
        logic [31:0] E_rs2;
        logic [4:0]   E_addr_rs1;
        logic [4:0]   E_addr_rs2;
        logic [4:0]   E_addr_rd;
        
        logic [31:0] E_pc;
        logic [31:0] E_pc_plus_4; 
        logic [31:0] E_pc_next;
        logic [ 2:0 ] E_funct3;
        logic [31:0] E_immExt;

        ID_EX_Stage STAGE_2 (
            .clk(clk), 
            .rst(rst),
            .clr(FlushE),
            // control 
            .D_MemWrite(MemWrite),
            .D_MemRead(MemRead),
            .D_MemToReg(MemToReg),
            .D_RegWrite(RegWrite),
            .D_ALUControl(ALUControl),
            .D_Jump(Jump),
            .D_JumpSrc(JumpSrc), 
            .D_Branch(Branch), 
            .D_ALUSrc(ALUSrc),
            .D_rs1_sel(rs1_sel),
            //data 
            .D_rs1(rs1),
            .D_rs2(rs2),
            .D_addr_rs1(addr_rs1), 
            .D_addr_rs2(addr_rs2),
            .D_addr_rd(addr_rd),
            .D_pc(D_pc),            // retained from prev stage
            .D_pc_plus_4(pc_plus_4),
            .D_pc_next(D_pc_next),   // ---
            .D_funct3(funct3),
            .D_immExt(immExt), 
            
            // control outputs
            .E_MemWrite(E_MemWrite),
            .E_MemRead(E_MemRead),
            .E_MemToReg(E_MemToReg),
            .E_RegWrite(E_RegWrite),
            .E_ALUControl(E_ALUControl),
            .E_Jump(E_Jump),
            .E_JumpSrc(E_JumpSrc), 
            .E_Branch(E_Branch), 
            .E_ALUSrc(E_ALUSrc),
            .E_rs1_sel(E_rs1_sel),
        
            // data outputs
            .E_rs1(E_rs1),
            .E_rs2(E_rs2),
            .E_addr_rs1(E_addr_rs1), 
            .E_addr_rs2(E_addr_rs2),
            .E_addr_rd(E_addr_rd),
            .E_pc(E_pc),
            .E_pc_plus_4(E_pc_plus_4),
            .E_pc_next(E_pc_next),
            .E_funct3(E_funct3),
            .E_immExt(E_immExt)
        );
        
        /* ID/EX end*/
        
        /* EX/MEM start */
        
        // the control signals are here, next we create the ALU, finally!
        // 6. ALU
                
        // DATA HAZARDS MITIGATION  (RAW)
        // signal needed from ahead stage
        logic M_RegWrite; 
        logic [4:0] M_addr_rd;
        logic [31:0] M_ALUResult;

        
        logic [1:0]  ForwardA, ForwardB; 
        
        FWD_LOGIC FORWARDING (
            .E_addr_rs1(E_addr_rs1), 
            .E_addr_rs2(E_addr_rs2), 
            .M_RegWrite(M_RegWrite), 
            .W_RegWrite(W_RegWrite),
            .M_addr_rd(M_addr_rd),
            .W_addr_rd(W_addr_rd),
            .ForwardA(ForwardA),
            .ForwardB(ForwardB)
        ); 
        
        // hazar unit and forwarding go hand in hand so: 
        
        hazard_unit     HAZU (
            .E_MemToReg(E_MemToReg),
            .D_addr_rs1(addr_rs1),   // from prev stage
            .D_addr_rs2(addr_rs2),   // ......
            .E_addr_rd(E_addr_rd), 
            .lwStall(lwStall),
            .StallF(StallF),
            .StallD(StallD),
            .FlushE(FlushE)
        );
        
        typedef enum logic [1:0] {
            Fwd_MEM = 2'b00,
            Fwd_WB    = 2'b01,
            Fwd_SRC  = 2'b10,
            
            Invalid      = 2'b11
        } ForwardSrc; 
        
        // alu src1 mux
        logic [31:0] rs1_src;
        
        always_comb
        begin
            case (E_rs1_sel)  
                2'b00:  rs1_src = 32'b0;   // LUI 
                2'b01:  rs1_src = E_pc;      // AUIPC | the concerned instruction 
                2'b10:  rs1_src = E_rs1;    //  normal case
                
                default:
                    rs1_src = 32'bz;  // reserved for future use 
                    
            endcase
        end
        
        // forwarding mux placed after the source reg line
        logic [31:0]  SrcA, SrcB; 
        
        always_comb // p mux 1
        begin 
            case (ForwardA) 
                Fwd_MEM:   SrcA = M_ALUResult;
                Fwd_WB  :    SrcA = result;      // the final result line
                Fwd_SRC:    SrcA = rs1_src;
                Invalid:         SrcA = 32'bz;
            endcase
        end
        
        // forwarding mux to be placed before the source reg line 
        logic [31:0] rs2_src; 
        
        always_comb 
        begin 
            case (ForwardB) // p mux 2
                Fwd_MEM:   SrcB = M_ALUResult; // M_ALUResult is declared below!
                Fwd_WB  :    SrcB = result;      // the final result line
                Fwd_SRC:    SrcB = E_rs2;
                Invalid:         SrcB = 32'bz;
            endcase
        end
        
        // alu src 2 mux
        mux_2x1 REG_OR_IMM_MUX (
            .a(SrcB), 
            .b(E_immExt),
            .sel(E_ALUSrc),
            .out(rs2_src)   // the value we get for rs2 
        );   


        logic IsZero; // branching indicator
        alu  ALU (
            .rs1(SrcA),     // mux placed after the src1 mux
            .rs2(rs2_src), // mux placed before the src1 mux
            .ALUControl(E_ALUControl), 
            .data(ALUResult),    // goes to Register File
            .Zero(IsZero)
        );
        
        // NOTE: rs2_src is a bad name, chnage it. TODO
        
        // [deprecated comment] don't i need an adder here ? yes, cause now we at jumps 
        // we need support for either offsetting the PC with imm20 or PC+4, so a simple
        // mux will do 
        
        always_comb 
        begin 
        
            if (E_Jump) begin
                if (E_JumpSrc) pc_next = ALUResult;         // JALR
                else                  pc_next = E_pc + rs2_src;   // JAL 
            end 
            else if (E_Branch) begin // beq operation 
                if (IsZero) 
                    pc_next = E_pc + E_immExt;   // we need the pc for current instruction .
                else 
                    pc_next = pc_plus_4; // we need the next instruction to be read. we good with computing the pc + 4 in the first ever stage. 
            end
            else  pc_next = pc_plus_4;
             
        end
        
        // pipe line register 
        logic M_MemWrite; 
        logic M_MemRead;
        logic M_Jump;
        // logic M_RegWrite;
        
        logic M_MemToReg; 
         
        // logic [31:0] M_ALUResult;
        logic [31:0] M_rs2;
        logic [ 2:0 ] M_funct3;
        // logic [ 4:0 ] M_addr_rd; // declared above for forwarding logic
        logic [31:0] M_pc_next;
        
        EX_MEM_Stage STAGE_3 (
            .clk(clk),  .rst(rst), 
            .E_MemWrite(E_MemWrite), 
            .E_MemRead(E_MemRead),
            .E_RegWrite (E_RegWrite),
            .E_Jump(E_Jump),
            .E_MemToReg(E_MemToReg),
            .E_ALUResult(ALUResult), 
            .E_rs2(SrcB), // that issue which Anas pointed me at! ;)
            .E_funct3(E_funct3),
            .E_addr_rd(E_addr_rd),
            .E_pc_next(E_pc_next), // i won't apparently be using this i guess :=(
            
            .M_MemWrite(M_MemWrite), 
            .M_MemRead(M_MemRead),
            .M_RegWrite  (M_RegWrite),
            .M_Jump (M_Jump),
            .M_MemToReg(M_MemToReg),
            .M_ALUResult(M_ALUResult), 
            .M_rs2(M_rs2),
            .M_funct3(M_funct3),
            .M_addr_rd(M_addr_rd),
            .M_pc_next(M_pc_next) // won't !!! :(  
        );
        /* EX/MEM end */
        
        // 7. Now this "data" could either be 
        // the result from ALU or data from data memory effectively. 
        // so we need data memory followed by a 2x1 mux to 
        // select between both.
        
        /* MEM/WB start */
        logic [31:0] dataR;
        
        data_memory DMEM (
            .clk(clk), 
            .MemRd(M_MemRead), 
            .MemWr(M_MemWrite),
            .addr(M_ALUResult),   // data here is the computed address from ALU
            .dataW(M_rs2),            // in case of SW
            .funct3(M_funct3),      
            .dataR(dataR)          // data from memory, to be written to a register (LW)
        );
        
        // 8. Mux to propagate either the ALU result or 
        // the Memory data to the register file 
        
        // pipeline processor
        logic W_MemToReg;
        // logic W_RegWrite; 
        
        logic [31:0] W_dataR;
        // logic [ 4:0 ] W_addr_rd; 
        logic [31:0] W_ALUResult;
        logic [31:0] W_pc_next;  // unused still , courtesy of my love for this signal!

        MEM_WB_Stage STAGE_4 (
            .clk(clk), .rst(rst),
            
            .M_RegWrite(M_RegWrite), 
            .M_Jump(M_Jump),
            .M_MemToReg(M_MemToReg),
            .M_dataR (dataR),
            .M_addr_rd(M_addr_rd),
            .M_ALUResult(M_ALUResult),
            .M_pc_next(M_pc_next), // courtesy of my love for this signal yet again!

            .W_RegWrite(W_RegWrite),  // feedsback to ID stage
            .W_Jump(W_Jump),
            .W_MemToReg(W_MemToReg),
            .W_dataR (W_dataR),
            .W_addr_rd(W_addr_rd),
            .W_ALUResult(W_ALUResult),
            .W_pc_next(W_pc_next) 
            
        ); 
        
        mux_2x1 ALU_OR_MEM_OUT (
            .a  (W_ALUResult), // from prev stage
            .b  (W_dataR),             // from curr stage 
            .sel(W_MemToReg), 
            .out(result)                 // this result goes to another mux placed before RF
        );
        
        /* MEM/WB end */
        
endmodule