`timescale 1ns / 1ps



module Main(
    input clk,
    input reset
);
    //Enable and Write bits
        //Enable for PC Register
        logic PC_REG_EN;
        
        //Main Memory
        //Write enable for Main memory
        logic Memory_WE;
        //Enable for Instruction Register
        logic IR_EN;
        //Enable for Data Register
        logic DR_EN;
        
        //Register
        //Write data select line for multiplexer
        logic [1:0] Register_WD_SELECT;
        //Write enable for Register file
        logic RegisterFile_WE;
        //Enable for Register register
        logic Register_REG_EN;
        
        //ALU
        //Enable for ALU Register
        logic ALU_REG_EN;
        
    //Mutex select bits and control bits
        logic AddrSrc;
        logic [1:0] ALU_ASelect;
        logic [1:0] ALU_BSelect;
        logic [2:0] ALUControl;
        
    //wires
    //PC
    logic [31:0] PCNext;
    logic [31:0] PC;
    logic [31:0] PCOld;
    //Memory
    logic [31:0] Memory_A;
    logic [31:0] Memory_RD;
    logic [31:0] IR_out;
    logic [31:0] DR_out;
    //Register file
    logic [31:0] RegisterFile_RD1;
    logic [31:0] RegisterFile_RD2;
    logic [31:0] RegisterFile_WD;
    logic [31:0] RegisterFile_RD1_out;
    logic [31:0] RegisterFile_RD2_out;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    //Extend
    logic [31:0] extendedImm;
    //ALU
    logic [31:0] ALU_A;
    logic [31:0] ALU_B;
    logic [31:0] ALUResult;
    logic [31:0] ALUOut;
    logic Zero, Negative, Overflow, Carry;
    
   
    
    //Control Unit
    ControlUnit CU(
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        
        .PC_REG_EN(PC_REG_EN),
        .AddrSrc(AddrSrc),
        .Memory_WE(Memory_WE),
        .IR_EN(IR_EN),
        .DR_EN(DR_EN),
        .RegisterFile_WE(RegisterFile_WE),
        .Register_WD_SELECT(Register_WD_SELECT),
        .Register_REG_EN(Register_REG_EN),
        .ALU_REG_EN(ALU_REG_EN),
        .ALU_ASelect(ALU_ASelect),
        .ALU_BSelect(ALU_BSelect),
        .ALUControl(ALUControl)
    );
    
    //Program counter modules
    FlipFlop_32bit PC_REG(
        .clk(clk),
        .reset(reset),
        .en(PC_REG_EN), 
        .next(PCNext), 
        .Q(PC)
    );
    
    
    
    //Main memory modules
    //Multiplexer for Memory Address
    mux2_1_32bit AddrSrc_Mux(
        .a(PC), 
        .b(ALUOut), 
        .s(AddrSrc), 
        .q(Memory_A)
    );
    //Instruction and Data Memory
    MainMemory mainMemory(
        .clk(clk), 
        .WEN(Memory_WE), 
        .A(Memory_A), 
        .WD(RegisterFile_RD2_out),
        .RD(Memory_RD)
    );
    //Instruction and Data Registers
    FlipFlop_32bit IR(
        .clk(clk), 
        .reset(reset),
        .en(IR_EN), 
        .next(Memory_RD), 
        .Q(IR_out)
    );
    assign opcode = IR_out[6:0];
    assign funct3 = IR_out[14:12];
    assign funct7 = IR_out[31:25];
    
    FlipFlop_32bit DR(
        .clk(clk), 
        .reset(reset),
        .en(DR_EN), 
        .next(Memory_RD), 
        .Q(DR_out)
    );
    
    //Register File modules
    //Register File
    
    mux4_1_32bit Register_WD_Mux(
        .a(DR_out), 
        .b(ALUOut),
        .c(),
        .d(), 
        .s(Register_WD_SELECT), 
        .q(RegisterFile_WD)
    );
    RegisterFile registerFile(
        .clk(clk), 
        .WEN(RegisterFile_WE), 
        .A1(IR_out[19:15]), 
        .A2(IR_out[24:20]),
        .A3(IR_out[11:7]), 
        .WD3(RegisterFile_WD), 
        .RD1(RegisterFile_RD1), 
        .RD2(RegisterFile_RD2)
    );
    //Registers A/B for RD1 and RD2 of Register File
    FlipFlop_32bit RegisterFile_REG1(
        .clk(clk), 
        .reset(reset),
        .en(Register_REG_EN), 
        .next(RegisterFile_RD1), 
        .Q(RegisterFile_RD1_out)
    );
    FlipFlop_32bit RegisterFile_REG2(
        .clk(clk), 
        .reset(reset),
        .en(Register_REG_EN), 
        .next(RegisterFile_RD2), 
        .Q(RegisterFile_RD2_out)
    );
    
    
    
    //Extend for Immediate Value
    Extend extendUnit(
        .opcode(opcode),
        .instr(IR_out[31:5]), 
        .Q(extendedImm)
    );
    
    //ALU modules
    //ALU muxes for A and B of ALU
    mux4_1_32bit ALU_ASelect_MUX(
        .a(RegisterFile_RD1_out), 
        .b(PC), 
        .c(),
        .d(),
        .s(ALU_ASelect), 
        .q(ALU_A)
    );
        
    mux4_1_32bit ALU_BSelect_MUX(
        .a(extendedImm), 
        .b(32'h4), 
        .c(RegisterFile_RD2_out),
        .d(),
        .s(ALU_BSelect), 
        .q(ALU_B)
    );
    //ALU
    ALU alu(
        .A(ALU_A),
        .B(ALU_B),
        .ALUControl(ALUControl), 
        .Y(ALUResult), 
        .Zero(Zero), 
        .Negative(Negative), 
        .Overflow(Overflow), 
        .Carry(Carry)
    );
    //ALU Register
    FlipFlop_32bit ALU_REG(
        .clk(clk), 
        .reset(reset),
        .en(ALU_REG_EN), 
        .next(ALUResult), 
        .Q(ALUOut)
     );
    
    //Set PCNext to calculated PC + 4
    assign PCNext = ALUResult;   
    
endmodule