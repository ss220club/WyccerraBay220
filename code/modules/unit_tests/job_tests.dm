/datum/unit_test/jobs_shall_have_a_valid_outfit_type
	name = "JOBS: Shall have a valid outfit type"

/datum/unit_test/jobs_shall_have_a_valid_outfit_type/start_test()
	var/failed_jobs = 0

	for (var/occ in SSjobs.titles_to_datums)
		var/datum/job/occupation = SSjobs.titles_to_datums[occ]
		var/singleton/hierarchy/outfit/job/outfit = outfit_by_type(occupation.outfit_type)
		if(!istype(outfit))
			log_bad("[occupation.title] - [occupation.type]: Invalid outfit type [outfit ? outfit.type : "NULL"].")
			failed_jobs++

	if(failed_jobs)
		fail("[failed_jobs] job\s with invalid outfit type.")
	else
		pass("All jobs had outfit types.")
	return 1

/datum/unit_test/jobs_shall_have_a_HUD_icon
	name = "JOB: Shall have a HUD icon"

/datum/unit_test/jobs_shall_have_a_HUD_icon/start_test()
	var/failed_jobs = 0
	var/failed_sanity_checks = 0

	if(!ICON_HAS_STATE(GLOB.using_map.id_hud_icons, ""))
		log_bad("Sanity Check - Missing default/unnamed HUD icon")
		failed_sanity_checks++

	if(!ICON_HAS_STATE(GLOB.using_map.id_hud_icons, "hudunknown"))
		log_bad("Sanity Check - Missing HUD icon: hudunknown")
		failed_sanity_checks++

	if(!ICON_HAS_STATE(GLOB.using_map.id_hud_icons, "hudcentcom"))
		log_bad("Sanity Check - Missing HUD icon: hudcentcom")
		failed_sanity_checks++

	for(var/job_name in SSjobs.titles_to_datums)
		var/datum/job/J = SSjobs.titles_to_datums[job_name]
		var/hud_icon_state = J.hud_icon
		if(!ICON_HAS_STATE(GLOB.using_map.id_hud_icons, hud_icon_state))
			log_bad("[J.title] - Missing HUD icon: [hud_icon_state]")
			failed_jobs++

	if(failed_sanity_checks || failed_jobs)
		fail("[GLOB.using_map.id_hud_icons] - [failed_sanity_checks] failed sanity check\s, [failed_jobs] job\s with missing HUD icon.")
	else
		pass("All jobs have a HUD icon.")
	return 1

/datum/unit_test/jobs_shall_have_a_unique_title
	name = "JOBS: All Job Datums Shall Have A Unique Title"

/datum/unit_test/jobs_shall_have_a_unique_title/start_test()
	var/list/checked_titles = list()
	var/list/non_unique_titles = list()
	for(var/job_type in SSjobs.types_to_datums)
		var/datum/job/job = SSjobs.types_to_datums[job_type]
		var/list/titles_to_check = job.alt_titles ? job.alt_titles.Copy() : list()
		titles_to_check += job.title
		for(var/job_title in titles_to_check)
			if(checked_titles[job_title])
				non_unique_titles += "[job_title] ([job_type])"
				non_unique_titles |= "[job_title] ([checked_titles[job_title]])"
			else
				checked_titles[job_title] = job_type

	if(LAZYLEN(non_unique_titles))
		fail("Some jobs share a title:\n[jointext(non_unique_titles, "\n")]")
	else
		pass("All jobs have a unique title.")
	return 1
