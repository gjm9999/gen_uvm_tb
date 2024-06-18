# gen_uvm_tb说明文档

## 前言

客观的说，不同验证工程师所搭建的环境结构差异极大，因此gen_uvm_tb类型的脚本也是五花八门。故而本脚本也不追求完善和充分，只是作为搭建简单的普适性验证环境的工具，降低固定的以及重复性工作带来的时间消耗。

最终追求的目的是，gen_uvm_tb + gen_vum_agent + auto_testbench可以覆盖UT（unit test）和BT（block test）两个层级的功能测试。

## 工程路径

[gen_uvm_tb: 生成uvm仿真环境](https://gitee.com/gjm9999/gen_uvm_tb)

## 更新记录

| 时间        | 更新                                                    | 说明  |
| --------- | ----------------------------------------------------- | --- |
| 2024/6/18 | 1.增加了dut和interface的例化功能<br>2.增加了生成文件功能<br>3.修改了对齐缩进问题 |     |

## 功能列表

1.根据配置表生成env/base_test/harness等验证环境；

2.生成基于VCS的可编译仿真平台；

3.根据选项生成空文件；

## 使用说明

下载脚本于linux工作站后并配置可执行路径后，执行脚本：

```
gen_uvm_tb env_name
```

如果当前目录下有env_name.cfg文件则会直接生成仿真环境，否则会通过gvim新建并打开env_name.cfg配置文件：

```
//======================================================================================================
//position | component_name  | inst_name |     component_type               | create new | connect
//env|base | agent|model|scb | a_scb[2]  | AGENT|MODEL|RAL|SCB|VSQR|RTL|INF | Y|N        |
//======================================================================================================
env        |                 |           |                                  |            | 
//======================================================================================================
base       |                 |           |                                  |            | 
//======================================================================================================
harness    |                 |           |                                  |            | 
//======================================================================================================
```

position：表示某个组件所在的位置，只能选择env/base/harness三者之一；

component_name：组件的名字；

inst_name：组件的例化名，此处可以为数组形式例化；

component_type：组件类型，只能在AGENT|MODEL|RAL|SCB|VSQR|RTL|INF这几种里进行选择，对于AGENT类型需要标明其主动还是从动属性AGENT::UVM_ACTIVE/AGENT::UVM_PASSIVE；

create new：表示是否需要新建该组件，无论该组件例化在哪个位置，均新建于env文件夹；

connect：组件与其他组件的链接关系，因为组件形式千奇百怪所以这里的配置仅为参考，不会体现在环境生成中。

按照需求填写该配置文件后，键入y后生成的环境位于当前目录的env_name文件夹下。

## 使用示例

当前目录下完成配置文件test.cfg如下：

```
//======================================================================================================
//position | component_name  | inst_name |     component_type               | create new | connect
//env|base | agent|model|scb | a_scb[2]  | AGENT|MODEL|RAL|SCB|VSQR|RTL|INF | Y|N        |
//======================================================================================================
env        | a_agent         | a_agt     | AGENT::UVM_ACTIVE                | N          | 
env        | b_agent         | b_agt[4]  | AGENT::UVM_PASSIVE               | N          | 
env        | a_scoreboard    | a_scb     | SCB                              | N          | rm, a_agent.out_fifo.blocking_get_export 
env        | b_scoreboard    | b_scb[4]  | SCB                              | N          | rm, b_agt[i].out_fifo.blocking_get_export
env        | my_rm           | rm        | MODEL                            | Y          | 
env        | rf_vsqr         | rf        | VSQR                             | N          | 
//======================================================================================================
base       | c_model         | c_model   | MODEL                            | N          | 
base       | d_ral_model     | ral       | RAL                              | N          | 
base       | ram_model       | ram       | VSQR                             | N          | 
base       | env             | my_env    | MODEL                            | N          |
//======================================================================================================
harness    | rr_dispatch     | u_dut     | RTL                              | N          | 
harness    | in_inf          | u_in_inf  | INF                              | N          | 
//======================================================================================================
```

键入命令：

```
gen_uvm_tb test
```

之后生成了test文件夹，文件夹结构如下：

```
.
|—— cfg
|   |—— cfg.mk
|   |—— check_fail.pl
|   |—— run.do
|   |—— tb.f
|—— env
|   |—— my_rm.sv
|   |—— test_env.sv
|—— sim
|   |—— Makefile
|—— tc
|   |—— base_test.sv
|   |—— tc.f
|__ th
    |__ harness.sv
```

看一下生成的关键代码以及需要手动修改的部分。

**harness**中的核心部分如下：

```
// ----------------------------------------------------------------
// AUTO declare and inst
// ----------------------------------------------------------------
in_inf       u_in_inf(clk, rst_n);

initial begin
  uvm_config_db#(virtual in_inf)::set(null, "*", "vif", u_in_inf);
end

// ----------------------------------------------------------------
// AUTO declare and inst
// ----------------------------------------------------------------
/*AUTOOUTPUT*/
/*AUTOINPUT*/
/*AUTOLOGIC*/

rr_dispatch #(/*AUTOINSTPARAM*/)
u_dut(/*AUTOINST*/);

// ----------------------------------------------------------------
// assign
// ----------------------------------------------------------------

endmodule
// Local Variables:
// verilog-auto-inst-param-value:t
// verilog-library-directories:(".")
// verilog-library-extensions:(".v")
// End:
```

1. 对于interface需要配置的路径，需要根据实际情况手动配置；

2. RTL的例化借助verilog-mode完成，这是我最喜欢的verilog emacs/vim插件，如果不喜欢这里的生成形式也可以借助其他工具auto_testbench生成DUT的例化和连线；

3. assign区域是interface和wire/logic的互联区域需要手动完成；

harness是有一些取巧的，主要在于推测interface和DUT的互联关系是一件比较麻烦的事情。尽管有一些大力出奇迹的方式，不过我还是觉得哪怕生成之后一样需要花费很多时间去排查和调整，不如就自己来完成吧。

**test_env**的核心代码有如下的部分：

```
class test_env extends uvm_env;

  a_agent      a_agt;
  b_agent      b_agt[4];
  a_scoreboard a_scb;
  b_scoreboard b_scb[4];
  my_rm        rm;
  rf_vsqr      rf;

  extern function new(string name = "test_env", uvm_component parent=null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);

  `uvm_component_utils(test_env)
endclass: test_env
```

令人赏心悦目的缩进与对齐以及部分方法的声明，如果要补充更多的方法就需要自己动手了。其中build_phase函数主体如下：

```
function void test_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  a_agt = a_agent::type_id::create("a_agt", this);
  a_agt.is_active = UVM_ACTIVE;
  for(int i=0;i<4;i=i+1)begin
    b_agt[i] = b_agent::type_id::create($sformatf("b_agt[%0d]", i), this);
    b_agt[i].is_active = UVM_PASSIVE;
  end
  a_scb = a_scoreboard::type_id::create("a_scb", this);
  for(int i=0;i<4;i=i+1)begin
    b_scb[i] = b_scoreboard::type_id::create($sformatf("b_scb[%0d]", i), this);
  end
  rm = my_rm::type_id::create("rm", this);
  rf = rf_vsqr::type_id::create("rf", this);
  uvm_config_db #(uvm_object_wrapper)::set(
    this,
    "rf.main_phase",
    "default_sequence",
    rf_seq::type_id::get()
  );
