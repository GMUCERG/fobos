

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "openadc_interface_light" "NUM_INSTANCES" "DEVICE_ID"  "C_S_CFG_AXI_BASEADDR" "C_S_CFG_AXI_HIGHADDR"
}
