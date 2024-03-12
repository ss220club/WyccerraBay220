/client/proc/atmosscan()
	set category = "Mapping"
	set name = "Check Piping"
	set background = 1
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(alert("WARNING: This command should not be run on a live server. Do you want to continue?", "Check Piping", "No", "Yes") == "No")
		return

	to_chat(usr, "Checking for disconnected pipes...")

	var/list/all_atmos_machinery = SSmachines.get_machinery_of_type(/obj/machinery/atmospherics)
	for(var/obj/machinery/atmospherics/plumbing as anything in all_atmos_machinery)
		if(istype(plumbing, /obj/machinery/atmospherics/pipe/manifold))
			var/obj/machinery/atmospherics/pipe/manifold/pipe = plumbing
			if (!pipe.node1 || !pipe.node2 || !pipe.node3)
				to_chat(usr, "Unconnected [pipe.name] located at [pipe.x],[pipe.y],[pipe.z] ([get_area(pipe.loc)])")

		else if(istype(plumbing, /obj/machinery/atmospherics/pipe/simple))
			var/obj/machinery/atmospherics/pipe/simple/pipe = plumbing
			if (!pipe.node1 || !pipe.node2)
				to_chat(usr, "Unconnected [pipe.name] located at [pipe.x],[pipe.y],[pipe.z] ([get_area(pipe.loc)])")

		else if (plumbing.nodealert)
			to_chat(usr, "Unconnected [plumbing.name] located at [plumbing.x],[plumbing.y],[plumbing.z] ([get_area(plumbing.loc)])")

	to_chat(usr, "Checking for overlapping pipes...")

	var/list/pipes_by_turfs = list()
	for(var/obj/machinery/atmospherics/pipe as anything in all_atmos_machinery)
		var/turf/pipe_loc = get_turf(pipe)
		if(!pipe_loc)
			stack_trace("Pipe without loc: [pipe] - [ref(pipe)]")
			continue

		var/list/pipes = pipes_by_turfs[ref(pipe_loc)]
		if(!pipes)
			pipes = list()

		pipes += pipe

		pipes_by_turfs[ref(pipe_loc)] += pipes

	var/list/overlapping_pipes_logs = list()
	for(var/turf_ref in pipes_by_turfs)
		var/list/pipes_on_same_turf = pipes_by_turfs[turf_ref]
		if(length(pipes_on_same_turf) <= 1)
			continue

		for(var/cardinal_dir in GLOB.cardinal)
			var/list/connection_types = list()
			for(var/obj/machinery/atmospherics/pipe as anything in pipes_on_same_turf)
				if(!(cardinal_dir & pipe.initialize_directions))
					continue

				var/list/connections_by_dir = connection_types["[pipe.connect_types]"]
				if(!connections_by_dir)
					connections_by_dir = list()
					connection_types["[pipe.connect_types]"] = connections_by_dir

				connections_by_dir |= list(pipe)

			for(var/connection_type in connection_types)
				var/list/duplication_pipes = connection_types[connection_type]
				if(length(duplication_pipes) <= 1)
					continue

				for(var/obj/machinery/atmospherics/pipe as anything in duplication_pipes)
					overlapping_pipes_logs += "Overlapping pipe [pipe.name] detected at [pipe.x], [pipe.y], [pipe.z]"

	if(length(overlapping_pipes_logs))
		to_chat(usr, overlapping_pipes_logs.Join("<br>"))

	to_chat(usr, "Done")

/client/proc/powerdebug()
	set category = "Mapping"
	set name = "Check Power"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	for (var/datum/powernet/PN in SSmachines.powernets)
		if (!PN.nodes || !length(PN.nodes))
			if(PN.cables && (length(PN.cables) > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Powernet with no nodes! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]")

		if (!PN.cables || (length(PN.cables) < 10))
			if(PN.cables && (length(PN.cables) > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]")
