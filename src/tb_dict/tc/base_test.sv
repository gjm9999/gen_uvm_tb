// +FHDR------------------------------------------------------------
//                 Copyright (c) 2022 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : base_test.sv
// Author        : 
// Created On    : 
// Last Modified : 2024-06-17 18:11 by gaojiaming
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef BASE_TEST_SV
`define BASE_TEST_SV

class base_test extends uvm_test;

  /*STATE_POSI*/
	
	extern function new(string name = "base_test", uvm_component parent=null);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual task watchdog(uvm_phase phase);

	`uvm_component_utils(base_test)
endclass: base_test

function base_test::new(string name = "base_test", uvm_component parent=null);
	super.new(name, parent);
endfunction: new

function void base_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
  set_report_max_quit_count(5);
  /*CREATE_POSI*/
endfunction: build_phase

function void base_test::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  /*CONNECT_POSI*/
endfunction: connect_phase

function void base_test::report_phase(uvm_phase phase);
	super.report_phase(phase);
endfunction: report_phase

task base_test::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
endtask

task base_test::main_phase(uvm_phase phase); //{{{
  super.main_phase(phase);
  fork
    this.watchdog(phase);
  join_none
  #0;
endtask

task base_test::watchdog(uvm_phase phase);
  phase.raise_objection(this);
	#1000;
	while(1)begin
		bit vr_reached;
		fork: timeout
			begin //normal finish
				phase.phase_done.wait_for_total_count(null, 1);
        #1000;
        phase.phase_done.wait_for_total_count(null, 1);
				vr_reached = 1;
			end
			begin //timeout
				#100000;
				`uvm_fatal("base_test", $psprintf("watchdog timeout(%s_phase)::\n %s", phase.get_name(), phase.phase_done.convert2string()))
			end
      //@other event here
		join_any
		disable timeout;
	
		#100;
		if(vr_reached && phase.phase_done.get_objection_total() == 1)begin
			`uvm_info("watchdog", "watchdog timeout normal reached", UVM_LOW)
			break;
		end
	end
	`uvm_info("base_test", "watchdog(): Finished!", UVM_LOW)
  phase.drop_objection(this);
  #1000;
endtask //}}}

`endif
