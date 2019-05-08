`define SIMULATION;
module tb_pwm_led;
reg clk;
reg rst_n;
wire pwm_sig;

initial begin
	clk = 1;
	forever #1 clk = ~clk;
  end

initial begin
	rst_n = 1'b0;
	#22 rst_n = 1'b1;
	#20000 $finish;
  end

pwm_genrate
#(
	5,	//MHz
	1,	//us
	1,	//ms
	2		//s
)
pwm_led
(
	.clk		(clk	),
	.rst_n		(rst_n	),
	.pwm_sig	(pwm_sig)	
);
endmodule