interface i2c_interface(
                  input bit clk,
                  inout tri1  scl,
                  inout tri1 sda);
//timeunit 1ns/1ps;
    logic scl_out;
    logic sda_out;
    logic sda_in;
    logic scl_in;
    logic [255:0] bus_state;
    assign sda = sda_out ? 1'bz : sda_out;
    assign sda_in =sda;
    assign scl = scl_out ? 1'bz : scl_out;
    assign scl_in =scl;
    
endinterface:i2c_interface


