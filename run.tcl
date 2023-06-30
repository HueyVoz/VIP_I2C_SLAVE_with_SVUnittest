vlog -l compile.log  -f .svunit.f +define+SVUNIT_VERSION=unreleased +define+RUN_SVUNIT_WITH_UVM ; vsim -c -lib work  -l run.log testrunner
vsim -novopt testrunner
add wave -position insertpoint sim:/testrunner/__ts/i2c_slave_driver_ut/i2c_itf/*
#add wave -position insertpoint sim:/testrunner/__ts/i2c_slave_driver_ut/i2c_itf/drv_cb/*
run -all