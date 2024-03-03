/// For the area_contents list unit test
/// Allows us to know our area without needing to preassign it
/// Sorry for the mess
/turf/var/area/in_contents_of

/datum/unit_test/areas_turf_cache_should_be_consisten
	name = "AREA: Area turf cache should be consistent"
	async = TRUE
	var/failed = FALSE


/datum/unit_test/areas_turf_cache_should_be_consisten/start_test()
	invoke_async(src, PROC_REF(run_test))
	return TRUE


/datum/unit_test/areas_turf_cache_should_be_consisten/check_result()
	return reported


/datum/unit_test/areas_turf_cache_should_be_consisten/proc/run_test()
	PRIVATE_PROC(TRUE)

	for(var/area/area_to_check as anything in GLOB.areas)
		for(var/turf/turf_to_validate as anything in area_to_check.get_turfs_from_all_z())
			if(turf_to_validate.in_contents_of)
				if(turf_to_validate.in_contents_of == area_to_check)
					log_bad("Found duplicate turf [log_info_line(turf_to_validate)] inside turf cache of [log_info_line(turf_to_validate.in_contents_of)]")
				else
					log_bad("Found shared turf [log_info_line(turf_to_validate)] between [log_info_line(area_to_check)] and [log_info_line(turf_to_validate.in_contents_of)]")

				failed = TRUE

			var/area/actual_area = turf_to_validate.loc
			if(area_to_check != actual_area)
				log_bad("Found turf [log_info_line(turf_to_validate)] in cache of [log_info_line(area_to_check)] but not in it's contents")
				failed = TRUE

			turf_to_validate.in_contents_of = area_to_check

	for(var/turf/turf_to_validate as anything in ALL_TURFS())
		if(!turf_to_validate.in_contents_of)
			log_bad("Found turf [log_info_line(turf_to_validate)] in contents of [log_info_line(turf_to_validate.loc)] but not in it's cache")
			failed = TRUE

	if(failed)
		fail("Area turf cache is invalid.")
	else
		pass("Area turf cache is valid.")
