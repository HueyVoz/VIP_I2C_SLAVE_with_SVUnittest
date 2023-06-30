class i2c_slave_sequence extends uvm_sequence#(i2c_slave_transaction);
    `uvm_object_utils(i2c_slave_sequence)
    function new(string name  = " i2c_slave_sequence");
        super.new(name);
    endfunction

    i2c_slave_transaction seq;

    task body();
        repeat(20) begin
            seq = i2c_slave_transaction::type_id::create("seq");
            start_item(seq);
                assert(seq.randomize());
            finish_item(seq);
        end
    endtask:body
endclass: i2c_slave_sequence