package  i2c_pkg;
 `include"uvm_macros.svh"
 import uvm_pkg::*;
    

   typedef enum {
  	I2C_DIR_WRITE = 0,
  	I2C_DIR_READ  = 1
    } e_i2c_direction;
 // Group: Parameter
    `include "i2c_slave_transaction.sv"
    `include "i2c_slave_sequence.sv"
    `include "i2c_slave_sequencer.sv"
    `include "i2c_slave_config.sv"
    `include "i2c_slave_driver.sv" 
    `include "i2c_monitor.sv"
    //`include "i2c_slave_agent.sv"
    // `include "i2c_score_board.sv"
    // `include "i2c_environment.sv"
endpackage