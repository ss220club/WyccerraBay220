// Areas.dm

/area
	/// Integer. Global counter for `uid` values assigned to areas. Increments by one for each new area.
	var/static/global_uid = 0
	/// Integer. The area's unique ID number. set to the value of `global_uid` + 1 when the area is created.
	var/uid
	/// Bitflag (Any of `AREA_FLAG_*`). See `code\__defines\misc.dm`.
	var/area_flags
	/// A lazy list of vent pumps currently in the area
	var/list/obj/machinery/atmospherics/unary/vent_pump/vent_pumps
	/// Lazy list of all turfs in area. Updated when new turf created or removed from the area.
	/// For faster lookup and cleanup, turfs are grouped by z level.
	/// Looks like: z_level -> contained_turfs_list
	var/list/turf/contained_turfs_by_z
	/// Due to size of some area turfs lists, it's quite expensive to clean them up right away.
	/// So we will do it in subsystem, or right away, if area turfs requested.
	/// Has the same structure as `contained_turfs_by_z`.
	var/list/turf/turfs_to_uncontain_by_z

/area/New()
	LAZYADD(GLOB.areas,	src)
	LAZYINITLIST(contained_turfs_by_z)
	LAZYINITLIST(turfs_to_uncontain_by_z)

	icon_state = ""
	uid = ++global_uid

	if(!requires_power)
		power_light = 0
		power_equip = 0
		power_environ = 0

	if(dynamic_lighting)
		luminosity = 0
	else
		luminosity = 1

	..()

/area/Initialize()
	. = ..()
	if(!requires_power || !apc)
		power_light = 0
		power_equip = 0
		power_environ = 0
	power_change()		// all machines set to current power level, also updates lighting icon
	if (turfs_airless)
		return INITIALIZE_HINT_LATELOAD

/area/Destroy()
	LAZYREMOVE(GLOB.areas, src)
	return ..()

/area/LateInitialize(mapload)
	turfs_airless = FALSE

/// Returns list (`/obj/machinery/camera`). A list of all cameras in the area.
/area/proc/get_cameras()
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in machinery_list)
		cameras += C
	return cameras

/**
 * Defines the area's atmosphere alert level.
 *
 * **Parameters**:
 * - `danger_level` Integer. The new alert danger level to set.
 * - `alarm_source` Atom. The source that's triggering the alert change.
 *
 * Returns boolean. `TRUE` if the atmosphere alarm level was changed, `FALSE` otherwise.
 */
/area/proc/atmosalert(danger_level, alarm_source)
	if (danger_level == 0)
		GLOB.atmosphere_alarm.clearAlarm(src, alarm_source)
	else
		GLOB.atmosphere_alarm.triggerAlarm(src, alarm_source, severity = danger_level)

	var/list/area_alarms = list()
	//Check all the alarms before lowering atmosalm. Raising is perfectly fine.
	for(var/obj/machinery/alarm/AA in machinery_list)
		if (AA.operable() && !AA.shorted && AA.report_danger_level)
			danger_level = max(danger_level, AA.danger_level)

		area_alarms += AA

	if(atmosalm == danger_level)
		return FALSE

	if (danger_level < 1 && atmosalm >= 1)
		//closing the doors on red and opening on green provides a bit of hysteresis that will hopefully prevent fire doors from opening and closing repeatedly due to noise
		air_doors_open()
	else if (danger_level >= 2 && atmosalm < 2)
		air_doors_close()

	atmosalm = danger_level
	for (var/obj/machinery/alarm/AA as anything in area_alarms)
		AA.update_icon()

	return TRUE

/// Sets `air_doors_activated` and sets all firedoors in `all_doors` to the closed state. Does nothing if `air_doors_activated` is already set.
/area/proc/air_doors_close()
	if(!air_doors_activated)
		air_doors_activated = 1
		if(!all_doors)
			return
		for(var/obj/machinery/door/firedoor/E in all_doors)
			if(!E.blocked)
				if(E.operating)
					E.nextstate = FIREDOOR_CLOSED
				else if(!E.density)
					spawn(0)
						E.close()

