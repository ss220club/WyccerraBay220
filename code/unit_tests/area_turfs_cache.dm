/datum/unit_test/areas_turf_cache_should_be_valid
	name = "AREA: Area turf cache should be valid"


/datum/unit_test/areas_turf_cache_should_be_valid/start_test()
	var/list/turfs_grouped_by_areas = group_turfs_by_areas()

	var/total_non_cached_turfs = 0
	var/total_incorrectly_cached_turfs = 0
	for(var/area/area as anything in turfs_grouped_by_areas)
		var/list/expected_area_turfs = turfs_grouped_by_areas[area]
		var/list/cached_area_turfs = get_area_turfs(area)

		total_non_cached_turfs += check_non_cached_turfs(expected_area_turfs, cached_area_turfs)
		total_incorrectly_cached_turfs += check_incorrectly_cached_turfs(expected_area_turfs, cached_area_turfs)

	if(total_non_cached_turfs || total_incorrectly_cached_turfs)
		fail("Area turf cache is invalid with: total_non_cached_turfs: [total_non_cached_turfs] and total_incorrectly_cached_turfs: [total_incorrectly_cached_turfs]")
	else
		pass("Area turf cache is valid.")

	return TRUE

/datum/unit_test/areas_turf_cache_should_be_valid/proc/group_turfs_by_areas()
	PRIVATE_PROC(TRUE)

	var/list/turfs_by_area = list()
	for(var/turf/turf as anything in block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz)))
		LAZYADDASSOCLIST(turfs_by_area, get_area(turf), turf)

	return turfs_by_area

/datum/unit_test/areas_turf_cache_should_be_valid/proc/check_non_cached_turfs(list/expected_area_turfs, list/cached_area_turfs)
	var/list/area_non_cached_turfs = expected_area_turfs - cached_area_turfs
	var/non_cached_turfs_amount = length(area_non_cached_turfs)
	if(!non_cached_turfs_amount)
		return 0

	for(var/turf/non_cached_turf as anything in area_non_cached_turfs)
		log_bad("Non cached turf detected: [log_info_line(non_cached_turf)] in area: [log_info_line(get_area(non_cached_turf))]")

	return non_cached_turfs_amount

/datum/unit_test/areas_turf_cache_should_be_valid/proc/check_incorrectly_cached_turfs(list/expected_area_turfs, list/cached_area_turfs)
	var/list/area_incorrectly_cached_turfs = cached_area_turfs - expected_area_turfs
	var/incorrectly_cached_turfs = length(area_incorrectly_cached_turfs)
	if(!incorrectly_cached_turfs)
		return 0

	for(var/turf/incorrectly_cached_turf as anything in area_incorrectly_cached_turfs)
		log_bad("Incorrectly cached turf detected: [log_info_line(incorrectly_cached_turf)] in area: [log_info_line(get_area(incorrectly_cached_turf))]")

	return incorrectly_cached_turfs
