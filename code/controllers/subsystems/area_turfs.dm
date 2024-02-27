SUBSYSTEM_DEF(area_turfs)
	name = "Area Turfs"
	wait = 1
	flags = SS_NO_INIT
	/// List of areas enqued to be updated
	var/static/list/queue = list()

/datum/controller/subsystem/area_turfs/fire(resumed)
	if(!resumed)
		queue = GLOB.areas.Copy()

	while(length(queue))
		var/area/area_to_clear = queue[length(queue)]
		var/list/turfs_to_uncontain_by_z = area_to_clear.turfs_to_uncontain_by_z

		var/z_level_to_clear = min(length(area_to_clear.contained_turfs_by_z), length(turfs_to_uncontain_by_z))
		for(var/z_level in 1 to z_level_to_clear)
			var/list/turfs_to_uncontain = turfs_to_uncontain_by_z[z_level]
			if(!length(turfs_to_uncontain))
				continue

			var/list/area_contained_turfs = area_to_clear.contained_turfs_by_z[z_level]
			for(var/turf_index in 1 to length(turfs_to_uncontain))
				area_contained_turfs -= turfs_to_uncontain[turf_index]
				if(MC_TICK_CHECK)
					turfs_to_uncontain.Cut(1, turf_index + 1)
					return

		LIST_DEC(queue)
