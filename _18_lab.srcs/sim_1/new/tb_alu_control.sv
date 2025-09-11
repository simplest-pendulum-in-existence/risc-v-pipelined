`timescale 1ns / 1ps


module tb_alu_control;

    // I can even this test this on those provided instructions 
    
    // inputs
    logic [2:0] funct3; 
    logic [6:0] funct7; 
    logic [1:0] ALUOp;
    
    
    // outputs
    logic [3:0] ALUControl;
    
    
    // instantiate 
    alu_control     alu_ctrl (
        .funct3(funct3), 
        .funct7(funct7),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );
    
    // testing 
    
    initial begin 
    
        // for cases when it'_undefined should be the output 
       
        // 1. undefined operation i.e 12 ? 
        ALUOp = 2'b10; 
        funct3 = 3'b011; 
        funct7 = 7'b1; // no such case 
        #10;

        ALUOp = 2'b11; // undefined yet 
        funct3 = 3'b010;
        funct7 = 7'b1;
        #10;

        // testing correct conditions 
        funct3 = 3'b111; // AND case
        funct7 = 7'b1;  // but now it would do subtraction
        ALUOp = 2'b10 ; // RI 
        #10;

        $finish;
    end
    
    
    
endmodule

/*
launch_simulation
open_wave_config C:/HamzaMateen/Architecture/_18_lab/tb_register_file_behav.wcfg
source <that file>  // i don't want this
*/