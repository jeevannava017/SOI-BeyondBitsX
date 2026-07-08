`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 00:29:41
// Design Name: 
// Module Name: output_register
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


module output_register(
input clk,
input rst,
input load_output,
input [7:0] prev_char,
input [7:0] count,
output reg [7:0]char_out,
output reg [7:0]count_out

    );
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    char_out<=8'd0;
    count_out<=8'd0;
    end
    else if(load_output) begin
    char_out<=prev_char;
    count_out<=count;
    end
    end
endmodule
