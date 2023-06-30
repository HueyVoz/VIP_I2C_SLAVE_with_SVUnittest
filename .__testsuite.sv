module __testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "__ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  i2c_slave_driver_unit_test i2c_slave_driver_ut();


  //===================================
  // Build
  //===================================
  function void build();
    i2c_slave_driver_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(i2c_slave_driver_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    i2c_slave_driver_ut.run();
    svunit_ts.report();
  endtask

endmodule
