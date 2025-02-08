## Get command line arguments
set fpga [lindex $argv 0]
puts "fpga:"
puts $fpga

set target_type [lindex $argv 1]
puts "target_type:"
puts $target_type

set target_name [lindex $argv 2]
puts "target_name:"
puts $target_name

set bit_file [lindex $argv 3]
puts "file:"
puts $bit_file

#####################################################################
open_hw_manager
connect_hw_server -url localhost:3121 -allow_non_jtag
current_hw_target [get_hw_targets *$target_type$target_name]
set_property PARAM.FREQUENCY 6000000 [get_hw_targets *$target_type$target_name]
open_hw_target
set_property PROGRAM.FILE $bit_file [get_hw_devices $fpga]
current_hw_device [get_hw_devices $fpga]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $fpga] 0]

set_property PROBES.FILE {} [get_hw_devices $fpga]
set_property FULL_PROBES.FILE {} [get_hw_devices $fpga]
set_property PROGRAM.FILE $bit_file [get_hw_devices $fpga]
program_hw_devices [get_hw_devices $fpga]
refresh_hw_device [lindex [get_hw_device $fpga] 0]
