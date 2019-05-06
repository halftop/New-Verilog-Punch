`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/01 16:08:05
// Design Name: 
// Module Name: tb27
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


module tb27(    );
reg clk,rst_n;
wire [3:0]  o_cnt;

initial fork
  clk = 1'b0;
  rst_n = 1'b0;
  #20 rst_n = 1'b1;
  #455 rst_n = 1'b0;
  #475 rst_n = 1'b1;
  #600 $finish;
join

always #10 clk = ~ clk;

test27  cnt4(
    .clk    (clk  ),
    .rst_n  (rst_n),
    .o_cnt  (o_cnt)
    );
endmodule