/// Clears `air_doors_activated` and sets all firedoors in `all_doors` to the open state. Does nothing if `air_doors_activated` is already cleared.
/area/proc/air_doors_open()
	if(air_doors_activated)
		air_doors_activated = 0
		if(!all_doors)
			return
		for(var/obj/machinery/door/firedoor/E in all_doors)
			E.locked = FALSE
			if(!E.blocked)
				if(E.operating)
					E.nextstate = FIREDOOR_OPEN
				else if(E.density)
					spawn(0)
						if(E.can_safely_open())
							E.open()


/// Sets a fire alarm in the area, if one is not already active.
/area/proc/fire_alert()
	if(!fire)
		fire = TRUE	//used for firedoor checks
		update_icon()
		mouse_opacity = 0
		if(!all_doors)
			return
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = FIREDOOR_CLOSED
				else if(!D.density)
					spawn()
						D.close()

/// Clears an active fire alarm from the area.
/area/proc/fire_reset()
	if (fire)
		fire = FALSE	//used for firedoor checks
		update_icon()
		mouse_opacity = 0
		if(!all_doors)
			return
		for(var/obj/machinery/door/firedoor/D in all_doors)
			D.locked = FALSE
			if(!D.blocked)
				if(D.operating)
					D.nextstate = FIREDOOR_OPEN
				else if(D.density)
					spawn(0)
					D.open()

/// Sets an active evacuation alarm in the area, if one is not already active.
/area/proc/readyalert()
	if(!eject)
		eject = 1
		update_icon()

/// Clears an active evacuation alarm from the area.
/area/proc/readyreset()
	if(eject)
		eject = 0
		update_icon()

/// Sets a party alarm in the area, if one is not already active.
/area/proc/partyalert()
	if (!( party ))
		party = 1
		update_icon()
		mouse_opacity = 0

/// Clears an active party alarm from the area.
/area/proc/partyreset()
	if (party)
		party = 0
		mouse_opacity = 0
		update_icon()
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = FIREDOOR_OPEN
				else if(D.density)
					spawn(0)
					D.open()

/area/on_update_icon()
	if ((fire || eject || party) && (!requires_power||power_environ))//If it doesn't require power, can still activate this proc.
		if(fire && !eject && !party)
			icon_state = "blue"
		/*else if(atmosalm && !fire && !eject && !party)
			icon_state = "bluenew"*/
		else if(!fire && eject && !party)
			icon_state = "red"
		else if(party && !fire && !eject)
			icon_state = "party"
		else
			icon_state = "blue-red"
	else
	//	new lighting behaviour with obj lights
		icon_state = null

/// Sets the area's light switch state to on or off, in turn turning all lights in the area on or off.
/area/proc/set_lightswitch(new_switch)
	if(lightswitch != new_switch)
		lightswitch = new_switch
		for(var/obj/machinery/light_switch/L in machinery_list)
			L.sync_state()
		update_icon()
		power_change()

/// Calls `set_emergency_lighting(enable)` on all `/obj/machinery/light` in contained machinery.
/area/proc/set_emergency_lighting(enable)
	for(var/obj/machinery/light/M in machinery_list)
		M.set_emergency_lighting(enable)


/area/Entered(A)
	..()
	if(!isliving(A))
		return

	var/mob/living/L = A

	if(!L.lastarea)
		L.lastarea = get_area(L.loc)
	var/area/newarea = get_area(L.loc)
	var/area/oldarea = L.lastarea
	if(oldarea.has_gravity != newarea.has_gravity)
		if(newarea.has_gravity == 1 && MOVING_QUICKLY(L)) // Being not hasty when you change areas allows you to avoid falling.
			thunk(L)
		L.update_floating()

	play_ambience(L)
	L.lastarea = newarea


