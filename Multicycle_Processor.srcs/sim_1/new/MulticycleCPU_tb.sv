`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.04.2026 23:44:28
// Design Name: 
// Module Name: MulticycleCPU_tb
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

module MulticycleCPU_tb();

    logic clk;
    logic reset;
    logic [31:0] testValue;
    logic [31:0] testInstruction;
    logic [31:0] expectedValue;
    
    //lw x1, 4(x0)
    
    assign expectedValue = 32'hDEADBEEF;

    Main dut (
        .clk(clk),
        .reset(reset),
        .testInstruction(testInstruction),
        .testValue(testValue)
    );

    always begin
        clk = 1'b0; #10;
        clk = 1'b1; #10;
    end


    initial begin

        $display("Starting CPU Simulation...");

        reset = 1'b1;

        #35; 
        
        reset = 1'b0; 

        //lw = 5*20ns = 100ns
        #100;
        if(testValue == expectedValue) begin
            $display("Test Successfull with value: %h", testValue);
            $display("Machine code of Instruction: %h", testInstruction);
        end
        else begin
            $display("Test Failure with value: %h", testValue);
            $display("Machine code of Instruction: %h", testInstruction);
        end        
        
        $finish;
    end

endmodule
