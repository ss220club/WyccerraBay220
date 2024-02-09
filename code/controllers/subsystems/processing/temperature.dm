PROCESSING_SUBSYSTEM_DEF(temperature)
	name = "Temperature"
	priority = SS_PRIORITY_TEMPERATURE
	wait = 5 SECONDS
	process_proc = type_proc_ref(/atom, ProcessAtomTemperature)
