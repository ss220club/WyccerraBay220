/datum/event/prison_break
	startWhen = 5
	announceWhen = 75
	endWhen = 60
	var/warning = 0.5

	var/list/area/areas = list()		//List of areas to affect. Filled by start()

	var/eventDept = "Security"			//Department name in announcement
	var/list/areaName = list("Brig")	//Names of areas mentioned in AI and Engineering announcements
	var/list/areaType = list(/area/security/prison, /area/security/brig)	//Area types to include.
	var/list/areaNotType = list()		//Area types to specifically exclude.

/datum/event/prison_break/setup()
	announceWhen = rand(75, 105)
	endWhen = announceWhen + rand(5, 25)
	warning = rand(5, 10) / 10


/datum/event/prison_break/announce()
	if (areas && length(areas) > 0)
		GLOB.command_announcement.Announce("[pick("Gr3yT1d3 virus","Malignant trojan",)] detected in [location_name()] [eventDept] subroutines. Secure any compromised areas immediately.", "[location_name()] Anti-Virus Alert", zlevels = affecting_z)


/datum/event/prison_break/start()
	for(var/area/A as anything in GLOB.areas)
		if(is_type_in_list(A,areaType) && !is_type_in_list(A,areaNotType))
			areas += A

	if(areas && length(areas) > 0)
		var/my_department = "[location_name()] Firewall Subroutines"
		var/rc_message = "An unknown malicious program has been detected in the [english_list(areaName)] lighting and airlock control systems at [stationtime2text()]. Systems will be fully compromised within approximately three minutes. Direct intervention is required immediately.<br>"
		var/obj/machinery/message_server/MS = get_message_server()
		if(MS)
			MS.send_rc_message("Engineering", my_department, rc_message, "", "", 2)
		for(var/mob/living/silicon/ai/A in GLOB.player_list)
			to_chat(A, SPAN_DANGER("Malicious program detected in the [english_list(areaName)] lighting and airlock control systems by [my_department]."))

	else
		to_world_log("ERROR: Could not initate grey-tide. Unable to find suitable containment area.")
		kill()


/datum/event/prison_break/tick()
	if (activeFor >= warning * endWhen)
		if (areas && length(areas) > 0)
			var/obj/machinery/power/apc/theAPC = null
			for (var/area/A in areas)
				theAPC = A.get_apc()
				if (theAPC && theAPC.operating)
					theAPC.flicker_lighting()


/datum/event/prison_break/end()
	for(var/area/A in shuffle(areas))
		A.prison_break()
