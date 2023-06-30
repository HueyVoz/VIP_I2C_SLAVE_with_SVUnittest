timeunit 1ns;
class i2c_slave_cfg extends uvm_object;
  realtime t_hd_dat_max;
  typedef enum  { 
    STANDARD_MODE  = 0, // 100kbit/s 
    FAST_MODE      = 1, // 400kbit/s 
    FAST_MODE_PLUS = 2  // 1000 kHz
  } i2c_frequency_mode;
  rand int request_frequency_scl_mode;
  rand int max_byte_read_data_for_nack_en; 
  rand int max_byte_write_data_for_nack_en;
  rand int address_num_of_bits;
   // vary between 100 Kbit/s (standard), 400 Kbit/s (fast), 1 Mbit/s (fast mode plus fm+), and 3.4 Mbit/s (high speed). 
  rand i2c_frequency_mode frequency_mode_range;
  
  `uvm_object_utils_begin(i2c_slave_cfg)
    `uvm_field_int(address_num_of_bits,UVM_ALL_ON)
    `uvm_field_int(max_byte_read_data_for_nack_en,UVM_ALL_ON)
    `uvm_field_int(max_byte_write_data_for_nack_en,UVM_ALL_ON)
    `uvm_field_int(request_frequency_scl_mode, UVM_ALL_ON);
    `uvm_field_enum(i2c_frequency_mode,frequency_mode_range, UVM_ALL_ON)
  `uvm_object_utils_end
function new(string name = "i2c_slave_cfg");
  super.new(name);
endfunction: new
function void post_randomize();
  case(frequency_mode_range)
    STANDARD_MODE: begin
     t_hd_dat_max = 3.45us;
    end
    
    FAST_MODE: begin
      t_hd_dat_max = 0.9us;
    end
    
    FAST_MODE_PLUS: begin
      t_hd_dat_max = 300ns; 
    end
  endcase
endfunction: post_randomize

constraint address_bits_c { address_num_of_bits == 7; }
constraint max_byte_read_data_c{ max_byte_read_data_for_nack_en == 3;}
constraint max_byte_write_data_c{max_byte_write_data_for_nack_en == 3;}
constraint frequency_mode_range_c { frequency_mode_range == STANDARD_MODE;}
constraint request_frequency_scl_mode_c{
  if (frequency_mode_range == STANDARD_MODE)   request_frequency_scl_mode == 100;
  if (frequency_mode_range == FAST_MODE)       request_frequency_scl_mode == 400;
  if (frequency_mode_range == FAST_MODE_PLUS)  request_frequency_scl_mode == 1000;
}   


endclass: i2c_slave_cfg 