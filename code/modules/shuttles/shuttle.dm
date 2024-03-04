//shuttle moving state defines are in setup.dm

/datum/shuttle
	var/name = ""
	/// Time it takes shuttle to takeoff
	var/warmup_time = 0
	/// Time it takes shuttle to land
	var/landing_time = 10 SECONDS
	var/moving_status = SHUTTLE_IDLE

	var/list/shuttle_area //can be both single area type or a list of areas
	var/obj/shuttle_landmark/current_location //This variable is type-abused initially: specify the landmark_tag, not the actual landmark.

	var/arrive_time = 0	//the time at which the shuttle arrives when long jumping
	var/flags = 0
	var/process_state = IDLE_STATE //Used with SHUTTLE_FLAGS_PROCESS, as well as to store current state.
	var/category = /datum/shuttle
	var/multiz = 0	//how many multiz levels, starts at 0

	var/ceiling_type = /turf/unsimulated/floor/shuttle_ceiling

	var/sound_takeoff = 'sound/effects/shuttle_takeoff.ogg'
	var/sound_landing = 'sound/effects/shuttle_landing.ogg'

	var/knockdown = 1 //whether shuttle downs non-buckled people when it moves

	var/defer_initialisation = FALSE //this shuttle will/won't be initialised automatically. If set to true, you are responsible for initialzing the shuttle manually.
	                                 //Useful for shuttles that are initialed by map_template loading, or shuttles that are created in-game or not used.
	var/logging_home_tag   //Whether in-game logs will be generated whenever the shuttle leaves/returns to the landmark with this landmark_tag.
	var/logging_access     //Controls who has write access to log-related stuff; should correlate with pilot access.

	var/mothershuttle //tag of mothershuttle
	var/motherdock    //tag of mothershuttle landmark, defaults to starting location

/datum/shuttle/New(_name, obj/shuttle_landmark/initial_location)
	..()
	if(_name)
		src.name = _name

	var/list/areas = list()
	if(!islist(shuttle_area))
		shuttle_area = list(shuttle_area)
	for(var/T in shuttle_area)
		var/area/A = locate(T)
		if(!istype(A))
			CRASH("Shuttle \"[name]\" couldn't locate area [T].")
		areas += A
	shuttle_area = areas

	if(initial_location)
		current_location = initial_location
	else
		current_location = SSshuttle.get_landmark(current_location)
	if(!istype(current_location))
		CRASH("Shuttle \"[name]\" could not find its starting location.")

	if(src.name in SSshuttle.shuttles)
		CRASH("A shuttle with the name '[name]' is already defined.")
	SSshuttle.shuttles[src.name] = src
	if(logging_home_tag)
		new /datum/shuttle_log(src)
	if(flags & SHUTTLE_FLAGS_PROCESS)
		SSshuttle.process_shuttles += src
	if(flags & SHUTTLE_FLAGS_SUPPLY)
		if(SSsupply.shuttle)
			CRASH("A supply shuttle is already defined.")
		SSsupply.shuttle = src

/datum/shuttle/Destroy()
	current_location = null

	SSshuttle.shuttles -= src.name
	SSshuttle.process_shuttles -= src
	SSshuttle.shuttle_logs -= src
	if(SSsupply.shuttle == src)
		SSsupply.shuttle = null

	. = ..()

/datum/shuttle/proc/short_jump(obj/shuttle_landmark/destination)
	if(moving_status != SHUTTLE_IDLE)
		return

	moving_status = SHUTTLE_WARMUP
	if(sound_takeoff)
		playsound(current_location, sound_takeoff, 100, 20, 0.2)

	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/shuttle, perform_short_jump), destination), warmup_time)

/datum/shuttle/proc/perform_short_jump(obj/shuttle_landmark/destination)
	if (moving_status == SHUTTLE_IDLE)
		return //someone cancelled the launch

	if(!fuel_check()) //fuel error (probably out of fuel) occured, so cancel the launch
		var/datum/shuttle/autodock/self = src
		if(istype(self))
			self.cancel_launch(null)
		return

	moving_status = SHUTTLE_INTRANSIT //shouldn't matter but just to be safe
	attempt_move(destination)
	moving_status = SHUTTLE_IDLE

/datum/shuttle/proc/long_jump(obj/shuttle_landmark/destination, obj/shuttle_landmark/interim, travel_time)
	if(moving_status != SHUTTLE_IDLE)
		return

	var/obj/shuttle_landmark/start_location = current_location

	moving_status = SHUTTLE_WARMUP
	if(sound_takeoff)
		playsound(current_location, sound_takeoff, 100, 20, 0.2)
		if(!isspace(start_location.base_area))
			var/list/shuttle_area_refs_set = get_area_refs_set(shuttle_area)
			for(var/mob/mob_to_notify as anything in GLOB.player_list)
				if(!mob_to_notify.client)
					continue

				if(mob_to_notify.z != start_location.z)
					continue

				if(isspaceturf(get_turf(mob_to_notify)))
					continue

				if(shuttle_area_refs_set[ref(get_area(mob_to_notify))])
					continue

				to_chat(mob_to_notify, SPAN_NOTICE("The rumble of engines are heard as a shuttle lifts off."))

	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/shuttle, launch_shuttle), start_location, interim, destination, travel_time), warmup_time)

