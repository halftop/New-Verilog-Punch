---
title: Verilog没有葵花宝典——day10（PWM）
date: 2019-05-08 17:05:52
tags: [Verilog没有葵花宝典,IC,FPGA,Verilog HDL,学习笔记]
published: false
hideInList: false
feature: 
---
## 题目

> 用verilog实现PWM控制呼吸灯。呼吸周期2秒：1秒逐渐变亮，1秒逐渐变暗。系统时钟24MHz，pwm周期1ms，精度1us。

### 思路

<center>
 <img src="https://i.loli.net/2019/05/08/5cd29cc73330d.jpg" alt="思路（网图侵删）" title="思路（侵删）" width=""> 
</center>

就不重复造轮子了，请点击[详细思路]{http://www.stepfpga.com/doc/%E5%91%BC%E5%90%B8%E7%81%AF}
### Verilog描述

```verilog
// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Author: halftop
// Github: https://github.com/halftop
// Email: yu.zh@live.com
// Description: LED通过PWM调亮度,实现呼吸灯
// Dependencies: 
// LastEditors: halftop
// Since: 2019-05-08 11:24:52
// LastEditTime: 2019-05-08 16:08:10
// ********************************************************************
// Module Function:呼吸灯
`define SIMULATION;
module pwm_genrate
#(
    parameter CLK_FREQUENCE	= 24,	//MHz
            PWM_PRECISION	= 1,	//us
            PWM_PERIOD		= 1,	//ms
            BREATH_CYCLE	= 2		//s
)
(
    input					clk     ,
    input					rst_n	,
    output	reg				pwm_sig	
);

`ifdef	SIMULATION
localparam	PRECISION_CNT	= CLK_FREQUENCE*PWM_PRECISION,
            PERIOD_CNT		= PWM_PERIOD*10/PWM_PRECISION,
            CYCLE_CNT		= BREATH_CYCLE*5/PWM_PRECISION/PWM_PERIOD,
            PRECISION_WD	= clogb2(PRECISION_CNT),
            PERIOD_WD		= clogb2(PERIOD_CNT),
            CYCLE_WD		= clogb2(CYCLE_CNT);
`else
localparam	PRECISION_CNT	= CLK_FREQUENCE*PWM_PRECISION,
            PERIOD_CNT		= PWM_PERIOD*1000/PWM_PRECISION,
            CYCLE_CNT		= BREATH_CYCLE*500/PWM_PRECISION/PWM_PERIOD,
            PRECISION_WD	= clogb2(PRECISION_CNT),
            PERIOD_WD		= clogb2(PERIOD_CNT),
            CYCLE_WD		= clogb2(CYCLE_CNT);
`endif

reg     [PRECISION_WD-1:0]  cnt_pre;//精度计数
reg     [PERIOD_WD-1:0]     cnt_per;//pwm周期计数
reg     [CYCLE_WD-1:0]      cnt_cyc;//呼吸周期计数
wire                        time_pre;//精度标志
wire                        time_per;//pwm周期标志
wire                        time_cyc;//半个呼吸周期计数
reg                         turn_flag;//默认低亮高灭；1为逐渐变暗，0为逐渐变亮

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_pre <= 'd0;
    end else if (cnt_pre<PRECISION_CNT) begin
        cnt_pre <= cnt_pre + 1'b1;
    end else begin
        cnt_pre <= 'd1;
    end
end
assign time_pre = cnt_pre == PRECISION_CNT;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_per <= 'd0;
    end else if (time_pre) begin
        cnt_per <= (cnt_per<PERIOD_CNT)?(cnt_per+1'b1):1'd1;
    end else begin
        cnt_per <= cnt_per;
    end
end
assign time_per = cnt_per == PERIOD_CNT && time_pre;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_cyc <= 'd0;
    end else if (time_per) begin
        cnt_cyc <= (cnt_cyc<CYCLE_CNT)?(cnt_cyc+1'b1):1'd1;
    end else begin
        cnt_cyc <= cnt_cyc;
    end
end
assign time_cyc = cnt_cyc == CYCLE_CNT && time_per;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        turn_flag <= 1'b0;
    end else if (time_cyc) begin
        turn_flag <= ~turn_flag;
    end else begin
        turn_flag <= turn_flag;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_sig <= 1'b1;
    end else begin
        case (turn_flag)
            1'b0: pwm_sig <= (cnt_per>cnt_cyc)?1'b1:1'b0;
            1'b1: pwm_sig <= (cnt_per<cnt_cyc)?1'b1:1'b0;
            default: pwm_sig <= pwm_sig;
        endcase
    end
end

function integer clogb2 (input integer depth);
    begin
        for(clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
    end
endfunction
endmodule
```

### testbench

```verilog
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
```

### 仿真图

<center>
 <img src="https://i.loli.net/2019/05/08/5cd29e8d9fa40.png" alt="pwm呼吸灯仿真" title="pwm呼吸灯仿真" width="800"> 
</center>