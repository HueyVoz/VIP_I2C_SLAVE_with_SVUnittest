
`include "uvm_macros.svh"
import uvm_pkg::*;
class i2c_cfg extends uvm_object;

  
  typedef enum  { 
      STANDARD_MODE  = 0, // 100kbit/s 
      FAST_MODE      = 1, // 400kbit/s 
      FAST_MODE_PLUS = 2  // 1000 kHz
  } i2c_frequency_mode;
  realtime t_hd_sta_min; //minimum hold time of a repeated start. after this period,the first clock pulse is generated
  realtime t_su_sta_min; // minimum set-up time for a repeated start condition
  realtime t_su_sto_min; // minimun setup time for stop condition
  realtime t_buf_min; // minimum time bus must be free between a stop and start condition
  realtime t_hd_data_max;

  rand int address_num_of_bits;
  rand i2c_frequency_mode frequency_mode;

  function new(string name = "i2c_cfg");
      super.new(name);
  endfunction: new

   `uvm_object_utils_begin(i2c_cfg)
      `uvm_field_enum(i2c_frequency_mode, frequency_mode , UVM_ALL_ON)
      `uvm_field_int(address_num_of_bits, UVM_ALL_ON)
    `uvm_object_utils_end

   constraint address_num_of_bits_c{ soft address_num_of_bits == 7   ;}
   constraint i2c_frequency_mode_c { frequency_mode == STANDARD_MODE ;}
   extern function  void post_randomize();

endclass: i2c_cfg

function void i2c_cfg::post_randomize();
string s = "";
  case(frequency_mode)
     STANDARD_MODE:begin
       t_hd_sta_min  = 4.0us;
       t_su_sta_min  = 4.7us;
       t_su_sto_min  = 4.0ns;
       t_hd_data_max = 3.45us;
       t_buf_min     = 4.7us;
     end

     FAST_MODE:begin
       t_hd_sta_min  = 0.6s;
       t_su_sta_min  = 0.6us;
       t_su_sto_min = 0.6ns;
       t_buf_min    = 1.3us;
     end

     FAST_MODE_PLUS: begin
      t_hd_sta_min       = 0.26us;
      t_su_sta_min       = 0.26us;
      t_su_sto_min       = 0.26us;
      t_buf_min          = 0.5us;
     end
    default: `uvm_fatal(get_type_name(), $sformatf("illegal mode %s", frequency_mode.name()) )
  endcase
   s = "i2c bus timing values:\n";
   s = {s, "--------------------------------------\n"};
   s = { s, $sformatf("t_hd_sta_min = t\n", t_hd_sta_min )};
   s = { s, $sformatf("t_su_sta_min = t\n",  t_su_sta_min )};
   s = { s, $sformatf("t_su_sto_min = t\n", t_su_sto_min  )};
   s = { s, $sformatf("t_buf_min  = t\n",  t_buf_min )};

   `uvm_info(get_type_name(), "s", UVM_FULL)
endfunction:post_randomize

// `endif