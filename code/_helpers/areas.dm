/*
	List generation helpers
*/
/proc/get_filtered_areas(list/predicates = list(GLOBAL_PROC_REF(is_area_with_turf)))
	RETURN_TYPE(/list)
	. = list()
	if(!predicates)
		return
	if(!islist(predicates))
		predicates = list(predicates)
	for(var/area/A as anything in GLOB.areas)
		if(all_predicates_true(list(A), predicates))
			. += A

/proc/get_area_turfs(area/A, list/predicates)
	RETURN_TYPE(/list)
	A = istype(A) ? A : locate(A)
	if(!A)
		return list()

	if(!A.has_turfs())
		return list()

	var/list/all_area_turfs = A.get_turfs_from_all_z()
	if(!length(predicates))
		return all_area_turfs

	var/list/area_turfs = list()
	for(var/turf/T as anything in all_area_turfs)
		if(all_predicates_true(list(T), predicates))
			area_turfs += T

	return area_turfs

/proc/get_turfs_in_areas(list/areas, list/predicates)
	if(!islist(areas))
		areas = list(areas)

	var/list/turfs = list()
	for(var/area/current_area as anything in areas)
		var/list/current_area_turfs = get_area_turfs(current_area, predicates)
		if(!current_area_turfs)
			continue

		turfs |= current_area_turfs

	return turfs

/// Returns set of area refs as: area_ref => TRUE
/// For fast area checking
/proc/get_area_refs_set(list/areas)
	var/list/area_refs_set = list()
	for(var/area/single_area as anything in areas)
		area_refs_set[ref(single_area)] = TRUE

	return area_refs_set

/proc/get_subarea_turfs(area/A, list/predicates)
	RETURN_TYPE(/list)
	. = list()
	A = istype(A) ? A.type : A
	if(!ispath(A))
		return

	for(var/sub_area_type in typesof(A))
		var/area/sub_area = locate(sub_area_type)
		if(!sub_area.has_turfs())
			continue

		var/list/all_area_turfs = sub_area.get_turfs_from_all_z()
		if(!length(predicates))
			. += all_area_turfs

		for(var/turf/T as anything in all_area_turfs)
			if(all_predicates_true(list(T), predicates))
				. += T

/proc/group_areas_by_name(list/predicates)
	RETURN_TYPE(/list)
	. = list()
	for(var/area/A in get_filtered_areas(predicates))
		group_by(., A.name, A)

/proc/group_areas_by_z_level(list/predicates)
	RETURN_TYPE(/list)
	. = list()
	for(var/area/A in get_filtered_areas(predicates))
		group_by(., pad_left(num2text(A.z), 3, "0"), A)

/*
	Pick helpers
*/
/proc/pick_subarea_turf(areatype, list/predicates)
	RETURN_TYPE(/turf)
	var/list/turfs = get_subarea_turfs(areatype, predicates)
	if(LAZYLEN(turfs))
		return pick(turfs)

/proc/pick_area_turf(areatype, list/predicates)
	RETURN_TYPE(/turf)
	var/list/turfs = get_area_turfs(areatype, predicates)
	if(length(turfs))
		return pick(turfs)

/proc/pick_area(list/predicates)
	RETURN_TYPE(/area)
	var/list/areas = get_filtered_areas(predicates)
	if(LAZYLEN(areas))
		. = pick(areas)

/proc/pick_area_and_turf(list/area_predicates, list/turf_predicates)
	RETURN_TYPE(/turf)
	var/list/areas = get_filtered_areas(area_predicates)
	// We loop over all area candidates, until we finally get a valid turf or run out of areas
	while(!. && length(areas))
		var/area/A = pick_n_take(areas)
		. = pick_area_turf(A, turf_predicates)

/proc/pick_area_turf_in_connected_z_levels(list/area_predicates, list/turf_predicates, z_level)
	RETURN_TYPE(/turf)
	area_predicates = area_predicates.Copy()

	var/z_levels = GetConnectedZlevels(z_level)
	area_predicates[GLOBAL_PROC_REF(area_belongs_to_zlevels)] = z_levels
	return pick_area_and_turf(area_predicates, turf_predicates)

/proc/pick_area_turf_in_single_z_level(list/area_predicates, list/turf_predicates, z_level)
	RETURN_TYPE(/turf)
	area_predicates = area_predicates.Copy()
	area_predicates[GLOBAL_PROC_REF(area_belongs_to_zlevels)] = list(z_level)
	return pick_area_and_turf(area_predicates, turf_predicates)

/*
	Predicate Helpers
*/
/proc/area_belongs_to_zlevels(area/A, list/z_levels)
	return A && (A.z in z_levels)

/proc/is_station_area(area/A)
	return A && (isStationLevel(A.z))

/proc/is_contact_area(area/A)
	return A && (isContactLevel(A.z))

/proc/is_player_area(area/A)
	return A && (isPlayerLevel(A.z))

/proc/is_not_space_area(area/A)
	. = !istype(A,/area/space)

/proc/is_not_shuttle_area(area/A)
	. = !istype(A,/area/shuttle)

/proc/is_area_with_turf(area/A)
	return A && (isnum(A.x))

/proc/is_area_without_turf(area/A)
	. = !is_area_with_turf(A)

/proc/is_maint_area(area/A)
	. = istype(A,/area/maintenance)

/proc/is_not_maint_area(area/A)
	. = !is_maint_area(A)

/proc/is_coherent_area(area/A)
	return !is_type_in_list(A, GLOB.using_map.area_coherency_test_exempt_areas)

GLOBAL_LIST_INIT(is_station_but_not_space_or_shuttle_area, list(GLOBAL_PROC_REF(is_station_area), GLOBAL_PROC_REF(is_not_space_area), GLOBAL_PROC_REF(is_not_shuttle_area)))

GLOBAL_LIST_INIT(is_contact_but_not_space_or_shuttle_area, list(GLOBAL_PROC_REF(is_contact_area), GLOBAL_PROC_REF(is_not_space_area), GLOBAL_PROC_REF(is_not_shuttle_area)))

GLOBAL_LIST_INIT(is_player_but_not_space_or_shuttle_area, list(GLOBAL_PROC_REF(is_player_area), GLOBAL_PROC_REF(is_not_space_area), GLOBAL_PROC_REF(is_not_shuttle_area)))

GLOBAL_LIST_INIT(is_station_area, list(GLOBAL_PROC_REF(is_station_area)))

GLOBAL_LIST_INIT(is_station_and_maint_area, list(GLOBAL_PROC_REF(is_station_area), GLOBAL_PROC_REF(is_maint_area)))

GLOBAL_LIST_INIT(is_station_but_not_maint_area, list(GLOBAL_PROC_REF(is_station_area), GLOBAL_PROC_REF(is_not_maint_area)))

/*
	Misc Helpers
*/
#define teleportlocs area_repository.get_areas_by_name_and_coords(GLOB.is_player_but_not_space_or_shuttle_area)
#define stationlocs area_repository.get_areas_by_name(GLOB.is_player_but_not_space_or_shuttle_area)
#define wizteleportlocs area_repository.get_areas_by_name(GLOB.is_station_area)
#define maintlocs area_repository.get_areas_by_name(GLOB.is_station_and_maint_area)
#define wizportallocs area_repository.get_areas_by_name(GLOB.is_station_but_not_space_or_shuttle_area)
