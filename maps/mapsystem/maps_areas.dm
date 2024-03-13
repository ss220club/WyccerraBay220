/datum/map
	/*
		Areas where crew members are considered to have safely left the station.
		Defaults to all area types on the admin levels if left empty
	*/
	var/list/post_round_safe_areas = list()

	/// Saferoom area types
	var/list/saferoom_area_types = list()

/datum/map/setup_map()
	..()
	if(!length(post_round_safe_areas))
		for(var/area/A as anything in GLOB.areas)
			if(isspace(A))
				continue
			if(A.z && (A.z in admin_levels))
				post_round_safe_areas += A.type

/datum/map/proc/bolt_saferooms()
	var/list/saferoom_areas = list()
	for(var/atype in types_of_real_list(saferoom_area_types))
		saferoom_areas += locate(atype)

	if(!length(saferoom_areas))
		return

	var/list/area_refs_set = get_area_refs_set(saferoom_areas)
	for(var/obj/machinery/door/airlock/vault/bolted/vault_to_lock as anything in SSmachines.get_machinery_of_type(/obj/machinery/door/airlock/vault/bolted))
		if(vault_to_lock.locked)
			continue

		if(!area_refs_set[ref(get_area(vault_to_lock))])
			continue

		vault_to_lock.lock()

/datum/map/proc/unbolt_saferooms()
	var/list/saferoom_areas = list()
	for(var/atype in types_of_real_list(saferoom_area_types))
		saferoom_areas += locate(atype)

	if(!length(saferoom_areas))
		return

	var/list/area_refs_set = get_area_refs_set(saferoom_areas)
	for(var/obj/machinery/door/airlock/vault/bolted/vault_to_unlock as anything in SSmachines.get_machinery_of_type(/obj/machinery/door/airlock/vault/bolted))
		if(!vault_to_unlock.locked)
			continue

		if(!area_refs_set[ref(get_area(vault_to_unlock))])
			continue

		vault_to_unlock.unlock()