/datum/shuttle/proc/launch_shuttle(obj/shuttle_landmark/start_location, obj/shuttle_landmark/interim, obj/shuttle_landmark/destination, travel_time)
	if(moving_status == SHUTTLE_IDLE)
		return	//someone cancelled the launch

	if(!fuel_check()) //fuel error (probably out of fuel) occured, so cancel the launch
		var/datum/shuttle/autodock/self = src
		if(istype(self))
			self.cancel_launch(null)

		return

	var/start_landing_in = travel_time - landing_time
	arrive_time = world.time + travel_time
	moving_status = SHUTTLE_INTRANSIT

	if(!attempt_move(interim))
		moving_status = SHUTTLE_IDLE
		return

	if(start_landing_in > 0)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/shuttle, prepare_for_landing), start_location, destination), start_landing_in)
	else
		prepare_for_landing(start_location, destination)

/// Plans landing of shuttle and plays landing sound
/datum/shuttle/proc/prepare_for_landing(obj/shuttle_landmark/start_location, obj/shuttle_landmark/destination)
	if(sound_landing)
		playsound(destination, sound_landing, 100, 0, 7)
		if(!isspace(destination.base_area))
			var/list/shuttle_area_refs_set = get_area_refs_set(shuttle_area)
			for(var/mob/mob_to_notify as anything in GLOB.player_list)
				if(!mob_to_notify.client)
					continue

				if(mob_to_notify.z != destination.z)
					continue

				if(isspaceturf(get_turf(mob_to_notify)))
					continue

				if(shuttle_area_refs_set[ref(get_area(mob_to_notify))])
					continue

				to_chat(mob_to_notify, SPAN_NOTICE("The rumble of a shuttle's engines fill the area as a ship manuevers in for a landing."))

	var/landing_in = arrive_time - world.time
	if(landing_in > 0)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/shuttle, land_shuttle), start_location, destination), landing_in)
	else
		land_shuttle(start_location, destination)

/// Actually moves shuttle to new location from the interim
/datum/shuttle/proc/land_shuttle(obj/shuttle_landmark/start_location, obj/shuttle_landmark/destination)
	if(!attempt_move(destination))
		/// Something went wrong, so we try to move back
		attempt_move(start_location)

	moving_status = SHUTTLE_IDLE

/datum/shuttle/proc/fuel_check()
	return TRUE //fuel check should always pass in non-overmap shuttles (they have magic engines)

/*****************
* Shuttle Moved Handling * (Observer Pattern Implementation: Shuttle Moved)
* Shuttle Pre Move Handling * (Observer Pattern Implementation: Shuttle Pre Move)
*****************/

/datum/shuttle/proc/attempt_move(obj/shuttle_landmark/destination)
	if(current_location == destination)
		return FALSE

	if(!destination.is_valid(src))
		return FALSE

	if(current_location.cannot_depart(src))
		return FALSE

	testing("[src] moving to [destination]. Areas are [english_list(shuttle_area)]")

	var/old_location = current_location
	var/list/translation = get_turf_translation(get_turf(current_location), get_turf(destination), get_turfs())
	GLOB.shuttle_pre_move_event.raise_event(src, old_location, destination)
	shuttle_moved(destination, translation)
	GLOB.shuttle_moved_event.raise_event(src, old_location, destination)
	destination.shuttle_arrived(src)
	// + BANDAID
	// /obj/machinery/proc/area_changed and /proc/translate_turfs cause problems with power cost duplication.
	var/list/area/retally_areas
	if (isarea(shuttle_area))
		retally_areas = list(shuttle_area)
	else if (islist(shuttle_area))
		retally_areas = shuttle_area
	for (var/area/area as anything in retally_areas)
		area.retally_power()
	// - BANDAID
	return TRUE

/// Returns list of all turfs that shuttle posses
/datum/shuttle/proc/get_turfs()
	var/list/shuttle_turfs = list()
	for(var/area/area_on_shuttle as anything in shuttle_area)
		shuttle_turfs += get_area_turfs(area_on_shuttle)

	return shuttle_turfs

//just moves the shuttle from A to B, if it can be moved
//A note to anyone overriding move in a subtype. shuttle_moved() must absolutely not, under any circumstances, fail to move the shuttle.
//If you want to conditionally cancel shuttle launches, that logic must go in short_jump(), long_jump() or attempt_move()
/datum/shuttle/proc/shuttle_moved(obj/shuttle_landmark/destination, list/turf_translation)