/// Handles playing ambient sounds to a given mob, including ship hum.
/area/proc/play_ambience(mob/living/living)
	if (!living?.client)
		return
	if (living.get_preference_value(/datum/client_preference/play_ambiance) != PREF_YES)
		return
	var/turf/turf = get_turf(living)
	if (!turf)
		return

	var/vent_ambience
	if (!always_unpowered && power_environ && length(vent_pumps) && living.get_sound_volume_multiplier() > 0.2)
		for (var/obj/machinery/atmospherics/unary/vent_pump/vent as anything in vent_pumps)
			if (vent.can_pump())
				vent_ambience = TRUE
				break
	var/client/client = living.client
	if (vent_ambience)
		if (!client.playing_vent_ambience)
			var/sound = sound('sound/ambience/shipambience.ogg', repeat = TRUE, wait = 0, volume = 10, channel = GLOB.ambience_channel_vents)
			living.playsound_local(turf, sound)
			client.playing_vent_ambience = TRUE
	else
		sound_to(living, sound(null, channel = GLOB.ambience_channel_vents))
		client.playing_vent_ambience = FALSE

	if (living.lastarea != src)
		if (length(forced_ambience))
			var/sound = sound(pick(forced_ambience), repeat = TRUE, wait = 0, volume = 25, channel = GLOB.ambience_channel_forced)
			living.playsound_local(turf, sound)
		else
			sound_to(living, sound(null, channel = GLOB.ambience_channel_forced))

	var/time = world.time
	if (length(ambience) && time > client.next_ambience_time)
		var/sound = sound(pick(ambience), repeat = FALSE, wait = 0, volume = 15, channel = GLOB.ambience_channel_common)
		living.playsound_local(turf, sound)
		client.next_ambience_time = time + rand(3, 5) MINUTES


/**
 * Sets the area's `has_gravity` state.
 *
 * **Parameters**:
 * - `gravitystate` Boolean, default `FALSE`. The new state to set `has_gravity` to.
 */
/area/proc/gravitychange(gravitystate = FALSE)
	if(has_gravity == gravitystate)
		return

	has_gravity = gravitystate
	for(var/mob/target as anything in SSmobs.get_all_mobs())
		if(get_area(target) != src)
			continue

		if(has_gravity)
			thunk(target)

		target.update_floating()

/// Causes the provided mob to 'slam' down to the floor if certain conditions are not met. Primarily used for gravity changes.
/area/proc/thunk(mob/living/carbon/human/mob_to_thunk)
	if(!istype(mob_to_thunk))
		return

	if(isspace(get_turf(mob_to_thunk))) // Can't fall onto nothing.
		return

	if(mob_to_thunk.Check_Shoegrip())
		return

	if(mob_to_thunk.buckled || !prob(mob_to_thunk.skill_fail_chance(SKILL_EVA, 100, SKILL_MASTER)))
		return

	if(!MOVING_DELIBERATELY(mob_to_thunk))
		mob_to_thunk.AdjustStunned(3)
		mob_to_thunk.AdjustWeakened(3)
	else
		mob_to_thunk.AdjustStunned(1.5)
		mob_to_thunk.AdjustWeakened(1.5)

	to_chat(mob_to_thunk, SPAN_NOTICE("The sudden appearance of gravity makes you fall to the floor!"))

/// Trigger for the prison break event. Causes lighting to overload and dooes to open. Has no effect if the area lacks an APC or the APC is turned off.
/area/proc/prison_break()
	var/obj/machinery/power/apc/theAPC = get_apc()
	if(theAPC && theAPC.operating)
		for(var/obj/machinery/power/apc/temp_apc in machinery_list)
			temp_apc.overload_lighting(70)

		for(var/obj/machinery/door/airlock/temp_airlock in all_doors)
			temp_airlock.prison_open()

		for(var/obj/machinery/door/window/temp_windoor in all_doors)
			temp_windoor.open()

/// Returns boolean. Whether or not the area is considered to have gravity.
/area/has_gravity()
	return has_gravity

/area/space/has_gravity()
	return 0

/atom/proc/has_gravity()
	var/area/A = get_area(src)
	if(A && A.has_gravity())
		return 1
	return 0

/mob/has_gravity()
	if(!lastarea)
		lastarea = get_area(src)
	if(!lastarea || !lastarea.has_gravity())
		return 0
	return 1

/turf/has_gravity()
	var/area/A = loc
	if(A && A.has_gravity())
		return 1
	return 0

