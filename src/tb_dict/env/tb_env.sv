// +FHDR------------------------------------------------------------
//                 Copyright (c) 2022 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : tb_env.sv
// Author        : 
// Created On    : 
// Last Modified : 2023-11-29 11:27 by ICer
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __TB_ENV_SV__
`define __TB_ENV_SV__

class tb_env extends uvm_env;

  /*STATE_POSI*/

	extern function new(string name = "tb_env", uvm_component parent=null);
	extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);

	`uvm_component_utils(tb_env)
endclass: tb_env

function tb_env::new(string name = "tb_env", uvm_component parent=null);
	super.new(name, parent);
endfunction: new

function void tb_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
  /*CREATE_POSI*/
endfunction: build_phase

function void tb_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  /*CONNECT_POSI*/
endfunction: connect_phase

task tb_env::reset_phase(uvm_phase phase);
  super.reset_phase(phase);
endtask: reset_phase

task tb_env::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
endtask: configure_phase

task tb_env::main_phase(uvm_phase phase);
  super.main_phase(phase);
endtask: main_phase

function void tb_env::report_phase(uvm_phase phase);
  super.report_phase(phase);
endfunction: report_phase
`endif
