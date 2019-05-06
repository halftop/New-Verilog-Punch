---
title: Verilog没有葵花宝典——day5（时序逻辑）
date: 2019-04-26 16:34:48
tags: [Verilog HDL,FPGA,IC,学习笔记]
published: true
hideInList: false
feature: https://i.loli.net/2019/05/03/5ccba0745769c.jpg
---
## 题目

> 1. dff和latch有什么区别。
> 2. 什么是同步电路和异步电路。
> 3. 什么是setup time和 hold time。
> 4. 设计一个101序列检测器。要画出状态转移图，写verilog，并仿真测试。

<!-- more -->

- [题目](#题目)
  - [1. dff和latch有什么区别。](#1-dff和latch有什么区别)
  - [2. 什么是同步电路和异步电路。](#2-什么是同步电路和异步电路)
  - [3. 什么是setup time和 hold time。](#3-什么是setup-time和-hold-time)
  - [4. 设计一个101序列检测器。要画出状态转移图，写verilog，并仿真测试。](#4-设计一个101序列检测器要画出状态转移图写verilog并仿真测试)
    - [状态转移图](#状态转移图)
    - [verilog描述](#verilog描述)
    - [testbench](#testbench)
    - [仿真结果](#仿真结果)


### 1. dff和latch有什么区别。
都是时序逻辑，输出不但同当前的输入相关还同上一状态的输出相关。

1、latch由电平触发，非同步控制。在使能信号有效时latch相当于通路，在使能信号无效时latch保持输出状态。DFF由时钟沿触发，同步控制。

2、latch容易产生毛刺（glitch），DFF则不易产生毛刺。

3、如果使用门电路来搭建latch和DFF，则latch消耗的门资源比DFF要少，这是latch比DFF优越的地方。所以，在ASIC中使用 latch的集成度比DFF高，但在FPGA中正好相反，因为FPGA中没有标准的latch单元，但有DFF单元，一个LATCH需要多个LE才能实现。

4、latch将静态时序分析变得极为复杂。

<center>
    <img src="https://i.loli.net/2019/04/26/5cc31e0a462a2.png" alt="D锁存器和D触发器的输出波形图" title="D锁存器和D触发器的输出波形图">
</center>

上图所示为D锁存器和D触发器输出端随输入信号变化的波形图( Waveform diagram)。由图中可见,输入信号D在$t_a$时刻以前,D锁存器和D触发器输出端随输入信号变化的波形相同;在t时刻,CP=1期间D发生了变化,D锁存器的输出随着输入信号的变化而变化,D触发器则是在下一个时钟到来后输出状态才发生改变。这是由于触发器不具有传输透明性(Transparency),即触发器输入端发生变化并不会同步引起其输出端发生变化。触发器输出端的变化仅受控制输入(时钟)信号或异步置位复位信号的控制。在通常情况下,除了输入信号在CP=1期间发生变化以外,锁存器和触发器的输出响应是相同的。
### 2. 什么是同步电路和异步电路。

**同步电路** ：各时钟端连在一起，并接在统一的系统时钟端。只有当时钟边沿到来时，电路的状态才会改变。改变后的状态一直保持到下一个时钟的到来，在此期间无论外部的信号如何变化，状态表中的每个状态都是稳定的。

**异步电路** : 电路中没有统一的时钟，电路状态可以由外部输入的变化直接引起。

### 3. 什么是setup time和 hold time。

**建立时间（setup time）** 是指在触发器的时钟信号上升沿到来以前，数据稳定不变的最小时间，如果建立时间不够，数据将不能在这个时钟上升沿被打入触发器；

**保持时间（hold time）** 是指在触发器的时钟信号上升沿到来以后，数据稳定不变的最小时间，如果保持时间不够，数据同样不能被打入触发器。

### 4. 设计一个101序列检测器。要画出状态转移图，写verilog，并仿真测试。

#### 状态转移图

<center>
    <img src="https://i.loli.net/2019/04/26/5cc318f6ed952.png" alt="状态转移" title="状态转移" width="500">
</center>

#### verilog描述
```v
module test29(
input clk, rst_n, data,
output reg flag_101
    );
parameter   ST0 = 4'b0001,
            ST1 = 4'b0010,
            ST2 = 4'b0100,
            ST3 = 4'b1000;

reg [3:0] c_st;
reg [3:0] n_st;
//FSM-1
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    c_st <= ST0;
  end else begin
    c_st <= n_st;
  end
end
//FSM-2
always @(*) begin
  case (c_st)
    ST0: n_st = data ? ST1 : ST0;
    ST1: n_st = data ? ST1 : ST2;
    ST2: n_st = data ? ST3 : ST0;
    ST3: n_st = data ? ST1 : ST2;
    default: n_st = ST0;
  endcase
end
//FSM-3
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    flag_101 <= 1'b0;
  end else begin
    case (n_st)
      ST3: flag_101 <= 1'b1;
      ST0,ST1,ST2: flag_101 <= 1'b0;
      default: flag_101 <= 1'b0;
    endcase
  end
end
endmodule
```

#### testbench

```v
module tb29(    );
reg     clk, rst_n, data;
wire    flag_101;

  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  
  initial begin
    rst_n = 1'b0;
    #22 rst_n = 1'b1;
  end

  initial begin
    repeat(100)begin
      @(negedge clk)
	      data = {$random};
    end
    $finish;
  end
  
/*   initial begin
    $dumpfile("seq101_tb.vcd");
    $dumpvars();
  end */

test29 test29(
    .clk        (clk     ), 
    .rst_n      (rst_n   ), 
    .data       (data    ),
    .flag_101   (flag_101)
    );
endmodule
```
#### 仿真结果

<center>
    <img src="https://i.loli.net/2019/04/26/5cc31a11654c1.png" alt="全加器计数" title="全加器计数" width="600">
</center>