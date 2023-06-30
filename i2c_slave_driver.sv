//==============================================================//
//Project: Design Verification IP I2C-Slave                     //
// Author: HuyVNQ                                               //
// Date:  15062023                                              //
//==============================================================//
timeunit 1ns;
class i2c_slave_driver extends uvm_driver#(i2c_slave_transaction);
    `uvm_component_utils(i2c_slave_driver)
    typedef enum {
        I2C_DIR_WRITE = 0,
        I2C_DIR_READ  = 1
    } e_i2c_direction;
    virtual i2c_interface i2c_itf;  
    i2c_slave_cfg i2c_cfg;
    i2c_slave_transaction seq;

    event start_e;
    event stop_e;

    int n_period =0;
    realtime period =0;
    realtime input_clock_period_in_ps;
    int n_high;
    int n_low;
    int n_hld_data_max;
    bit start_detection;
    bit detect_RW;
    logic [6:0] address;
    bit [7:0] data[int];
    bit ack_master = 0; 
    int  num_byte_data_export = 0;


    function new(string name = "i2c_slave_driver",uvm_component parent);
        super.new(name,parent);
    endfunction:new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    if(!uvm_config_db#(virtual i2c_interface)::get(this, " ", "i2c_itf", i2c_itf))
        `uvm_fatal(get_type_name(), "NOT ACCESS!!!")
        seq = i2c_slave_transaction::type_id::create("seq");
        i2c_cfg = i2c_slave_cfg::type_id::create("i2c_cfg");
        void'(i2c_cfg.randomize());
    endfunction:build_phase

    task run_phase(uvm_phase phase);
        e_i2c_direction R_W;
        super.run_phase(phase);
        start_detection =1'b0;
        detect_RW = 1'b0;
        // `uvm_info(get_tpye_name(),"SLAVE RUN PHASE!!",UVM_NONE)
        $display("SLAVE RUN PHASE!!");
        
        fork 
            
             detect_start_condition();    
            begin
                    // detect_start_condition();
                    seq_item_port.get_next_item(seq);
                    caculate_scl_frequency();
                    `uvm_info(get_type_name(),"Start get seq",UVM_NONE)
                    seq.print();
                    wait(start_e.triggered)
                    `uvm_info(get_type_name(),"Start get address",UVM_NONE)
                    get_address();

                    $display("start_get_rw");
                    get_rd_wr(.R_W(R_W));
                    send_ack();
                    case(R_W)  //Read=1||Write=0
                        I2C_DIR_READ: read_command_of_master();
                        I2C_DIR_WRITE: write_command_of_master();
                        default: `uvm_fatal(get_type_name(),$sformatf("UKNOWN SLAVE RD_WR!!"))
                    endcase
                    seq_item_port.item_done();
                    //$display("-------------------",$realtime);
                   detect_stop_condition();

            end
        //   forever detect_stop_condition();

       join
    endtask:run_phase


    task detect_start_condition();
            @(negedge i2c_itf.sda_in);                 
            if (i2c_itf.scl_in === 1'b1) begin
            ->start_e;
        end
        if((start_e.triggered)) begin
            start_detection = 1'b1; //start=1,stop=0
            `uvm_info(get_type_name(),$sformatf("start_detection = %0d",start_detection),UVM_MEDIUM);
            `uvm_info(get_type_name(),"Success detect start condition!",UVM_NONE)
             i2c_itf.bus_state = "detect_start";
        end
    endtask: detect_start_condition

    task detect_stop_condition();
        @(posedge i2c_itf.sda_in);
        if(i2c_itf.scl_in === 1'b1) begin
            ->stop_e;
           
        end
        if(stop_e.triggered) begin
            if(start_detection) begin
              start_detection = 1'b0;
              `uvm_info(get_type_name(),"Success detect stop condition!",UVM_NONE)
              i2c_itf.bus_state = "detect_stop";
            end
        end
    endtask:detect_stop_condition

    task get_address();
        address = '0;
        for(int i = 0 ; i < i2c_cfg.address_num_of_bits ; i++) begin

            @(posedge i2c_itf.scl_in);
            address = {address[5:0],i2c_itf.sda_in};
            $display("At[%0t]_Bit_address[%0d]=%0b",$realtime,i,i2c_itf.sda_in);
            i2c_itf.bus_state = "address";
        end
        $display("num_bit_of_address:%0d",i2c_cfg.address_num_of_bits);
        `uvm_info("Slave address","Address receivered Successful!!",UVM_NONE)
        `uvm_info(get_type_name(),$sformatf("Address=%7b",address),UVM_NONE);
    endtask: get_address

    task get_rd_wr(output e_i2c_direction R_W);
        @(posedge i2c_itf.scl_in);
        R_W = e_i2c_direction'(i2c_itf.sda_in);
        `uvm_info(get_type_name(),$sformatf("Slave_get_bit_read_write:%0d",R_W),UVM_NONE);
        i2c_itf.bus_state = "bit_RW";
        // send_ack();
    endtask:get_rd_wr

    task send_ack();
        time_hold_data();
        i2c_itf.sda_out = 1'b0;//ack=0
       `uvm_info(get_type_name(),$sformatf("slave_send_ack : %0d",i2c_itf.sda_out),UVM_NONE);
       i2c_itf.bus_state = "S_ACK";
        // time_hold_data();
        // i2c_itf.sda_out = 1'b1;//ack=1
        // `uvm_info(get_type_name(),$sformatf("Bit NACK is : %0d",i2c_itf.sda_out),UVM_NONE);

    endtask:send_ack

    task send_nack();
        time_hold_data();
        i2c_itf.sda_out = 1'b1;//ack=1
        `uvm_info(get_type_name(),$sformatf("slave_send_ack : %0d",i2c_itf.sda_out),UVM_NONE);
        i2c_itf.bus_state = "S_NACK";
    endtask:send_nack

    task get_ack_master(output logic ack);
        @(posedge i2c_itf.scl_in);
        ack = i2c_itf.sda_in;
        i2c_itf.bus_state = "salve_get_ack";
    endtask:get_ack_master

    task write_command_of_master();
        logic [7:0] data_in;
        int         num_byte_data_access = 0;
        `uvm_info(get_type_name(), "Slave read data form master", UVM_MEDIUM)
        while(num_byte_data_access <=i2c_cfg.max_byte_write_data_for_nack_en) begin
            data_in = '0;
            repeat(2) wait(i2c_itf.sda_out === 0 ||i2c_itf.sda_out === 1 );
            for(int i = 0 ; i <= 7 ; i++) begin
                @(negedge i2c_itf.scl_in)
                data_in = { data_in[6:0] , i2c_itf.sda_in};
                i2c_itf.bus_state = "data_in";
                `uvm_info(get_type_name(),$sformatf("[%0d] = %8b",i,i2c_itf.sda_in),UVM_NONE);
            end
            data[num_byte_data_access] = data_in;
            `uvm_info(get_type_name(),$sformatf("data[%0d] = %8b",num_byte_data_access,data_in),UVM_NONE);
            if(num_byte_data_access < i2c_cfg.max_byte_write_data_for_nack_en)begin
                send_ack();
            end 
            if(num_byte_data_access == i2c_cfg.max_byte_write_data_for_nack_en) begin
                send_nack();
            end

            
            num_byte_data_access++;
        end
        //send_nack();
        // end

    endtask:write_command_of_master

    task read_command_of_master();
        logic [7:0] data_out = '0;
        
        `uvm_info(get_type_name(),"Slave write data to master ",UVM_MEDIUM)
         //while( ack_master == 1'b0 && num_byte_data_export <= i2c_cfg.max_byte_read_data_for_nack_en ) ;
        //do begin
            while( ack_master == 1'b0 && num_byte_data_export <= i2c_cfg.max_byte_read_data_for_nack_en ) begin
           // `uvm_info(get_type_name(),$sformatf("slave_send_data=%8b",seq.data_out),UVM_NONE);
            `uvm_info(get_type_name(),$sformatf("num_byte_data_export=%0d",num_byte_data_export),UVM_NONE);
            data[num_byte_data_export] = data_out;
            for(int i = 8 ; i  ; i--) begin
            time_hold_data();
                i2c_itf.sda_out <= seq.data_out[i-1];
               
                i2c_itf.bus_state = "data_out";
           //    `uvm_info(get_type_name(),$sformatf("salve_send_data[%0d]=%0d",i,i2c_itf.sda_out),UVM_NONE);
                //`uvm_info(get_type_name(),$sformatf("sda_out[%0d]=%0d",i,seq.data_out[i]),UVM_NONE);
            end
            //i2c_itf.sda_out <= 1'b1;
           wait(i2c_itf.scl_out);
            num_byte_data_export++;
            get_ack_master(ack_master);
            `uvm_info(get_type_name(),$sformatf("Get_ACK=%0d",ack_master),UVM_NONE);
            if(ack_master == 1'b1) break;
        end


     //   while( ack_master == 1'b0 && num_byte_data_export <= i2c_cfg.max_byte_read_data_for_nack_en ) ;
    endtask:read_command_of_master
    //---------------------------------------------//                 
    task time_hold_data();
   // wait(i2c_itf.scl_in==0);
        @(negedge i2c_itf.scl_in);
        repeat(n_hld_data_max) @(posedge i2c_itf.clk);
    endtask:time_hold_data

    task caculate_scl_frequency();
        realtime input_clock_period_in_ps;
        realtime before_t = 0;
        realtime after_t  = 0;
        @(posedge i2c_itf.clk);
            before_t = $realtime;
        @(posedge i2c_itf.clk);
         after_t = $realtime;
        //  $display("before_t  =%t,after_t =%t,after_t-before_t ",before_t,after_t,after_t-before_t);
        input_clock_period_in_ps = (after_t - before_t);
        if (input_clock_period_in_ps == 0) begin
            `uvm_error(get_type_name(), $sformatf("variable input_clock_period_in_ps = %0t", input_clock_period_in_ps)) end
   //         period = period /(10^-9);
            period = 1s/(1000*i2c_cfg.request_frequency_scl_mode);//  toc do standared 100kbs/s
            n_period = (period / input_clock_period_in_ps); // tinh so chu ky so voi chu ky cua system clock
            n_high = (n_period/2);
            n_low  = (n_period/2);
            n_hld_data_max = (i2c_cfg.t_hd_dat_max/input_clock_period_in_ps);
            $display("t_hd_dat_max=%0d",i2c_cfg.t_hd_dat_max);
            $display("freq_scl_mode[%s]=%0d",i2c_cfg.frequency_mode_range,i2c_cfg.request_frequency_scl_mode);

        $display("n_high = %0d", n_high);
        $display("n_low = %0d", n_low);
        $display("n_hold_data= %0d", n_hld_data_max);

        $display("n_period = %0t",n_period);
         $display("input_clock_period_in_ps = %0t",input_clock_period_in_ps);

    endtask:caculate_scl_frequency

endclass
