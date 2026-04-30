module FlipFlop_32bit(
    input logic clk,
    input logic reset,
    input logic en,
    input logic [31:0] next,
    output logic [31:0] Q
);
    always_ff @(posedge clk) begin
        if(reset) begin
            Q <= 32'b0;
        end
        else if(en) begin
            Q <= next;
        end
    end

endmodule

module MainMemory(
    input logic clk,
    input logic WEN,
    input logic [31:0] A,
    input logic [31:0] WD,
    output logic [31:0] RD
);

    logic [31:0] RAM [1023:0];

    always_ff @(posedge clk) begin
        if(WEN) begin
            RAM[A[11:2]] <= WD;
        end
    end    
    
    initial begin
        for (int i = 0; i < 1024; i++) begin
            RAM[i] = 32'b0;
        end
        $readmemb("program.mem", RAM);
    end
    
    assign RD = RAM[A[11:2]];

endmodule

module RegisterFile(
    input  logic        clk,
    input  logic        WEN,
    input  logic [4:0]  A1, A2, A3,
    input  logic [31:0] WD3,
    output logic [31:0] RD1, RD2
);
    logic [31:0] registers [31:0];

    assign registers[0] = 32'b0;
    
    always_ff @(posedge clk) begin
        if (WEN && (A3 != 5'b0)) begin 
            registers[A3] <= WD3;
        end
    end

    assign RD1 = registers[A1];
    assign RD2 = registers[A2];

endmodule