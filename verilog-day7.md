---
title: Verilog没有葵花宝典——day7（串并转换）
date: 2019-05-02 16:04:47
tags: [FPGA,Verilog HDL,学习笔记]
published: true
hideInList: false
feature: https://i.loli.net/2019/05/03/5ccb9ecb61930.jpg
---
## 题目

> 1. 复习verilog语法【选做题】
>
> 文件操作fopen fdisplay fwrite fclose
>
> 生成随机数 random
>
> 初始化 readmemh readmemb
>
> finish stop
>
> 2. 用verilog实现串并变换。
>
> mode 0 ：串行输入data_in[0]，并行输出data_out[3:0]
> mode 1 ：并行输入data_in[3:0]，串行输出data_out[0]
> mode 2 ：并行输入data_in[3:0]，并行输出data_out[3:0]，延迟1个时钟周期
> mode 3 ：并行输入data_in[3:0]，并行反序输出data_out[3:0]，延迟1个时钟周期并且交换bit
>
> 附加要求【选做】
> 将输入输出的位宽做成参数化
>
> 3. 记录一下第2题中用到的工具，包括工具版本，操作步骤或命令选项，遇到的错误，提示信息等。比较一下，与昨天的记录有何相同，有何不同。

<!-- more --> 

- [题目](#题目)
	- [1.复习verilog语法](#1复习verilog语法)
	- [2. 用verilog实现串并变换。【选做】 将输入输出的位宽做成参数化](#2-用verilog实现串并变换选做-将输入输出的位宽做成参数化)
	- [3. 记录一下第2题中用到的工具。。。。。。](#3-记录一下第2题中用到的工具)

### 1.复习verilog语法

- 文件操作fopen fdisplay fwrite fclose

	```verilog
	integer fileunder;
	fileunder = $fopen("FileName");//打开文件，返回一个整型，会清空文件
	$fdisplay(fileunder,"%d",mumber);//写入操作，写完换行
	$fwrite(fileunder,"%d",mumber);//写入操作，写完不换行
	$fclose(fileunder);//关闭文件
	```

- 生成随机数random

	每次调用`$random`任务时，它返回一个32位带符号的随机整数。将`$random`放入{}内，可以得到非负整数。`$random(seed)`中的seed是一个整数，用于指出随机数的取值范围。

	```verilog
	rand = $random % 60;//给出了一个范围在－59到59之间的随机数。
	rand = {$random} % 60;//通过位并接操作产生一个值在0到59之间的数。
	rand = min+{$random} % (max-min+1);//产生一个在min, max之间随机数的例子。
	```

- 初始化 readmemh readmemb

	把文本文件的数据读到存储器阵列中，以对存储器阵列完成初始化。

	```verilog
	$readmemb("<数据文件名>",<存储器名>);
	$readmemb("<数据文件名>",<存储器名>,<起始地址>);
	$readmemb("<数据文件名>",<存储器名>,<起始地址>,<终止地址>);
	
	$readmemh("<数据文件名>",<存储器名>);
	$readmemh("<数据文件名>",<存储器名>,<起始地址>);
	$readmemh("<数据文件名>",<存储器名>,<起始地址>,<终止地址>);
	
	$readmemb中要求数据必须为二进制，$readmemh要求数据必须为十六进制
	```

- finish stop

	`$stop`：用于在仿真时，暂停仿真。运行到`$stop`的时候，仿真会暂停；此时可以在命令行输入run继续运行仿真。

	`$finish`：仿真停止。运行到`$finish`的时候，仿真停止退出，此时不可以再继续运行

### 2. 用verilog实现串并变换。【选做】 将输入输出的位宽做成参数化

借鉴了部分代码，用Vivado+modelsim仿了一下，功能没有问题，但是觉得写的一般。期待其他小伙伴的答案。

```verilog
module s_p_conver
#(
	parameter	WIDTH	=	4
)
(
	input						clk			,
	input						rst_n		,
	input		[WIDTH-1:0]		data_in		,
	output	reg	[WIDTH-1:0]		data_out	,
	input		[1:0]			mode		
);

localparam CNT_WIDTH = clogb2(WIDTH);

reg	[WIDTH-1:0]	data_out_r;

reg	[CNT_WIDTH-1:0]	cnt;
reg   [1:0] mode_r;
wire change;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
      mode_r <= 2'b00;
    else 
      mode_r <= mode;
end
assign change = (mode_r ^ mode)? 1'b1: 1'b0;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
      cnt <= 'd0;
    else if(change == 1'b1)
      cnt <= 'd0;
    else if(mode[1] == 1'b0) begin
		case (mode[0])
          1'b0: if(cnt == WIDTH) cnt <= 'd1;else cnt <= cnt + 1'b1;
          1'b1: if(cnt == WIDTH-1) cnt <= 'd0;else cnt <= cnt + 1'b1;
			default: cnt <= cnt;
		endcase
	end
	else
		cnt <= cnt;
end
//serial_parallel_convertion
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		data_out_r <= 'd0;
	end else begin:s_p
		integer i;
		case (mode)
			2'b00: begin
				for (i = WIDTH-1; i>0; i=i-1) begin
					data_out_r[i] <= data_out_r[i-1];
				end
				data_out_r[0] <= data_in[0];
			end
			2'b01: begin
              if(cnt == 'd0)
              data_out_r <= data_in;
              else
              data_out_r <= {1'b0,data_out_r[WIDTH-1:1]};
			end
			2'b10: begin
				/* for (i = 0; i<=WIDTH-1; i=i+1) begin
					data_out_r[i] <= data_in[i];
				end */
				data_out_r <= data_in;
			end
			2'b11: begin
				for (i = 0; i<=WIDTH-1; i=i+1) begin
					data_out_r[WIDTH-1-i] <= data_in[i];
				end
			end
			default: data_out_r <= data_out_r;
		endcase
	end
end
//output
always @(*) begin
	case (mode)
        2'b00: data_out = (cnt == 'd1) ? data_out_r : data_out;//latch
		2'b01: data_out = data_out_r;
		default: data_out = data_out_r;
	endcase
end

function integer clogb2 (input integer depth);
	begin
      for(clogb2=0; depth>0; clogb2=clogb2+1)
		depth = depth >> 1;
	end
endfunction

endmodule
```

### 3. 记录一下第2题中用到的工具。。。。。。

这次使用vivado2017.4+modelsim调试。