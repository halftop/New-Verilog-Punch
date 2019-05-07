// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Author: halftop
// Github: https://github.com/halftop
// Email: yu.zh@live.com
// Description: 按键消抖模块的testbench
// Dependencies: debounce.v
// LastEditors: halftop
// Since: 2019-05-07 17:50:38
// LastEditTime: 2019-05-07 20:57:55
// ********************************************************************
// Module Function:

module tb_debounce;
reg		clk		;
reg		rst_n	;
reg		key_in	;
wire	key_vld	;

initial begin
	clk = 1;
	forever #10 clk = ~clk;
  end

initial begin
	rst_n = 1'b0;
	#22 rst_n = 1'b1;
  end

initial begin
	key_in = 1'b1;
	repeat(15) begin
		@(posedge clk)
			key_in = {$random};
	end
	repeat(25) begin
		@(posedge clk)
			key_in = 1'b0;
	end
	repeat(25) begin
		@(posedge clk)
			key_in = 1'b1;
	end
	repeat(15) begin
		@(posedge clk)
			key_in = {$random};
	end
	$finish;
end

debounce
#(
	 'd10
)
debounce
(
	.clk		(clk	),
	.rst_n		(rst_n	),
	.key_in		(key_in	),
	.key_vld	(key_vld)	
);
endmodule