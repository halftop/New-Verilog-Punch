---
title: Verilog没有葵花宝典——day3（标准单元库）
date: 2019-04-24 21:32:31
tags: [IC,学习笔记]
published: true
hideInList: false
feature: https://i.loli.net/2019/05/03/5ccba0d941f6a.jpg
---
### 题目

>1. 了解目录结构：与前端相关的比如文档(doc)，仿真模型(verilog/vhdl)，标准单元库(synopsys/symbols)。
>2. 阅读文档transition time, propagation delay等参数的定义。
>3. 阅读文档Power Dissipation/Calculation的描述。
>4. 阅读文档Delay calculation的描述。
>5. 提供了哪些类型的cell？
>6. Verilog文件中包含了哪些信息？
<!-- more -->

<!-- TOC -->

- [题目](#题目)
  - [2. 阅读文档transition time, propagation delay等参数的定义。](#2-阅读文档transition-time-propagation-delay等参数的定义)
  - [3. 阅读文档Power Dissipation/Calculation的描述。](#3-阅读文档power-dissipationcalculation的描述)
  - [4. 阅读文档Delay calculation的描述。](#4-阅读文档delay-calculation的描述)
  - [5. 提供了哪些类型的cell？](#5-提供了哪些类型的cell)
  - [6. Verilog文件中包含了哪些信息？](#6-verilog文件中包含了哪些信息)

<!-- /TOC -->
今天的答案基本靠抄（流下了没有知识的眼泪）。

#### 2. 阅读文档transition time, propagation delay等参数的定义。
transition time（转化时间）：信号从10% Vdd变化到90% Vdd的时间，包括上升时间和下降时间。

<center>
    <img src="https://i.loli.net/2019/04/25/5cc1d290ac0ef.jpg" alt="transition time" title="transition time" >
</center>

propagation delay（传播延时）：输入信号变化到超过50%Vdd与输出信号变化到超过50%Vdd的时间间隔。

<center>
    <img src="https://i.loli.net/2019/04/25/5cc1d2aa0b781.jpg" alt="propagation delay" title="propagation delay" >
</center>

#### 3. 阅读文档Power Dissipation/Calculation的描述。
Power Dissipation(功耗，功率损耗)取决于电源电压、工作频率、内部电容和输出负载，并提供计算公式：
$$
P_{\mathrm{avg}}=\sum_{n=1}^{x}\left(E_{i n} \bullet f_{i n}\right)+\sum_{n=1}^{y}\left(C_{o n} \bullet V d d^{2} \bullet \frac{1}{2} f_{o n}\right)+E_{o s} \bullet f_{o 1}
$$
参数定义见其文档**Power Calculation**一节。

#### 4. 阅读文档Delay calculation的描述。
总传播延时的估算公式
$$
t_{\mathrm{TPD}}=\quad\left(\mathrm{K}_{\mathrm{Process}}\right) \cdot\left[1+\left(\mathrm{K}_{\mathrm{Volt}} \cdot \Delta \mathrm{Vdd}\right)\right] \cdot\left[1+\left(\mathrm{K}_{\mathrm{Temp}} \cdot \Delta \mathrm{T}\right)\right] \cdot \mathrm{t}_{\mathrm{typical}}
$$
参数定义见其文档**Delay Calculation**一节。

#### 5. 提供了哪些类型的cell？

Special Cells：Antenna-Fix Cell、NWELL and Substrate Tie Cell、Fill Cells、Low-Power (XL) Cells、TIEHI/LO Cells、Delay Cells。

Base Cells：全加器、与门、与或门、BUF、D触发器、延迟、反相器、选择器、与非门、或非门、三态门、异或门、同或门等等。

#### 6. Verilog文件中包含了哪些信息？
粗略地看了一下
有cell的输入、输出端口定义，延迟参数和路径延迟信息以及时序参数（比如说建立时间、保持时间）信息。这些应该都能和文档里的参数对应上。
