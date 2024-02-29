/// For the area_contents list unit test
/// Allows us to know our area without needing to preassign it
/// Sorry for the mess
/turf/var/area/in_contents_of

/datum/unit_test/areas_turf_cache_should_be_valid
	name = "AREA: Area turf cache should be valid"
	async = TRUE
	var/list/failed_turfs = list()


/datum/unit_test/areas_turf_cache_should_be_valid/start_test()
	invoke_async(src, PROC_REF(run_test))
	return TRUE


/datum/unit_test/areas_turf_cache_should_be_valid/check_result()
	return reported


/datum/unit_test/areas_turf_cache_should_be_valid/proc/run_test()
	PRIVATE_PROC(TRUE)

	validate_areas_turf_cache()
	check_for_non_cached_turfs()

	if(length(failed_turfs))
		fail("Area turf cache is invalid with: [length(failed_turfs)] failed turfs")
	else
		pass("Area turf cache is valid.")


/datum/unit_test/areas_turf_cache_should_be_valid/proc/validate_areas_turf_cache()
	PRIVATE_PROC(TRUE)

	for(var/area/area_to_check as anything in GLOB.areas)
		for(var/turf/turf_to_validate as anything in area_to_check.get_turfs_from_all_z())
			if(turf_to_validate.in_contents_of)
				if(turf_to_validate.in_contents_of == area_to_check)
					log_bad("Found duplicate turf [log_info_line(turf_to_validate)] inside turf cache of [log_info_line(turf_to_validate.in_contents_of)]")
				else
					log_bad("Found shared turf [log_info_line(turf_to_validate)] between [log_info_line(area_to_check)] and [log_info_line(turf_to_validate.in_contents_of)]")

				failed_turfs[turf_to_validate] = TRUE

			var/area/actual_area = turf_to_validate.loc
			if(area_to_check != actual_area)
				log_bad("Found turf [log_info_line(turf_to_validate)] in cache of [log_info_line(area_to_check)] but not in it's contents")
				failed_turfs[turf_to_validate] = TRUE

			turf_to_validate.in_contents_of = area_to_check


/datum/unit_test/areas_turf_cache_should_be_valid/proc/check_for_non_cached_turfs()
	PRIVATE_PROC(TRUE)

	for(var/turf/turf_to_validate as anything in ALL_TURFS())
		if(!turf_to_validate.in_contents_of)
			log_bad("Found turf [log_info_line(turf_to_validate)] in contents of [log_info_line(turf_to_validate.loc)] but not in it's cache")
			failed_turfs[turf_to_validate] = TRUE
