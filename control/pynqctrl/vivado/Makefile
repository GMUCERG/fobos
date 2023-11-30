###Make file to re-create the project and synthesize it from sources
create_project:
	vivado -mode batch -source build_proj.tcl
	cd pynq_controller/pynq_controller.srcs/sources_1/imports/hdl; \
	rm ctrl_top_wrapper.vhd; \
	ln -s ../../../../../src/ctrl_top_wrapper.vhd .
synth: 
	vivado -mode batch -source synth.tcl
	cp pynq_controller/pynq_controller.gen/sources_1/bd/ctrl_top/hw_handoff/ctrl_top.hwh pynq_ctrl.hwh
	cp pynq_controller/pynq_controller.runs/impl_1/ctrl_top_wrapper.bit pynq_ctrl.bit

### removes vivado log and jou files ###
clean:
	rm -f *.log *.jou
	rm -f build_proj_modified.tcl
	rm -rf pynq_controller/
	rm -rf NA
