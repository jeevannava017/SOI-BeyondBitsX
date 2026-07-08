`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2026 01:11:40
// Design Name: 
// Module Name: prev_register
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


module prev_register(
input clk,
input rst,
input load_prev,
input [7:0]current_char,
output reg [7:0]prev_char
    );
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    prev_char<=8'b0;
    end
    else if(load_prev) begin
    prev_char<=current_char;
    end
    end
    
endmodule
