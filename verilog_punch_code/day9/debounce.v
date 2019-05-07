// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Author: halftop
// Github: https://github.com/halftop
// Email: yu.zh@live.com
// Description: 按键消抖模块
// Dependencies: 
// LastEditors: halftop
// Since: 2019-05-07 09:45:37
// LastEditTime: 2019-05-07 11:09:10
// ******************************************************************** 
// Module Function:按键消抖

module debounce
#(
	parameter DELAY_TIME = 18'h3ffff
)
(
	input				clk,
	input				rst_n,
	input				key_in,
	output	reg			key_vld
);

localparam	IDLE		= 4'b0001,
			PRESS_DELAY	= 4'b0010,
			WAIT_RELEASE= 4'b0100,
			RELEASE_DELA= 4'b1000;

reg [1:0] key_in_r;
wire key_press_edge;
wire key_release_edge;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		key_in_r <= 2'b11;
	end else begin
		key_in_r <= {key_in_r[0],key_in};
	end
end
assign key_press_edge = key_in_r[1] & (~key_in_r[0]);
assign key_release_edge = (~key_in_r[1]) & key_in_r[0];


reg	[17:0]	  cnt;
reg [3:0] cstate,nstate;
//FSM-1
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cstate <= IDLE;
	end else begin
		cstate <= nstate;
	end
end
//FSM-2
always @(*) begin
	case (cstate)
		IDLE	 : nstate = key_press_edge ? PRESS_DELAY : IDLE;
		PRESS_DELAY: begin
			if (cnt==DELAY_TIME && key_in_r[0] == 0) begin
				nstate = WAIT_RELEASE;//按下完成
			end else if (cnt<DELAY_TIME && key_in_r[0] == 1) begin
				nstate = IDLE;//抖动
			end else begin
				nstate = PRESS_DELAY;//计数未完成
			end
		end
		WAIT_RELEASE: nstate = key_release_edge ? RELEASE_DELA : WAIT_RELEASE;
		RELEASE_DELA: begin
			if (cnt==DELAY_TIME && key_in_r[0] == 1) begin
				nstate = IDLE;//松开完成
			end else if (cnt<DELAY_TIME && key_in_r[0] == 0) begin
				nstate = WAIT_RELEASE;//抖动
			end else begin
				nstate = RELEASE_DELA;//计数未完成
			end
		end
		default: nstate = IDLE;
	endcase
end
//FSM-3
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		key_vld <= 1'b1;
	end else begin
		case (nstate)
			IDLE,PRESS_DELAY:key_vld <= 1'b1;
			WAIT_RELEASE,RELEASE_DELA: key_vld <= 1'b0;
			default: key_vld <= 1'b1;
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
		cnt <= 18'd0;
    else if (cstate==PRESS_DELAY || cstate==RELEASE_DELA) begin
		if (cnt==DELAY_TIME) begin
			cnt <= 18'd0;
		end else begin
			cnt <= cnt + 1'b1;
		end
	end else begin
		cnt <= 18'd0;
	end
end  
endmodule