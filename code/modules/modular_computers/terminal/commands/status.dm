/// Shows status on NTNet
/datum/terminal_command/status
	name = "status"
	man_entry = list(
		"Format: status",
		"Reports network status information.",
		"NOTICE: Requires network operator or admin access."
	)
	pattern = "^status$"
	req_access = list(list(GLOB.access_network, GLOB.access_network_admin))
	skill_needed = SKILL_EXPERIENCED

/datum/terminal_command/status/proper_input_entered(text, mob/user, datum/terminal/terminal)
	if(!terminal.computer.get_ntnet_status())
		return network_error()
	. = list()
	. += "NTnet status: [GLOB.ntnet_global.check_function() ? "ENABLED" : "DISABLED"]"
	. += "Alarm status: [GLOB.ntnet_global.intrusion_detection_enabled ? "ENABLED" : "DISABLED"]"
	if(GLOB.ntnet_global.intrusion_detection_alarm)
		. += "NETWORK INCURSION DETECTED"
