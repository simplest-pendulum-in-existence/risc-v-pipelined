`timescale 1ps/1ps

module tb_alu; 

    // Inputs
    logic [31:0] rs1;
    logic [31:0] rs2;
    logic [3:0]  ALUControl;

    // Output
    logic [31:0] data;

    // DUT
    alu arithmatic_logic_unit (
        .rs1(rs1),
        .rs2(rs2),
        .ALUControl(ALUControl),
        .data(data)
    );

    initial begin
        // ADD: 2 + 3 = 5
        rs1 = 2;
        rs2 = 3;
        ALUControl = 4'd2;
        #10;

        // SUB: 7 - 4 = 3
        rs1 = 7;
        rs2 = 4;
        ALUControl = 4'd6;
        #10;

        // AND: 6 & 3 = 2
        rs1 = 6;       // 0110
        rs2 = 3;       // 0011
        ALUControl = 4'd0;
        #10;

        // OR: 5 | 2 = 7
        rs1 = 5;       // 0101
        rs2 = 2;       // 0010
        ALUControl = 4'd1;
        #10;

        // XOR: 6 ^ 3 = 5
        rs1 = 6;       // 0110
        rs2 = 3;       // 0011
        ALUControl = 4'd9;
        #10;

        // SLL: 1 << 2 = 4
        rs1 = 1;
        rs2 = 2;
        ALUControl = 4'd4;
        #10;

        // SRL: 8 >> 1 = 4
        rs1 = 8;
        rs2 = 1;
        ALUControl = 4'd8;
        #10;

        // SRA: -16 >>> 2 = -4
        rs1 = -16;
        rs2 = 2;
        ALUControl = 4'd3;
        #10;

        // SLT: (3 < 4) = 1
        rs1 = 3;
        rs2 = 4;
        ALUControl = 4'd5;
        #10;

        // SLTU: (3 < 4) unsigned = 1
        rs1 = 3;
        rs2 = 4;
        ALUControl = 4'd7;
        #10;

        $finish;
    end

endmodule

