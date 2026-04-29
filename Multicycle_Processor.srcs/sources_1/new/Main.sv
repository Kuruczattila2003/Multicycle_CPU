`timescale 1ns / 1ps



module Main(
    input clk
);
    
    logic [31:0] pc_wire;
    
    PC_Register(.clk(clk), .en(), .PCnext(), .PC(pc_wire));
    MainMemory(.clk(clk), .WEN(), .A(), .WD(), .RD());
    RegisterFile(.clk(clk), .WEN(), .A1(), .A2(), .A3(), .WD3(), .RD1(), .RD2());
    
    
    
endmodule
