#define ALLOWED_LOOSE_TURFS 100

SUBSYSTEM_DEF(area_turfs)
	name = "Area Turfs"
	flags = SS_NO_INIT
	runlevels = RUNLEVELS_PREGAME|RUNLEVELS_GAME
	/// List of areas enqued to be updated
	var/static/list/queue = list()
	/// List of areas marked for clearing
	var/static/list/area/marked_for_clearing = list()

/datum/controller/subsystem/area_turfs/UpdateStat(text)
	var/turfs_to_uncontain = 0
	for(var/area/marked_for_clearing as anything in marked_for_clearing)
		for(var/z_level in marked_for_clearing.turfs_to_uncontain_by_z)
			turfs_to_uncontain += length(marked_for_clearing.turfs_to_uncontain_by_z[z_level])

	. = ..("Queue: [length(queue)] | To Uncontain: [turfs_to_uncontain]")

/datum/controller/subsystem/area_turfs/fire(resumed)
	if(!resumed)
		queue = GLOB.areas.Copy()

	while(length(queue))
		var/area/to_check = queue[length(queue)]
		for(var/z_level in to_check.turfs_to_uncontain_by_z)
			var/list/to_uncontain = LAZYACCESS(to_check.turfs_to_uncontain_by_z, z_level)
			if(LAZYLEN(to_uncontain) <= ALLOWED_LOOSE_TURFS)
				continue

			marked_for_clearing |= to_check
			break

		LIST_DEC(queue)
		if(MC_TICK_CHECK)
			return

	while(length(marked_for_clearing))
		var/area/area_to_clear = marked_for_clearing[length(marked_for_clearing)]
		for(var/z_level in area_to_clear.contained_turfs_by_z)
			var/list/turfs_to_uncontain = LAZYACCESS(area_to_clear.turfs_to_uncontain_by_z, z_level)
			if(!LAZYLEN(turfs_to_uncontain))
				continue

			var/list/contained_turfs = LAZYACCESS(area_to_clear.contained_turfs_by_z, z_level)
			for(var/turf_index in 1 to length(turfs_to_uncontain))
				contained_turfs -= turfs_to_uncontain[turf_index]
				if(MC_TICK_CHECK)
					turfs_to_uncontain.Cut(1, turf_index + 1)
					return

			LAZYREMOVE(area_to_clear.turfs_to_uncontain_by_z, z_level)
			if(!length(contained_turfs))
				area_to_clear.contained_turfs_by_z -= z_level

		LIST_DEC(marked_for_clearing)

#undef ALLOWED_LOOSE_TURFS
