timeunit 1ns;
  import uvm_pkg::*;
  import svunit_uvm_mock_pkg::*;
  `include "uvm_macros.svh"
  `include "C:/Users/ADMIN/Documents/HUY/08.Unit_test/svunit_master/svunit_base/svunit_defines.svh"
  `include "i2c_interface.sv"
  `include "i2c_slave_transaction.sv"
  `include "i2c_slave_sequence.sv"
  `include "i2c_slave_config.sv"
  `include "i2c_slave_driver.sv"
  

  // Mock sequencer for sending transactions to the driver
  class mock_sequencer extends uvm_sequencer#(i2c_slave_transaction);
    `uvm_sequencer_utils(mock_sequencer)
    function new(input string name,uvm_component parent);
      super.new(name,parent);
    endfunction
  endclass
  // Mock sequence to run on the mock sequencer.
  class mock_sequence extends uvm_sequence #(i2c_slave_transaction);
    `uvm_sequence_utils(mock_sequence, mock_sequencer)
  endclass
  //====================================//

  module i2c_slave_driver_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "i2c_slave_driver_ut";
    svunit_testcase svunit_ut;

    ////////////////////////////////////
    i2c_slave_driver slave_drv;
    mock_sequencer sequencer;
    i2c_slave_cfg i2c_cfg;
    bit clk;
    logic address;
    always #25 clk=~clk;
    i2c_interface i2c_itf(.clk(clk),.scl(scl),.sda(sda));    


    //===================================
    // Build
    //===================================
    function void build();
      svunit_ut = new(name);
      slave_drv = i2c_slave_driver::type_id::create("slave_drv",null);
      slave_drv.i2c_itf = i2c_itf;
      uvm_config_db#(virtual i2c_interface)::set(null,"*","i2c_itf",i2c_itf);
      // Connect transaction port to the driver
      sequencer = mock_sequencer::type_id::create("sequencer", null);
      i2c_cfg = i2c_slave_cfg::type_id::create("i2c_cfg");
      slave_drv.seq_item_port.connect(sequencer.seq_item_export);
      slave_drv.seq_item_port.resolve_bindings();
    endfunction


    //===================================
    // Setup for running the Unit Tests
    //===================================
    task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
      clk = 0;
      @(posedge clk);
      i2c_itf.scl_out <= 1;
      i2c_itf.sda_out <= 1; 
    endtask


    //===================================
    // Here we deconstruct anything we 
    // need after running the Unit Tests
    //=============================
    task teardown();
      svunit_ut.teardown();
    endtask

    `SVUNIT_TESTS_BEGIN
    //**********TEST1************//
    `SVTEST(i2c_itf_connected)

    @(posedge clk);

    $display("scl %0d",i2c_itf.scl);
    $display("sda %0d",i2c_itf.sda);
    `FAIL_IF(slave_drv.i2c_itf == null);
    i2c_itf.bus_state = "connect_itf";
    `SVTEST_END
    //**********TEST2************//
  
       `SVTEST(Test_read_data_from_master_with_nack)
            mock_sequence m_seq;
            i2c_slave_transaction seq;
            seq = new();
            m_seq = new();
            fork: run
              slave_drv.run_phase(null);
              begin
                sequencer.wait_for_grant(m_seq);
                void'(seq.randomize());
                sequencer.send_request(m_seq, seq);
              end
            join_none
           send_start_condition ();
            fork
            repeat(46) creat_scl();
               run2();
           join
            send_stop_condition();
    `SVTEST_END
    //**********TEST3************//
  `SVTEST(Test_write_data_from_master)
      bit start_detection = 0;
      mock_sequence m_seq;
      i2c_slave_transaction seq;
        seq = new();
        m_seq = new();
      fork: run
        slave_drv.run_phase(null);
        begin
        sequencer.wait_for_grant(m_seq);
        void'(seq.randomize());
        sequencer.send_request(m_seq, seq);
        end
      join_none
      send_start_condition ();
      fork
        repeat(45) creat_scl();
        run1();
        join
      send_stop_condition();
    `SVTEST_END
    // // **********TEST4************//
    `SVTEST(Test_read_data_from_master)
            mock_sequence m_seq;
            i2c_slave_transaction seq;
            seq = new();
            m_seq = new();
            fork: run
              slave_drv.run_phase(null);
              begin
                sequencer.wait_for_grant(m_seq);
                void'(seq.randomize());
                sequencer.send_request(m_seq, seq);
              end
            join_none
           send_start_condition ();
            fork
            repeat(46) creat_scl();
               run3();
           join
            send_stop_condition();
    `SVTEST_END
    `SVUNIT_TESTS_END
    //********RUN1***********//
    task run1();
      send_addr();
      send_bit_write();
      //master_get_ack();
      repeat(5) begin
          master_get_ack(); 
          master_send_byte_data(8'b10101010);
      end
    endtask
  //********RUN2***********//
    task run2();
      begin
        
      send_addr();
      send_bit_read();
      master_get_ack();
      repeat(4)   get_data_fr_slave();
    
      end
      
    endtask
  //********RUN3***********//
  task run3();
      begin
      send_addr();
      send_bit_read();
      master_get_ack();
      repeat(4)  begin
    
        get_data_fr_slave_1();
      end
      end
  endtask
  //--------------------------------//
    task send_start_condition();
        i2c_itf.scl_out = 1;
        i2c_itf.sda_out = 1; 
      repeat(40) @(posedge clk);
        i2c_itf.scl_out = 1;
        i2c_itf.sda_out = 0; 
      repeat(40)@(posedge clk);
        i2c_itf.sda_out = 0; 
        i2c_itf.scl_out = 0; 
      @(posedge clk);    
    endtask
    task send_stop_condition();   

      repeat(20) @(posedge clk);
      i2c_itf.scl_out = 0;
      i2c_itf.sda_out = 0; 

      repeat(20) @(posedge clk);
      i2c_itf.scl_out = 1;
      repeat(20) @(posedge clk);
      i2c_itf.sda_out = 1; 
      repeat(20) @(posedge clk);
      i2c_itf.scl_out = 1;
      i2c_itf.sda_out = 1;  
    endtask
    task send_addr();
      repeat(3)create_sda();
    endtask
    task send_bit_write();
      time_hold_data();
      i2c_itf.sda_out <=0;
      `uvm_info("SVUnit_test",$sformatf("Master_send_bit_read_write:%0d",i2c_itf.sda_out),UVM_NONE);
    endtask

    task send_bit_read();
      time_hold_data();
      i2c_itf.sda_out =1;
          `uvm_info("SVUnit_test",$sformatf("Master_send_bit_read_write:%0d",i2c_itf.sda_out),UVM_NONE);
    endtask
    task master_send_byte_data(input logic [7:0] a);
      for(int i = 0; i <=7;i++) begin
           
        // @(negedge scl);
          repeat(190) @(posedge clk);
          i2c_itf.sda_out <= a[i];
      end
    endtask
    task creat_scl();

      i2c_itf.scl_out <= 0;
      repeat(slave_drv.n_low) @(negedge i2c_itf.clk);

      i2c_itf.scl_out =~i2c_itf.scl_out;
      repeat(slave_drv.n_high) @(negedge i2c_itf.clk);
    endtask
    task create_sda();
      time_hold_data();
      i2c_itf.sda_out <= 1;
      time_hold_data();
      i2c_itf.sda_out <= 0;
    endtask   


    task get_data_fr_slave();
          if(slave_drv.ack_master == 1) begin
          end else 
          begin
            repeat(8) begin
                
                @(negedge scl);
                `uvm_info("SVUnit_test",$sformatf("Get_data_fr_slave=%0d",sda),UVM_NONE);
            end
            if(slave_drv.num_byte_data_export < 3)begin
                master_send_ack();
                $display("test11=%0t",$realtime);
            end else begin
              master_send_nack();
              $display("test22=%0t",$realtime);
            end
          end
    endtask
    task get_data_fr_slave_1();
          if(slave_drv.ack_master == 1) begin
            
          end else 
          begin
            repeat(8) begin
                @(negedge scl);
                `uvm_info("SVUnit_test",$sformatf("Get_data_fr_slave=%0d",sda),UVM_NONE);
            end
            master_send_nack();
            $display("test22=%0t",$realtime);
          end
    endtask
    task master_get_ack();
        repeat(2)@(posedge scl);
        `uvm_info("SVUnit_test",$sformatf("master_get_ACK=%0d",sda),UVM_NONE);
    endtask
    task master_send_ack();
          time_hold_data();
          i2c_itf.sda_out = 0;
          `uvm_info("SVUnit_test",$sformatf("Send_bit_ack:%0b",i2c_itf.sda_out),UVM_NONE);
    endtask
    task master_send_nack();
          time_hold_data();
          i2c_itf.sda_out = 1;
          `uvm_info("SVUnit_test",$sformatf("Send_bit_ack:%0b",i2c_itf.sda_out),UVM_NONE);
    endtask
    task time_hold_data();
          @(negedge scl);
          repeat(69) @(posedge clk);
    endtask:time_hold_data
  endmodule

