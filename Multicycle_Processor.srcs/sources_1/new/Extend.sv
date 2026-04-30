`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.04.2026 20:59:26
// Design Name: 
// Module Name: Extend
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Extend(
        input logic [6:0] opcode,
        input logic [31:5] instr,
        output logic [31:0] Q
    );
    
    always_comb begin
        if(opcode == 7'b0000011) begin
        //lw
            Q = {{20{instr[31]}}, instr[31:20]};
        end
        else if(opcode == 7'b0100011) begin
        //sw
            Q = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        end
    end 
    
endmodule
