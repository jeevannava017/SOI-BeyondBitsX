`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 01:31:43
// Design Name: 
// Module Name: rle_top
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


module rle_top( input clk,
input rst,
input [7:0]current_char,
input data_valid,
input last,
output [7:0]char_out,
output [7:0]count_out);
wire same;
wire count_full;
wire count_inc;
wire count_load_one;
wire load_prev;
wire load_output;
wire [7:0] prev_char;
wire [7:0] count;
comparator cmp(
.current_char(current_char),
.prev_char(prev_char),
.same(same)
);
prev_register prev_reg(
.clk(clk),
.rst(rst),
.load_prev(load_prev),
.prev_char(prev_char),
.current_char(current_char)
);
counter cnt(
.clk(clk),
.rst(rst),
.count_load_one(count_load_one),
.count_inc(count_inc),
.count(count),
.count_full(count_full)
);
controller ctrl(
.clk(clk),
.rst(rst),
.same(same),
.count_load_one(count_load_one),
.count_inc(count_inc),
.last(last),
.count_full(count_full),
.load_prev(load_prev),
.load_output(load_output),
.data_valid(data_valid)
);
output_register op_reg(
.clk(clk),
.rst(rst),
.load_output(load_output),
.prev_char(prev_char),
.char_out(char_out),
.count(count),
.count_out(count_out)
);
endmodule
