`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 00:13:36
// Design Name: 
// Module Name: counter
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


module counter(input clk,
input rst,
input count_inc,
input count_load_one,
output reg [7:0] count,
output count_full
    );
    always@(posedge clk or posedge rst)begin
    if(rst) begin
    count<=8'b0;
    end
    else if(count_load_one)begin
    count<=8'd1;
    end
    else if(count_inc) begin
    count<=count+1;
    
    end
    end
    assign count_full=(count==8'd255);
endmodule
