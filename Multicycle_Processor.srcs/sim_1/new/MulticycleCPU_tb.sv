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
   

    Main dut (
        .clk(clk),
        .reset(reset)
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

        //lw + sw = 2*5*20ns = 200ns
        #200
        #100
        $display("Test finished");
        $finish;
    end

endmodule
