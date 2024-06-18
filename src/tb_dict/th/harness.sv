// +FHDR------------------------------------------------------------
//                 Copyright (c) 2022 GEN_UVM_TB.
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : harness.v
// Author        : 
// Created On    : 
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------


`ifndef __HARNESS_SV__
`define __HARNESS_SV__

import uvm_pkg::*;

`timescale 1ns/1ps

module harness;

logic clk;
logic rst_n;

initial begin
  clk = 0;
  forever begin
    #500ps clk = ~clk;
  end
end

initial begin
  rst_n = 1'b0;
  #100ns;
  rst_n = 1'b1;
end

initial begin
  run_test("sanity_case");
end
// ----------------------------------------------------------------
// AUTO declare and inst
// ----------------------------------------------------------------
/*INF_POSI*/

initial begin
/*CONFIG_DB_POSI*/
end

// ----------------------------------------------------------------
// AUTO declare and inst
// ----------------------------------------------------------------
/*AUTOOUTPUT*/
/*AUTOINPUT*/
/*AUTOLOGIC*/

/*RTL_POSI*/ 

// ----------------------------------------------------------------
// assign
// ----------------------------------------------------------------

endmodule
// Local Variables:
// verilog-auto-inst-param-value:t
// verilog-library-directories:(".")
// verilog-library-extensions:(".v")
// End:

`endif

