 import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_slave_transaction extends uvm_sequence_item;
    rand logic [7:0]     data_out;
    rand bit ACK_out;
  `uvm_object_utils_begin (i2c_slave_transaction)
  `uvm_field_int(data_out,UVM_ALL_ON)
  `uvm_field_int(ACK_out,UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "i2c_slave_transaction");
    super.new(name);

  endfunction
endclass:i2c_slave_transaction
