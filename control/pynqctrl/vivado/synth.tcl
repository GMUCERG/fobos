
open_project ./pynq_controller/pynq_controller.xpr

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
