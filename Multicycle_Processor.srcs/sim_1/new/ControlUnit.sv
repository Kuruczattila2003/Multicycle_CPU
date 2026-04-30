`timescale 1ns / 1ps

/*
lw states:

S0 (Fetch) -> PC_REG_EN = 1, AddrSrc = 0, ALU_ASelect = 1, ALU_BSelect = 1, IR_EN = 1, DR_EN = 1, ALUControl = 3'b000
S1 (Decode) -> IR_EN = 0, DR_EN = 0, RegisterFile_RD1_EN = 1, RegisterFile_RD2_EN = 1
S2 (Execute) -> ALU_ASelect = 00, ALU_BSelect = 00, ALU_REG_EN = 1, ALUControl = 3'b000
S3 (Memory_read) -> AddrSrc = 1, DR_EN = 1
S4 (RegisterFile_write) -> RegisterFile_WE = 1, Register_WD_SELECT = 00

sw states:
S0 (Fetch) -> same as lw
S1 (Decode) -> same as lw
S2 (Execute) -> same as lw
S5 (Memory_Write) -> AddSrc = 1, Memory_WE = 1
 
R-Type: add, sub, and, or, slt
S0 (Fetch)
S1 (Decode)
S6 (Execute) -> ALU_ASelect = 00, ALU_BSelect = 10, ALU_REG_EN = 1, ALUControl = depends on opcode
S7 (ALUWriteback) -> RegisterFile_WE = 1, Register_WD_SELECT = 01 


*/

module ControlUnit(
        input clk,
        input reset,
        input  logic [6:0] opcode,
        input logic [2:0] funct3,
        input logic [6:0] funct7,
        
        output logic PC_REG_EN,
        output logic AddrSrc,
        output logic Memory_WE,
        output logic IR_EN,
        output logic DR_EN,
        output logic RegisterFile_WE,
        output logic Register_WD_SELECT,
        output logic Register_REG_EN,
        output logic ALU_REG_EN,
        output logic [1:0] ALU_ASelect,
        output logic [1:0] ALU_BSelect,
        output logic [2:0] ALUControl
    );
    
    typedef enum logic [2:0] {
        FETCH = 3'b000,
        DECODE = 3'b001,
        EXECUTE = 3'b010,
        MEM_READ = 3'b011,
        REGFILE_WRITE = 3'b100,
        MEM_WRITE = 3'b101,
        ExecuteR = 3'b110,
        ALUWriteback = 3'b111
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
        Register_WD_SELECT = 2'b00;
        Register_REG_EN = 1'b0;
        ALU_REG_EN = 1'b0;
        ALU_ASelect = 2'b00;
        ALU_BSelect = 2'b00;
        ALUControl = 3'b000;
        
        case(state)         
            //S0 (Fetch) -> PC_REG_EN = 1, AddrSrc = 0, ALU_ASelect = 1, ALU_BSelect = 1, IR_EN = 1, DR_EN = 1, ALUControl = 3'b000
            FETCH: begin
                PC_REG_EN = 1'b1;
                ALU_ASelect = 2'b01;
                ALU_BSelect = 2'b01;
                IR_EN = 1'b1;
                DR_EN = 1'b1;
                ALUControl = 3'b000;
                nextState = DECODE;
            end
            //S1 (Decode) -> IR_EN = 0, DR_EN = 0, RegisterFile_RD1_EN = 1, RegisterFile_RD2_EN = 1
            DECODE: begin
                Register_REG_EN = 1'b1;
                if(opcode == 7'b0000011 || opcode == 7'b0100011) begin
                    //sw or lw instruction
                    nextState = EXECUTE;
                end
                else if(opcode == 7'b0110011) begin
                    //R-Type instruction
                    nextState = ExecuteR;
                end
                else begin
                    nextState = FETCH;
                end
            end
            //S2 (Execute) -> ALU_ASelect = 0, ALU_BSelect = 0, ALU_REG_EN = 1, ALUControl = 3'b000
            EXECUTE: begin
                ALU_REG_EN = 1'b1;
                ALUControl = 3'b000;
                if(opcode == 7'b0000011) begin
                //lw instruction
                    nextState = MEM_READ;
                end
                else if(opcode == 7'b0100011) begin
                //sw instruction
                    nextState = MEM_WRITE;
                end
                
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
                Register_WD_SELECT = 2'b00;
                nextState = FETCH;
            end
            //S5 (Memory write) -> AddrSrc = 1, Memory_WE = 1
            MEM_WRITE: begin
                AddrSrc = 1'b1;
                Memory_WE = 1'b1;
            end
            //S6 (Execute for R-Type) -> ALU_ASelect = 00, ALU_BSelect = 10, ALU_REG_EN = 1, ALUControl = varies
            ExecuteR: begin
                ALU_BSelect = 2'b10;
                ALU_REG_EN = 1'b1;
                case(funct7)
                    7'b000000: begin
                        case(funct3)
                            3'b000: begin
                                //addition
                                ALUControl = 3'b000;
                            end
                            3'b110: begin
                                //bitwise OR
                                ALUControl = 3'b011;
                                
                            end
                            3'b111: begin
                                //bitwise AND
                                ALUControl = 3'b010;
                            end
                            default: begin
                                ALUControl = 3'b000;
                            end
                        endcase
                    end
                    
                    7'b0100000: begin
                        case(funct3)
                            3'b000: begin
                                //substraction
                                ALUControl = 3'b001;
                            end
                            default: begin
                                ALUControl = 3'b000;
                            end
                        endcase
                    end
                    
                    default: begin
                        ALUControl = 3'b000;
                    end
                endcase
                nextState = ALUWriteback;
            end
            
       ALUWriteback: begin
                RegisterFile_WE = 1'b1;
                Register_WD_SELECT = 2'b01;
                nextState = FETCH;
       end     
            
        default: begin
            nextState = FETCH;
        end
        
       
        endcase
        
    end
    
endmodule
