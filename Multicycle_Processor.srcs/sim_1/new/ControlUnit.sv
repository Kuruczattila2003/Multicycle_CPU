`timescale 1ns / 1ps

/*
lw states:

S0 (Fetch) -> PC_REG_EN = 1, AddrSrc = 0, ALU_ASelect = 1, ALU_BSelect = 1, IR_EN = 1, DR_EN = 1, ALUControl = 3'b000

S1 (Decode) -> IR_EN = 0, DR_EN = 0, RegisterFile_RD1_EN = 1, RegisterFile_RD2_EN = 1

S2 (Execute) -> ALU_ASelect = 0, ALU_BSelect = 0, ALU_REG_EN = 1, ALUControl = 3'b000

S3 (Memory_read) -> AddrSrc = 1, DR_EN = 1

S4 (RegisterFile_write) -> RegisterFile_WE = 1

*/

module ControlUnit(
        input clk,
        input reset,
        input  logic [6:0] op,
        input logic [2:0] funct3,
        input logic [6:0] funct7,
        
        output logic PC_REG_EN,
        output logic AddrSrc,
        output logic Memory_WE,
        output logic IR_EN,
        output logic DR_EN,
        output logic RegisterFile_WE,
        output logic Register_REG_EN,
        output logic ALU_REG_EN,
        output logic ALU_ASelect,
        output logic ALU_BSelect,
        output logic [2:0] ALUControl
    );
    
    typedef enum logic [2:0] {
        FETCH = 3'b000,
        DECODE = 3'b001,
        EXECUTE = 3'b010,
        MEM_READ = 3'b011,
        REGFILE_WRITE = 3'b100
    } state_t;
    
    state_t state;
    state_t nextState;
    
    always @(posedge clk) begin
        if(reset) begin
            state <= FETCH;
        end
        else begin
            state <= nextState;
        end
    end
    
    always_comb begin
        
        //Default to avoid latch
        PC_REG_EN = 1'b0;
        AddrSrc = 1'b0;
        Memory_WE = 1'b0;
        IR_EN = 1'b0;
        DR_EN = 1'b0;
        RegisterFile_WE = 1'b0;
        Register_REG_EN = 1'b0;
        ALU_REG_EN = 1'b0;
        ALU_ASelect = 1'b0;
        ALU_BSelect = 1'b0;
        ALUControl = 3'b000;
        
        case(state)         
            //S0 (Fetch) -> PC_REG_EN = 1, AddrSrc = 0, ALU_ASelect = 1, ALU_BSelect = 1, IR_EN = 1, DR_EN = 1, ALUControl = 3'b000
            FETCH: begin
                PC_REG_EN = 1'b1;
                ALU_ASelect = 1'b1;
                ALU_BSelect = 1'b1;
                IR_EN = 1'b1;
                DR_EN = 1'b1;
                ALUControl = 3'b000;
                nextState = DECODE;
            end
            //S1 (Decode) -> IR_EN = 0, DR_EN = 0, RegisterFile_RD1_EN = 1, RegisterFile_RD2_EN = 1
            DECODE: begin
                Register_REG_EN = 1'b1;
                nextState = EXECUTE;
            end
            //S2 (Execute) -> ALU_ASelect = 0, ALU_BSelect = 0, ALU_REG_EN = 1, ALUControl = 3'b000
            EXECUTE: begin
                ALU_REG_EN = 1'b1;
                ALUControl = 3'b000;
                nextState = MEM_READ;
            end
            //S3 (Memory_read) -> AddrSrc = 1, DR_EN = 1
            MEM_READ: begin
                AddrSrc = 1'b1;
                DR_EN = 1'b1;
                nextState = REGFILE_WRITE;
            end
            //S4 (RegisterFile_write) -> RegisterFile_WE = 1
            REGFILE_WRITE: begin
                RegisterFile_WE = 1'b1;
                nextState = FETCH;
            end
        
            default: begin
                nextState = FETCH;
        end
        endcase
        
    end
    
endmodule
