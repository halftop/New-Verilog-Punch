---
title: Verilog没有葵花宝典——day8（计数器）
date: 2019-05-06 15:27:23
tags: [IC,FPGA,Verilog HDL,学习笔记]
published: true
hideInList: false
feature: https://upload.wikimedia.org/wikipedia/commons/e/e8/JohnsonCounter2.png
---
## 题目

> 1. 用verilog实现一个4bit二进制计数器。
> a) 异步复位
> b) 同步复位
> input clk, rst_n; 
> output [3:0] o_cnt;
> 2. 用verilog实现4bit约翰逊(Johnson)计数器。
> 3. 用verilog实现4bit环形计数器：复位有效时输出0001，复位释放后依次输出0010，0100，1000，0001，0010...
> 4. 比较一下以上三种计数器的特点。
> 5. 记录1,2,3题目使用的工具，操作步骤，以及出现的错误和提示信息。

<!-- more --> 

<!-- TOC -->

- [题目](#题目)
  - [第一题](#第一题)
    - [Verilog描述](#verilog描述)
    - [vcs仿真结果](#vcs仿真结果)
  - [第二题](#第二题)
    - [Verilog描述](#verilog描述-1)
    - [VCS仿真](#vcs仿真)
  - [第三题](#第三题)
    - [Verilog描述](#verilog描述-2)
    - [VCS仿真](#vcs仿真-1)
    - [testbench](#testbench)
  - [第四题](#第四题)
  - [第五题](#第五题)

<!-- /TOC -->
### 第一题

**用verilog实现一个4bit二进制计数器。**

#### Verilog描述

```verilog
module cnt2s(
    input clk, rst_n,
    output [3:0] o_cnt
    );
    reg [3:0] cnt;
//异步复位
/* always @ (posedge clk or negedge rst_n) begin
    if ( !rst_n )
        cnt <= 4'b0000;
    else if ( cnt == 4'b1111 )
        cnt <= 4'b0000;
    else
        cnt <= cnt + 1'b1;
end */
//同步复位
always @ (posedge clk) begin
    if ( !rst_n )
        cnt <= 4'b0000;
    else if ( cnt == 4'b1111 )
        cnt <= 4'b0000;
    else
        cnt <= cnt + 1'b1;
end

assign o_cnt = cnt;

endmodule
```

#### vcs仿真结果

- 同步复位

<center>
 <img src="https://i.loli.net/2019/05/06/5ccfee4f90f5a.png" alt="二进制计数器同步复位" title="二进制计数器同步复位" width=""> 
</center>
- 异步复位

<center>
 <img src="https://i.loli.net/2019/05/06/5ccfefa529217.png" alt="二进制计数器异步复位" title="二进制计数器异步复位" width=""> 
</center>

### 第二题

**用verilog实现4bit约翰逊(Johnson)计数器。**

#### Verilog描述

```verilog
module cnt_johnson(
    input clk, rst_n,
    output [3:0] o_cnt
    );
    reg [3:0] cnt;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cnt <= 4'b0000;
	end else begin
		cnt <= {~cnt[0],cnt[3:1]};
	end
end

assign o_cnt = cnt;

endmodule
```

#### VCS仿真

<center>
 <img src="https://i.loli.net/2019/05/06/5ccfef4744096.png" alt="Johnson计数器" title="Johnson计数器" width=""> 
</center>

### 第三题

**用verilog实现4bit环形计数器**

#### Verilog描述

```verilog
module cnt_ring(
	input clk, rst_n,
    output [3:0] o_cnt
);
reg [3:0] cnt;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cnt <= 4'b0001;
	end else begin
		cnt <= {cnt[0],cnt[3:1]};
	end
end

assign o_cnt = cnt;
endmodule
```

#### VCS仿真

<center>
 <img src="https://i.loli.net/2019/05/06/5ccff040014cf.png" alt="4bit环形计数器" title="4bit环形计数器" width=""> 
</center>
#### testbench

三个计数器均用此tb：

```verilog
module tb_cnt4(    );
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

cnt**  cnt4(
    .clk    (clk  ),
    .rst_n  (rst_n),
    .o_cnt  (o_cnt)
    );
endmodule
```



### 第四题

**比较一下以上三种计数器的特点。**

- 环形计数器：n比特的环形计数器会循环n次，每计数一次的汉明距离是2。一般来说，环形计数器中循环的数据是只有一个比特为1的数据，因此任一时刻只有一个触发器输出为高电位。
- 约翰逊记数器：是修改过的环形计数器，最后一个触发器的输出反相后再接到第一个触发器。n比特的环形计数器会循环2n次，每计数一次的[汉明距离](https://zh.wikipedia.org/wiki/汉明距离)是1。电路译码是不会产生竞争冒险且译码电路简单。
- 二进制计数器：n位二进制计数器(n为触发器的个数)有$2^n$个状态。

参考链接：[维基百科](<https://zh.wikipedia.org/wiki/计数器#约翰逊记数器>)

另附一份更进一步解决前两种计数器自启动问题的[文档](https://wenku.baidu.com/view/0b116b23c1c708a1294a446e.html)

### 第五题

编辑器：VS Code，vim

仿真工具：VCS

```shell
vcs ./tb.v ./cnt.v +v2k -debug_all -R -gui
```

