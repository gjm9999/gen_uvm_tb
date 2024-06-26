# gen_uvm_tb

## Preface

Objectively speaking, the environmental structures built by different verification engineers vary greatly, hence scripts of the gen_uvm_tb type are also diverse. Therefore, this script does not aim for perfection and completeness; it merely serves as a tool for building a simple, universal verification environment, reducing the time consumption brought by fixed and repetitive work.

The ultimate goal pursued is that gen_uvm_tb + gen_vum_agent + auto_testbench can cover the functional testing of both the UT (unit test) and BT (block test) levels.

## Project Path

[gen_uvm_tb: Generate UVM Simulation Environment](https://gitee.com/gjm9999/gen_uvm_tb)

## Update Log

| Date      | Update                                                                                                                           | Description |
| --------- | -------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| 2024/6/18 | 1. Added instantiation of dut and interface<br>2. Added file generation function<br>3. Modified alignment and indentation issues |             |

## Feature List

1. Generate verification environments such as env/base_test/harness based on configuration tables;

2. Generate a compilable simulation platform based on VCS;

3. Generate empty files based on options;

## Usage Instructions

After downloading the script to a Linux workstation and setting the executable path, run the script:

```
gen_uvm_tb env_name
```

If there is an env_name.cfg file in the current directory, it will directly generate the simulation environment; otherwise, it will create and open the env_name.cfg configuration file with gvim:

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

1. position: Indicates the location of a component, which can only be one of env/base/harness;

2. component_name: The name of the component;

3. inst_name: The instantiation name of the component, which can be instantiated in an array form here;

4. component_type: The type of the component, which can only be selected from AGENT|MODEL|RAL|SCB|VSQR|RTL|INF, for the AGENT type, it is necessary to indicate whether it is an active or passive attribute AGENT::UVM_ACTIVE/AGENT::UVM_PASSIVE;

5. create new: Indicates whether a new component needs to be created, regardless of where the component is instantiated, it is newly created in the env folder;

6. connect: The connection relationship between the component and other components, because the form of the components is various, so the configuration here is only for reference and will not be reflected in the environment generation.

Fill in this configuration file according to the requirements, and after typing y, the generated environment will be located in the env_name folder in the current directory.

## Usage Example

The configuration file test.cfg in the current directory is as follows:

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

Type the command:
    gen_uvm_tb test

Afterwards, the test folder is generated, and the folder structure is as follows:

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
    |—— harness.sv
```

Take a look at the key code and the parts that need to be modified manually.

The core part of the **harness** is as follows:

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

1. For the paths that need to be configured for the interface, they need to be manually configured according to the actual situation;

2. The instantiation of RTL is completed with the help of verilog-mode, which is my favorite Verilog emacs/vim plugin. If you don't like the generated form here, you can also use other tools like auto_testbench to generate the instantiation and wiring of DUT;

3. The assign area is the interconnection area between the interface and wire/logic, which needs to be manually completed.

The harness is a bit tricky, mainly because guessing the interconnection relationship between the interface and DUT is quite troublesome. Although there are some powerful ways, I still think that even after generation, it still takes a lot of time to check and adjust, it might as well be done by oneself.

The core code of **test_env** has the following parts:

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

The pleasing indentation and alignment, as well as the declaration of some methods, need to be done by yourself if you want to add more methods. The main body of the build_phase function is as follows:

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

This part is largely my personal coding habit, and everyone can add or modify according to the actual situation. The part of connect_phase mentioned before, the internal structure of each component is various, it is better to directly complete this part instead of writing too much information in the configuration file, of course, some hint code is also written:

```
function void test_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  //like: 
  //rm.inst_port.connect(inst_agt.out_fifo.blocking_get_export);
  //aw_scb.exp_port.connect(rm.aw_fifo.blocking_get_export);
  //aw_scb.act_port.connect(aw_agt.out_fifo.blocking_get_export);
endfunction: connect_phase
```

For the base_test part, the generated code is similar to test_env, but there is an unnecessary watchdog structure here that can be commented out in the main_phase:

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

For the RAL type of model, there are the following operations, if not needed, just comment it out:

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

Finally, for the my_rm file marked as create new = Y in the configuration, it will be generated with this template:

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

The structure of the generated file is just like this, if you need to run the environment, you also need to modify the tb.f file.
