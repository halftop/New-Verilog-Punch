---
title: Verilog没有葵花宝典——day6（边沿检测）
date: 2019-04-29 16:23:17
tags: [IC,FPGA,Verilog HDL,学习笔记]
published: true
hideInList: false
feature: https://i.loli.net/2019/05/03/5ccb9f5ac0190.jpg
---
## 题目

> 1. 复习verilog语法【选做题】
> - reg和wire的区别
> - 阻塞赋值与非阻塞赋值的区别
> - parameter与define的区别
> - task与function的区别
> 
> 2. 用verilog实现边沿检测电路：上升沿，下降沿，双沿(上升或下降沿)。
> 
> 3. 记录一下第2题中用到的工具，包括工具版本，操作步骤或命令选项，遇到的错误，提示信息等。
<!-- more --> 

- [题目](#题目)
  - [1.1 reg和wire的区别](#11-reg和wire的区别)
    - [驱动( Driving)和赋值( Assigning)](#驱动-driving和赋值-assigning)
  - [1.2 阻塞赋值与非阻塞赋值的区别](#12-阻塞赋值与非阻塞赋值的区别)
  - [1.3 parameter与define的区别](#13-parameter与define的区别)
  - [1.4 task与function的区别](#14-task与function的区别)
  - [2. 用verilog实现边沿检测电路：上升沿，下降沿，双沿(上升或下降沿)。](#2-用verilog实现边沿检测电路上升沿下降沿双沿上升或下降沿)
    - [verilog描述](#verilog描述)
    - [testbench](#testbench)
    - [仿真图](#仿真图)
  - [3. 记录一下第2题中用到的工具，包括工具版本，操作步骤或命令选项，遇到的错误，提示信息等。](#3-记录一下第2题中用到的工具包括工具版本操作步骤或命令选项遇到的错误提示信息等)

### 1.1 reg和wire的区别

在Verilog语言中,有两大变量类型:
- 线网型:表示电路间的物理连线。（有其它类别，这里特指wire）
- 寄存器型: Verilog中的一个抽象的存储数据单元。（有其它类别，这里特指reg）

首先遵守如下的简单规则:
1. 凡是在 always或 initial语句中赋值的变量,一定是寄存器变量;
2. 在 assign中赋值的一定是线网变量。

“线网”变量可以理解为电路模块中的连线,但**“寄存器”并不严格对应于电路上的存储单元**,包括触发器(flip-flop)或锁存器(latch)。

实际上,从语义上来讲,在 Verilog仿真工具对语言仿真的时候,寄存器类型的变量是占用仿真环境的物理内存的,这与C语言中的变量类似。寄存器在被赋值后,便一直保存在内存中,保持该值不变,直到再次对该寄存器变量进行赋值。而线网类型是不占用仿真内存的,它的值是由当前所有驱动该线网的其他变量(可以是寄存器或线网)决定的。这是寄存器和线网最大的区别。

#### 驱动( Driving)和赋值( Assigning)

- 线网是被驱动的,该值不被保持,在任意一个仿真步进上都需要重新计算
- 寄存器是被赋值的,且该值在仿真过程中被保持,直到下一个赋值的出现。

描述两个值的异或，可以采用如下方式：
```v
assign #1 A_XOR=data0^data1;
```
还可以采用如下方式：
```v
reg A_XOR;
always @ (*)
    A_XOR = #1 data0^data1;
```
两种描述的目的是一样的，都是一个异或门。波形图如下图所示。

<center>
 <img src="https://i.loli.net/2019/04/29/5cc6bf6b1f576.png" alt="异或门波形图" title="异或门波形图"> 
</center>

第一种描述方式使用“assign”语句，实际上是连续驱动的过程。也就是说,在任意一个仿真时刻,当前时刻data0和data1相异或的结果决定了1ns以后(语句#1的延时控制)的线网变量A_XOR的值,不管data0和data1变化与否,这个驱动过程一直存在,因此称为**连续驱动**。在仿真器中,线网变量是不占用仿真内存空间的。如上图时序所示,这个驱动过程在任意时刻(包括0、1、2、…9等)都存在。

在第二种描述方式中使用了“always”语句,后面紧跟着一个敏感列表:@(*)。因此,这个语句只有在data0或data1发生变化时才会执行。上图中在时刻2、4和6,该语句都将执行,将data0和data1赋值的结果延时1ns以后赋值给A_XOR变量。在其他时刻,A_XOR变量必须保持。因此,从仿真语义上讲,需要一个存储单元,也可以说是寄存器,来保存A_XOR变量的中间值。所以这个A_XOR变量需要定义为reg类型。

### 1.2 阻塞赋值与非阻塞赋值的区别

两种赋值方式的格式只有符号的差别：`寄存器变量 =/<= 表达式`

如果多个阻塞赋值语句顺序出现在begin..end语句中,前面的语句在执行时,将完全阻塞后面的语句,直到前面语句的赋值完成以后,才会执行下一句的右边表达式计算。例如`begin m=n;n=m;end`语句中,当m被完全赋值以后,在开始执行“n=m”将m的新值付给n。这样执行的结果就是n的初始值不变,而且m与n相等。

与阻塞赋值不同的是,如果多个非阻塞赋值语句顺序出现在begin…end语句中,前面语句的执行,并不会阻塞后面语句的执行。前面语句的计算完成,还没有赋值时,就会执行下一句的右边表达式计算。例如`begin m<=n;n<=m;end`语句中,最后的结果是将m与n值互换了。

### 1.3 parameter与define的区别

parameter声明和作用于模块内部，可以在调用模块时进行参数传递；
define是全局作用，从编译器读到这条指令开始到编译结束都有效，或者遇到`undef命令使之失效。

### 1.4 task与function的区别

这里跟随大众：[请点击这里跳转](https://blog.csdn.net/kobesdu/article/details/39080571)

###  2. 用verilog实现边沿检测电路：上升沿，下降沿，双沿(上升或下降沿)。

#### verilog描述
```v
module edge_det(
    input   clk, rst_n, data,
    output  rise_edge,  //上升沿
    output  fall_edge,  //下降沿
    output  data_edge   //边沿
    );

reg data_r,data_rr;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_r  <= 1'b0;
        data_rr <= 1'b0;     
    end else begin
      data_r    <= data;
      data_rr   <= data_r;
    end
end

assign rise_edge = ( ~data_rr && data_r ) ? 1'b1 : 1'b0 ;
assign fall_edge = ( data_rr && ~data_r ) ? 1'b1 : 1'b0 ;
assign data_edge = ( data_rr^data_r ) ? 1'b1 : 1'b0 ;
endmodule
```

#### testbench
```v
module tb_edge_det;
reg     clk, rst_n, data;
wire    rise_edge;
wire    fall_edge;
wire    data_edge;

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
      @(posedge clk)
	      data = {$random};
    end
    $finish;
end
 /* 
initial begin
    $dumpfile("seq101_tb.vcd");
    $dumpvars();
end
*/
edge_det  edge_det(
    .clk        ( clk       ), 
    .rst_n      ( rst_n     ),
    .data       ( data      ),
    .rise_edge  ( rise_edge ),
    .fall_edge  ( fall_edge ),
    .data_edge  ( data_edge )
    );

endmodule
```

#### 仿真图

<center>
 <img src="https://i.loli.net/2019/04/29/5cc70ba866143.png" alt="边沿检测仿真图" title="边沿检测仿真图" width="800"> 
</center>

### 3. 记录一下第2题中用到的工具，包括工具版本，操作步骤或命令选项，遇到的错误，提示信息等。

VCS2014

把源文件和仿真文件放到同一目录下
`cd`到该目录
```shell
vcs ./edge_det.v ./tb_edge_det.v +v2k -debug_all -l compile.log
```
等待编译完成，`ls`查看产生的可执行文件simv
```shell
./simv -gui &
```
出现图形界面，选中信号，添加波形，运行（快捷键F5），全屏显示（快捷键F），完成。