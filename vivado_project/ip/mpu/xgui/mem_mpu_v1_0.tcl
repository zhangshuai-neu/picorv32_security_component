# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MEM_WORDS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MPU_ITEM_LEN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MPU_ITEM_NUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MPU_START_ADDR" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.MEM_WORDS { PARAM_VALUE.MEM_WORDS } {
	# Procedure called to update MEM_WORDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MEM_WORDS { PARAM_VALUE.MEM_WORDS } {
	# Procedure called to validate MEM_WORDS
	return true
}

proc update_PARAM_VALUE.MPU_ITEM_LEN { PARAM_VALUE.MPU_ITEM_LEN } {
	# Procedure called to update MPU_ITEM_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MPU_ITEM_LEN { PARAM_VALUE.MPU_ITEM_LEN } {
	# Procedure called to validate MPU_ITEM_LEN
	return true
}

proc update_PARAM_VALUE.MPU_ITEM_NUM { PARAM_VALUE.MPU_ITEM_NUM } {
	# Procedure called to update MPU_ITEM_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MPU_ITEM_NUM { PARAM_VALUE.MPU_ITEM_NUM } {
	# Procedure called to validate MPU_ITEM_NUM
	return true
}

proc update_PARAM_VALUE.MPU_START_ADDR { PARAM_VALUE.MPU_START_ADDR } {
	# Procedure called to update MPU_START_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MPU_START_ADDR { PARAM_VALUE.MPU_START_ADDR } {
	# Procedure called to validate MPU_START_ADDR
	return true
}


proc update_MODELPARAM_VALUE.MEM_WORDS { MODELPARAM_VALUE.MEM_WORDS PARAM_VALUE.MEM_WORDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MEM_WORDS}] ${MODELPARAM_VALUE.MEM_WORDS}
}

proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.MPU_START_ADDR { MODELPARAM_VALUE.MPU_START_ADDR PARAM_VALUE.MPU_START_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MPU_START_ADDR}] ${MODELPARAM_VALUE.MPU_START_ADDR}
}

proc update_MODELPARAM_VALUE.MPU_ITEM_NUM { MODELPARAM_VALUE.MPU_ITEM_NUM PARAM_VALUE.MPU_ITEM_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MPU_ITEM_NUM}] ${MODELPARAM_VALUE.MPU_ITEM_NUM}
}

proc update_MODELPARAM_VALUE.MPU_ITEM_LEN { MODELPARAM_VALUE.MPU_ITEM_LEN PARAM_VALUE.MPU_ITEM_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MPU_ITEM_LEN}] ${MODELPARAM_VALUE.MPU_ITEM_LEN}
}