endfunction: build_phase
```

这部分很大程度是我个人的代码习惯，大家根据实际情况增减修改就好。而connect_phase的部分前面提过，每个组件内部的结构千奇百怪，与其在配置文件里写太多的信息不如大家直接完成这一部分，当然也写了一些提示代码：

```
function void test_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  //like: 
  //rm.inst_port.connect(inst_agt.out_fifo.blocking_get_export);
  //aw_scb.exp_port.connect(rm.aw_fifo.blocking_get_export);
  //aw_scb.act_port.connect(aw_agt.out_fifo.blocking_get_export);
endfunction: connect_phase
```

base_test部分，生成代码和test_env比较接近，只是这里有一个watch_dog结构不需要的在main_phase中注释掉就可以：

```
class base_test extends uvm_test;

  c_model      c_model;
  d_ral_model  ral;
  ram_model    ram;
  env          my_env;

  extern function new(string name = "base_test", uvm_component parent=null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual task watchdog(uvm_phase phase);

  `uvm_component_utils(base_test)
endclass: base_test
```

对于RAL类型的model，会有如下的一些操作，如果不需要注释掉即可：

```
  if(!uvm_config_db #(d_ral_model)::get(this, "", "ral", ral)) begin
    ral = d_ral_model::type_id::create("ral", this);
    ral.build();
    ral.lock_model();
    ral.reset();
  end
  adapter = apb_adapter::type_id::create("adapter", this);
  ral.default_map.set_sequencer(apb_mst.sqr, adapter);
  ral.default_map.set_auto_predict(1);  
```

最后是配置中标注create new = Y的my_rm文件，会固定以此模板生成：

```
// +FHDR------------------------------------------------------------
//                 Copyright (c) 2023 GEN_UVM_TB.
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : my_rm.sv
// Author        : xxx
// Created On    : Tue Jun 18 17:35:46 CST 2024
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __MY_RM_SV__
`define __MY_RM_SV__

class my_rm extends uvm_component;

  //like
  //uvm_blocking_get_port #(inst_transaction)  inst_port;
  //uvm_analysis_port     #(axi_ar_transaction) ar_ap;

  `uvm_component_utils(my_rm);

  extern function new(string name = "my_rm", uvm_component parent=null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual task shutdown_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

endclass: my_rm

function my_rm::new(string name = "my_rm", uvm_component parent=null);
  super.new(name, parent);
endfunction: new

function void my_rm::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction: build_phase

function void my_rm::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase

task my_rm::reset_phase(uvm_phase phase);
  super.reset_phase(phase);;
endtask: reset_phase;

task my_rm::main_phase(uvm_phase phase);
  super.main_phase(phase);;
endtask: main_phase;

task my_rm::shutdown_phase(uvm_phase phase);
  super.shutdown_phase(phase);;
endtask: shutdown_phase;

task my_rm::run_phase(uvm_phase phase);
  super.run_phase(phase);;
endtask: run_phase;

function void my_rm::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction: report_phase

`endif
```

生成文件的结构就是如此，如果需要运行环境还需要修改tb.f文件。
