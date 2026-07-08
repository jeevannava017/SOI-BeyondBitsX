`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 23:58:00
// Design Name: 
// Module Name: controller
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


module controller( input clk,
input rst,
input same,
input count_full,
input last,
input data_valid,
output reg load_prev,
output reg count_inc,
output reg count_load_one,
output reg load_output
    );
    parameter IDLE=2'b00;
    parameter PROCESS=2'b01;
    parameter OUTPUT=2'b10;
    parameter FINISH=2'b11;
    reg [1:0] current_state;
    reg [1:0] next_state;
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    current_state<=IDLE;
    end
    else begin
    current_state<=next_state;
    end
    end
    always@(*) begin
    next_state = current_state;
    case(current_state)
    IDLE:
    begin
    if(data_valid) begin
    next_state=PROCESS;
    end
    end
    PROCESS:
    begin
    if(last && same)
    begin
    next_state=FINISH;
    end
    else if(last && !same)
    begin
    next_state=OUTPUT;
    end
    else if(count_full)
    begin
    next_state=OUTPUT;
    end
    else if(!same)
    begin
    next_state=OUTPUT;
    end
    else
    begin
    next_state=PROCESS;
    end    
    end
    OUTPUT:
    begin
    if(last) begin
    next_state=FINISH;
    end
    else begin
    next_state=PROCESS;
    end
    end
    FINISH:
    begin
    next_state=IDLE;
    end
    endcase
    end
    always@(*) begin
    load_prev=0;
    count_inc=0;
    count_load_one=0;
    load_output=0;    
    case(current_state)
    IDLE:
    begin
    if(data_valid) begin
    load_prev=1;
    count_load_one=1;
    end
    end
    PROCESS:
    begin
    if(same)
    begin
    count_inc=1;
    end
    end
    OUTPUT:
    begin
    load_output=1;
    load_prev=1;
    count_load_one=1;
    end
    FINISH:
    begin
    load_output=1;
    end
    endcase
    end
endmodule