//	log_debug("move_shuttle() called for [shuttle_tag] leaving [origin] en route to [destination].")
//	log_degug("area_coming_from: [origin]")
//	log_debug("destination: [destination]")
	if((flags & SHUTTLE_FLAGS_ZERO_G))
		var/new_area_has_gravity = TRUE

		if(destination.flags & SLANDMARK_FLAG_ZERO_G)
			var/area/new_area = get_area(destination)
			new_area_has_gravity = new_area.has_gravity

		for(var/area/our_area as anything in shuttle_area)
			if(our_area.has_gravity != new_area_has_gravity)
				our_area.gravitychange(new_area_has_gravity)

	for(var/turf/src_turf in turf_translation)
		var/turf/dst_turf = turf_translation[src_turf]
		if(!src_turf.is_solid_structure())
			continue

		//in case someone put a hole in the shuttle and you were lucky enough to be under it
		for(var/atom/movable/target as anything in dst_turf)
			if(!target.simulated)
				continue

			target.shuttle_land_on()

	var/list/old_powernets = list()
	var/has_z_level_above = HasAbove(current_location.z)
	for(var/turf/old_turf as anything in get_turfs())
		// if there was a zlevel above our origin, erase our ceiling now we're leaving
		if(has_z_level_above)
			var/turf/turf_above = GetAbove(old_turf)

			if(!istype(turf_above, ceiling_type))
				continue

			turf_above.ChangeTurf(get_base_turf_by_area(turf_above), 1, 1)

		for(var/obj/structure/cable/C in old_turf)
			old_powernets |= C.powernet

	if(knockdown)
		invoke_async(src, TYPE_PROC_REF(/datum/shuttle, knockdown_passengers))

	if(logging_home_tag)
		var/datum/shuttle_log/s_log = SSshuttle.shuttle_logs[src]
		s_log.handle_move(current_location, destination)

	translate_turfs(turf_translation, current_location.base_area, current_location.base_turf)
	current_location = destination

	// if there's a zlevel above our destination, paint in a ceiling on it so we retain our air
	if(HasAbove(current_location.z))
		var/list/area_refs_set = get_area_refs_set(shuttle_area)
		var/list/destination_turfs = get_turfs()
		for(var/turf/destination_turf as anything in destination_turfs)
			var/turf/turf_above = GetAbove(destination_turf)

			if(!istype(turf_above, get_base_turf_by_area(turf_above)) && !istype(turf_above, /turf/simulated/open))
				continue

			if(area_refs_set[ref(get_area(turf_above))])
				continue

			turf_above.ChangeTurf(ceiling_type, TRUE, TRUE, TRUE)

	// Remove all powernets that were affected, and rebuild them.
	var/list/shuttle_cables = list()
	for(var/datum/powernet/old_powernet as anything in old_powernets)
		shuttle_cables |= old_powernet.cables
		qdel(old_powernet)

	for(var/obj/structure/cable/C as anything in shuttle_cables)
		if(C.powernet)
			continue

		var/datum/powernet/NewPN = new()
		NewPN.add_cable(C)
		propagate_network(C, C.powernet)

	if(mothershuttle)
		return

	var/datum/shuttle/mothership = SSshuttle.shuttles[mothershuttle]
	if(!mothership)
		return

	if(current_location.landmark_tag == motherdock)
		mothership.shuttle_area |= shuttle_area
	else
		mothership.shuttle_area -= shuttle_area

/datum/shuttle/proc/knockdown_passengers()
	var/list/area_refs_set = get_area_refs_set(shuttle_area)
	for(var/mob/living/carbon/passenger_to_knockdown as anything in SSmobs.get_mobs_of_type(/mob/living/carbon))
		/// TODO: cache mobs inside areas
		if(!area_refs_set[ref(get_area(passenger_to_knockdown))])
			continue

		if(passenger_to_knockdown.buckled)
			to_chat(passenger_to_knockdown, SPAN_WARNING("Sudden acceleration presses you into your chair!"))
			shake_camera(passenger_to_knockdown, 3, 1)
			continue

		to_chat(passenger_to_knockdown, SPAN_WARNING("The floor lurches beneath you!"))
		shake_camera(passenger_to_knockdown, 10, 1)
		passenger_to_knockdown.visible_message(SPAN_WARNING("[passenger_to_knockdown.name] is tossed around by the sudden acceleration!"))
		passenger_to_knockdown.throw_at_random(FALSE, 4, 1)

/// Handler for shuttles landing on atoms. Called by `shuttle_moved()`.
/atom/movable/proc/shuttle_land_on()
	qdel(src)

/mob/living/shuttle_land_on()
	gib()

//returns 1 if the shuttle has a valid arrive time
/datum/shuttle/proc/has_arrive_time()
	return (moving_status == SHUTTLE_INTRANSIT)

/datum/shuttle/proc/find_children()
	. = list()
	for(var/shuttle_name in SSshuttle.shuttles)
		var/datum/shuttle/shuttle = SSshuttle.shuttles[shuttle_name]
		if(shuttle.mothershuttle == name)
			. += shuttle

//Returns those areas that are not actually child shuttles.
/datum/shuttle/proc/find_childfree_areas()
	. = shuttle_area.Copy()
	for(var/datum/shuttle/child in find_children())
		. -= child.shuttle_area

/datum/shuttle/autodock/proc/get_location_name()
	if(moving_status == SHUTTLE_INTRANSIT)
		return "In transit"
	return current_location.name

/datum/shuttle/autodock/proc/get_destination_name()
	if(!next_location)
		return "None"
	return next_location.name
