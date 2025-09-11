`timescale 1ns / 1ps

module tb_main_control; 

    logic [6:0] OpCode; 
    
    logic RegWrite, ALUSrc;
    logic [1:0] ALUOp; 
    
    main_control m_ctrl (
        .OpCode(OpCode),
        .RegWrite(RegWrite), 
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    );
    
    
    // sang dil tere bhi aansu nikal aye honge....
    // dhundne wale ne jab tujhko pukara hoga!!!
    
    
    initial begin 
        $monitor("time=%0t | OpCode=%0d | RegWrite=%b | ALUSrc=%b | ALUOp=%b",
                  $time, OpCode, RegWrite, ALUSrc, ALUOp);
                  
                  
        OpCode = 7'd1;    // all signals should be zero for this undefined Instruction Type
        
        # 10; 
        
        // testing R Type now 
        OpCode = 7'd51; 
        
        
        # 20 $finish;
           
    end
    
endmodule
















