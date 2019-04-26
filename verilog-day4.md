---
title: Verilog没有葵花宝典——day4（组合逻辑）
date: 2019-04-25 09:52:28
tags: [IC,Verilog HDL,学习笔记]
published: true
hideInList: false
feature: https://ws1.sinaimg.cn/mw690/7f79daaely1g2endkdglxj22bc1tuqv5.jpg
---
## 题目
>1. 什么是竞争和冒险？
>2. 设计一个2-4译码器。
>3. 输入一个8bit数，输出其中1的个数。如果只能使用1bit全加器，最少需要几个？
>4. 如果一个标准单元库只有三个cell：2输入mux(o = s ？a ：b;)，TIEH(输出常数1)，TIEL(输出常数0)，如何实现以下功能？
>    1. 反相器inv
>    2. 缓冲器buffer 
>    3. 两输入与门and2
>    4. 两输入或门or2
>    5. 四输入的mux  mux4
>    6. 一位全加器 fa
<!-- more --> 

### 1. 什么是竞争和冒险？

这个题以前做过，自己总结了一篇比较详细的内容：[通过做verilog99题的第11题学习竞争与冒险](https://halftop.github.io/post/verilog99_11)

**冒险**：在信号传输与状态变换时会发生的延迟（Delay）。事实上，由于这些延迟，当输入信号发生变化时，其输出信号不能立即跟随输入信号的变化而变化，而是经过一段过渡时间后才能达到原先所期望的状态，从而可能产生瞬间的错误输出，造成逻辑功能的瞬时紊乱。这种现象被称为逻辑电路的“***冒险现象***”（Hazard），简称“险象”。

产生冒险的原因——**竞争**：在组合逻辑电路中，输入信号的变化传输到电路各级门时，在时间上有先有后，这种先后所形成的时间差称为竞争（Competition）。

### 2. 设计一个2-4译码器。

#### verilog描述
```v
module decoder2_4(
	input		[1:0]	a,
	output	reg	[3:0]	b
);
always @ (*)
	case(a)
		2'b00:b=4'b1110;
		2'b01:b=4'b1101;
		2'b10:b=4'b1011;
		2'b11:b=4'b0111;
		default:b=4'b1111;
	endcase
endmodule
```

#### 门级电路图
电路图在下面，因为反相器、与非门和或非门是cmos集成电路的基本单元，所以选择了这样的实现形式。
<figure class="half">
	<img src="https://ws1.sinaimg.cn/large/7f79daaely1g1oepelcemj21341d0djp.jpg" alt="卡诺图化简" title="卡诺图化简" width="220">
	<img src="https://ws3.sinaimg.cn/large/7f79daaely1g1oeqjjlauj20640570sn.jpg" alt="2-4译码器门级电路图" title="2-4译码器门级电路图">
</figure>

### 3. 输入一个8bit数，输出其中1的个数。如果只能使用1bit全加器，最少需要几个？

#### verilog描述
```v
module test_20(
	input 	[7:0]	i_data,
	output	[3:0]	o_count
);
assign o_count = ((i_data[0] + i_data[1] + i_data[2]) + (i_data[3] + i_data[4] + i_data[5]) + i_data[6]) + i_data[7];

endmodule
```

#### 本题至少使用几个1bit全加器

下图使用八个1来说明。[参考链接](https://forum.allaboutcircuits.com/threads/count-number-of-logic-1s-in-7-bit-number.49821/)

<center>
    <img src="https://i.loli.net/2019/04/25/5cc1bb25dcb89.png" alt="全加器计数" title="全加器计数" width="400">
</center>

### 4. 使用2输入mux(o = s ？a ：b;)，TIEH(输出常数1)，TIEL(输出常数0)实现以下功能。

<center>
    <img src="https://ws1.sinaimg.cn/large/7f79daaely1g2eqsji2fgj22dr1onh34.jpg" alt="4.1-4.5" title="4.1-4.5" width="500">
</center>

<center>
    <img src="https://ws1.sinaimg.cn/large/7f79daaely1g2equ4tnj6j22dr1on4dn.jpg" alt="4.6" title="4.6" width="500">
</center>

```v
module mux2com(
    input       a,
    input       b,
    input       c,
    input       d,

    input       s0,s1,

    output      f_inv,
    output      f_buffer,
    output      f_and2,
    output      f_or2,
    output      f_mux4,

    output      adder_sum,
    output      adder_carry
    );

assign f_inv = a ? 0 : 1;

assign f_buffer = a ? 1 : 0;

assign f_and2 = a ? b : 0;

assign f_or2 = a ? 1 : b;

assign f_mux4 = s1 ? (s0?a:b) : (s0?c:d);

assign adder_sum = (a?(b?0:1):b)?(c?0:1):c;     
assign adder_carry = (c?b:0)?1:((c?a:0)?1:(b?a:0));
endmodule
```