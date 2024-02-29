#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
	/// For the area_contents list unit test
	/// Allows us to know our area without needing to preassign it
	/// Sorry for the mess
	/turf/var/area/in_contents_of
#endif

/datum/unit_test/areas_turf_cache_should_be_valid
	name = "AREA: Area turf cache should be valid"
	async = TRUE
	var/failed = FALSE


/datum/unit_test/areas_turf_cache_should_be_valid/start_test()
	invoke_async(src, PROC_REF(run_test))
	return TRUE


/datum/unit_test/areas_turf_cache_should_be_valid/check_result()
	return reported


/datum/unit_test/areas_turf_cache_should_be_valid/proc/run_test()
	PRIVATE_PROC(TRUE)

	assign_turfs_with_area_they_are_cached_in()
	validate_all_turfs_loc()

	if(failed)
		fail("Area turf cache is invalid with: total_non_cached_turfs: [total_non_cached_turfs] and total_incorrectly_cached_turfs: [total_incorrectly_cached_turfs]")
	else
		pass("Area turf cache is valid.")


/datum/unit_test/areas_turf_cache_should_be_valid/proc/assign_turfs_with_area_they_are_cached_in()
	PRIVATE_PROC(TRUE)

	for(var/area/area_to_check as anything in GLOB.areas)
		for(var/turf/turf_to_validate as anything in area_to_check.get_turfs_from_all_z())
			if(turf_to_validate.in_contents_of)
				log_bad("Turf: [log_info_line(turf_to_validate)] is already present in area: [log_info_line(in_contents_of)]")
				failed = TRUE

			turf_to_validate.in_contents_of = area_to_check

/datum/unit_test/areas_turf_cache_should_be_valid/proc/validate_all_turfs_loc()
	PRIVATE_PROC(TRUE)

	for(var/turf/turf_to_validate as anything in ALL_TURFS())
		var/area/excepted_area = turf_to_validate.loc
		if(expected_area != turf_to_validate.in_contents_of)
			log_bad("Turf: [log_info_line(turf_to_validate)] is expected to be cached in [log_info_line(expected_area)] but instead is in [log_info_line(turf_to_validate.in_contents_of)]")
