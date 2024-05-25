###Make file to re-create the project and synthesize it from sources
pynq_z1_rev1: _setup_pynq_z1_rev1 _create_project

pynq_z1_rev2: _setup_pynq_z1_rev2 _create_project

pynq_z2_rev1: _setup_pynq_z2_rev1 _create_project

_setup_pynq_z1_rev1:
	$(eval LINE=$(shell grep -m 1 -n pynq_z1_rev1 build_proj.tcl | cut -d: -f 1))
	$(eval LLINE=$(shell echo $$(($(LINE)+10))))
	@echo "Enabeling Pynq Z1 Rev 1"
	@sed "$(LINE),$(LLINE) s/-value \"0\"/-value \"1\"/" build_proj.tcl > build.tcl
#@echo "From line $(LINE) to line $(LLINE)"

_setup_pynq_z1_rev2:
	$(eval LINE=$(shell grep -m 1 -n pynq_z1_rev2 build_proj.tcl | cut -d: -f 1))
	$(eval LLINE=$(shell echo $$(($(LINE)+10))))
	@echo "Enabeling Pynq Z1 Rev 2"
	@sed "$(LINE),$(LLINE) s/-value \"0\"/-value \"1\"/" build_proj.tcl > build.tcl

_setup_pynq_z2_rev1:
	$(eval LINE=$(shell grep -m 1 -n pynq_z2_rev1 build_proj.tcl | cut -d: -f 1))
	$(eval LLINE=$(shell echo $$(($(LINE)+10))))
	@echo "Enabeling Pynq Z1 Rev 1"
	@sed "$(LINE),$(LLINE) s/-value \"0\"/-value \"1\"/" build_proj.tcl > build.tcl

_create_project:
	vivado -mode batch -source build.tcl
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
	rm -f build.tcl
	rm -rf pynq_controller/
	rm -rf NA
	rm -rf NONE