/// Returns List (axis => Integer). The width and height, in tiles, of the area, indexed by axis. Axis is `"x"` or `"y"`.
/// The `z` of the lowest z-level area located at is used
/area/proc/get_dimensions()
	var/list/res = list("x"=1,"y"=1)
	var/list/min = list("x"=world.maxx,"y"=world.maxy)
	for(var/turf/T as anything in get_turfs_from_z(z))
		res["x"] = max(T.x, res["x"])
		res["y"] = max(T.y, res["y"])
		min["x"] = min(T.x, min["x"])
		min["y"] = min(T.y, min["y"])
	res["x"] = res["x"] - min["x"] + 1
	res["y"] = res["y"] - min["y"] + 1
	return res

/// Returns boolean. Whether or not there are any turfs (`/turf`) in src.
/area/proc/has_turfs()
	for(var/z_level in contained_turfs_by_z)
		var/list/turfs_to_uncontain = LAZYACCESS(turfs_to_uncontain_by_z, z_level)
		if(!LAZYLEN(turfs_to_uncontain))
			return TRUE

		if((LAZYLEN(contained_turfs_by_z[z_level]) - LAZYLEN(turfs_to_uncontain)) > 0)
			return TRUE

	return FALSE

/// Returns boolean. Whether or not the area can be modified by player actions.
/area/proc/can_modify_area()
	if (src && src.area_flags & AREA_FLAG_NO_MODIFY)
		return FALSE
	return TRUE

/// Adds new turf to area turf cache
/area/proc/add_turf_to_cache(turf/turf_to_add)
	if(!istype(turf_to_add))
		CRASH("Invalid turf `[log_info_line(turf_to_add)]` supplied to [log_info_line(src)]: ")

	LAZYADDASSOCLIST(contained_turfs_by_z, "[turf_to_add.z]", turf_to_add)
	turf_to_add.added_to_area_cache = TRUE

/// Removes turf from area turf cache
/area/proc/remove_turf_from_cache(turf/turf_to_remove)
	if(!istype(turf_to_remove))
		CRASH("Invalid turf `[log_info_line(turf_to_remove)]` supplied to [log_info_line(src)]: ")

	if(!LAZYACCESS(contained_turfs_by_z, "[turf_to_remove.z]"))
		return

	LAZYADDASSOCLIST(turfs_to_uncontain_by_z, "[turf_to_remove.z]", turf_to_remove)

/// Returns all area turfs from specific z-level
/area/proc/get_turfs_from_z(z_level)
	cannonize_cached_turfs_by_z(z_level)
	return LAZYACCESS(contained_turfs_by_z, "[z_level]")

/// Returs list of all turfs located at this area
/area/proc/get_turfs_from_all_z()
	cannonize_cached_turfs_for_all_z()

	var/list/contained_turfs = list()
	for(var/z_level in contained_turfs_by_z)
		contained_turfs += contained_turfs_by_z[z_level]

	return contained_turfs

/// Makes sure that turfs located at area are up to date for all z levels
/area/proc/cannonize_cached_turfs_for_all_z()
	PRIVATE_PROC(TRUE)

	for(var/z_level in turfs_to_uncontain_by_z)
		cannonize_cached_turfs_by_z(z_level)

/// Makes sure that turfs located at area are up to date for specific z level
/// Returns FALSE if passed z_level doesn't require canonization, TRUE if cache is valid
/area/proc/cannonize_cached_turfs_by_z(z_level)
	PRIVATE_PROC(TRUE)

	var/list/contained_turfs = LAZYACCESS(contained_turfs_by_z, "[z_level]")
	if(!LAZYLEN(contained_turfs))
		LAZYREMOVE(turfs_to_uncontain_by_z, "[z_level]")
		return

	var/list/turfs_to_uncontain = LAZYACCESS(turfs_to_uncontain_by_z, "[z_level]")
	if(LAZYLEN(turfs_to_uncontain))
		contained_turfs -= turfs_to_uncontain
		LAZYREMOVE(turfs_to_uncontain_by_z, "[z_level]")

	if(!LAZYLEN(contained_turfs))
		LAZYREMOVE(contained_turfs_by_z, "[z_level]")
