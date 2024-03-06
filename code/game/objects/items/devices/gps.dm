GLOBAL_LIST_EMPTY(gps_list)

/obj/item/device/gps
	name = "global coordinate system"
	desc = "A handheld relay used to triangulate the approximate co-ordinates of the device."
	icon = 'icons/obj/tools/locator.dmi'
	icon_state = "gps"
	item_state = "gps"
	origin_tech = list(TECH_MATERIAL = 2, TECH_DATA = 2, TECH_BLUESPACE = 2)
	matter = list(MATERIAL_ALUMINIUM = 1000, MATERIAL_PLASTIC = 750)
	w_class = ITEM_SIZE_SMALL
	/// Will not show other signals or emit its own signal if false.
	var/tracking = FALSE
	/// If true, can see farther, depending on get_map_levels().
	var/long_range = FALSE
	/// If true, only GPS signals of the same Z level are shown.
	var/local_mode = FALSE
	/// If true, signal is not visible to other GPS devices.
	var/hide_signal = FALSE
	/// If it can toggle the above var.
	var/can_hide_signal = FALSE
	/// Device tag (name)
	var/gps_tag = "GEN0"
	/// If device is emped
	var/emped = FALSE

	var/is_in_processing_list = FALSE
	var/mob/holder
	var/list/decals
	var/list/tracking_devices
	var/list/showing_tracked_names
	var/obj/compass_holder/compass

/obj/item/device/gps/Initialize()
	GLOB.gps_list += src
	. = ..()
	name = "[initial(name)] ([gps_tag])"
	GLOB.moved_event.register(holder, src, PROC_REF(update_holder))
	compass = new(src)
	update_holder()
	update_icon()

/obj/item/device/gps/examine(mob/user, distance)
	. = ..()
	if(distance <= 1)
		to_chat(user, SPAN_NOTICE("\The [src]'s screen shows: <i>[fetch_coordinates()]</i>."))

/obj/item/device/gps/proc/fetch_coordinates()
	var/turf/T = get_turf(src)
	return T ? "[T.x]:[T.y]:[T.z]" : "N/A"

/obj/item/device/gps/proc/check_visible_to_holder()
	. = !!holder?.IsHolding(src)

/obj/item/device/gps/proc/update_holder(force_clear = FALSE)

	if(holder && (force_clear || loc != holder))
		GLOB.moved_event.unregister(holder, src)
		GLOB.dir_set_event.unregister(holder, src)
		holder.client?.screen -= compass
		holder = null

	if(!force_clear && istype(loc, /mob))
		holder = loc
		GLOB.moved_event.register(holder, src, PROC_REF(update_compass))
		GLOB.dir_set_event.register(holder, src, PROC_REF(update_compass))

	if(!force_clear && holder && tracking)
		if(!is_in_processing_list)
			START_PROCESSING(SSobj, src)
			is_in_processing_list = TRUE
		if(holder.client)
			if(check_visible_to_holder())
				holder.client.screen |= compass
			else
				holder.client.screen -= compass
	else
		STOP_PROCESSING(SSobj, src)
		is_in_processing_list = FALSE
		if(holder?.client)
			holder.client.screen -= compass

/obj/item/device/gps/equipped_robot()
	. = ..()
	update_holder()

/obj/item/device/gps/equipped()
	. = ..()
	update_holder()

/obj/item/device/gps/Process()
	if(!tracking)
		is_in_processing_list = FALSE
		return PROCESS_KILL
	update_holder()
	if(holder)
		update_compass(TRUE)

/obj/item/device/gps/Destroy()
	STOP_PROCESSING(SSobj, src)
	is_in_processing_list = FALSE
	GLOB.gps_list -= src
	GLOB.moved_event.unregister(holder, src, PROC_REF(update_holder))
	update_holder(force_clear = TRUE)
	QDEL_NULL(compass)
	return ..()

/obj/item/device/gps/proc/can_track(obj/item/device/gps/other, reachable_z_levels)
	if(!other.tracking || other.emped || other.hide_signal)
		return FALSE

	var/turf/origin = get_turf(src)
	var/turf/target = get_turf(other)
	if(!istype(origin) || !istype(target))
		return FALSE
	if(origin.z == target.z)
		return TRUE
	if(local_mode)
		return FALSE

	var/list/adding_sites
	if(long_range)
		adding_sites = (GLOB.using_map.station_levels | GLOB.using_map.contact_levels | GLOB.using_map.player_levels)
	else
		adding_sites = GetConnectedZlevels(origin.z)

	if(LAZYLEN(adding_sites))
		LAZYDISTINCTADD(reachable_z_levels, adding_sites)
	return (target.z in reachable_z_levels)

/obj/item/device/gps/proc/update_compass(update_compass_icon)

	compass.hide_waypoints(FALSE)

	var/turf/my_turf = get_turf(src)
	for(var/thing in tracking_devices)
		var/obj/item/device/gps/gps = locate(thing)
		if(!istype(gps) || QDELETED(gps))
			LAZYREMOVE(tracking_devices, thing)
			LAZYREMOVE(showing_tracked_names, thing)
			continue

		var/turf/gps_turf = get_turf(gps)
		var/gps_tag = LAZYACCESS(showing_tracked_names, thing) ? gps.gps_tag : null
		if(istype(gps_turf))
			compass.set_waypoint("[REF(gps)]", gps_tag, gps_turf.x, gps_turf.y, gps_turf.z, LAZYACCESS(tracking_devices, "[REF(gps)]"))
			if(can_track(gps) && my_turf && gps_turf != my_turf)
				compass.show_waypoint("[REF(gps)]")

	compass.rebuild_overlay_lists(update_compass_icon)

/obj/item/device/gps/proc/toggle_tracking(mob/user)
	tracking = !tracking
	if(tracking)
		if(!is_in_processing_list)
			is_in_processing_list = TRUE
			START_PROCESSING(SSobj, src)
	else
		is_in_processing_list = FALSE
		STOP_PROCESSING(SSobj, src)

	update_compass()
	update_holder()
	update_icon()

/obj/item/device/gps/emp_act(severity)
	SHOULD_CALL_PARENT(FALSE)
	if(emped) // Without a fancy callback system, this will have to do.
		return
	if(tracking)
		toggle_tracking()
	/// In case emp_act gets called without any arguments.
	var/severity_modifier = severity ? severity : 4
	var/duration = 5 MINUTES / severity_modifier
	emped = TRUE
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(reset_emp)), duration)
	GLOB.empd_event.raise_event(src, severity)

/obj/item/device/gps/proc/reset_emp()
	emped = FALSE
	update_icon()
	if(ismob(loc))
		to_chat(loc, SPAN_NOTICE("\The [src] appears to be functional again."))

/obj/item/device/gps/on_update_icon()
	ClearOverlays()
	if(emped)
		AddOverlays("gps_emp")
	else if(tracking)
		AddOverlays("gps_on")

/obj/item/device/gps/attack_self(mob/user)
	tgui_interact(user)
	return TRUE

/obj/item/device/gps/tgui_state(mob/user)
	return GLOB.tgui_physical_state

/obj/item/device/gps/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GPS")
		ui.open()

/obj/item/device/gps/tgui_data(mob/user, ui_key)
	var/list/data = list()
	var/turf/curr = get_turf(src)
	var/area/my_area = get_area(src)
	var/z_level_detection

	data["tracking"] = tracking
	data["gps_tag"] = gps_tag
	data["area"] = strip_improper(my_area.name)
	data["can_hide_signal"] = can_hide_signal
	data["hide_signal"] = hide_signal
	data["curr_x"] = curr.x
	data["curr_y"] = curr.y
	data["curr_z"] = curr.z
	data["local_mode"] = local_mode
	data["emped"] = emped

	if(long_range)
		z_level_detection = (GLOB.using_map.station_levels | GLOB.using_map.contact_levels | GLOB.using_map.player_levels)
	else
		z_level_detection = GetConnectedZlevels(curr.z)

	var/list/gps_list = list()
	for(var/obj/item/device/gps/gps as anything in GLOB.gps_list)
		if(gps == src || !can_track(gps, z_level_detection))
			continue
		var/gps_ref = "[REF(gps)]"
		var/area/area = get_area(gps)
		var/turf/turf = get_turf(gps)
		gps_list += list(list(
			"gps_ref" = gps_ref,
			"gps_tag" = gps.gps_tag,
			"gps_area" = strip_improper(area.name),
			"being_tracked" = !!(gps_ref in tracking_devices),
			"degrees" = round(Get_Angle(curr,turf)),
			"distance" = round(get_dist(curr, turf), 10),
			"local" = curr.z == turf.z,
			"x" = turf.x,
			"y" = turf.y,
		))
	data["gps_list"] = gps_list

	return data

/obj/item/device/gps/tgui_act(action, list/params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("toggle_power")
			toggle_tracking()
			return TRUE
		if("stop_track")
			var/gps_ref = params["stop_track"]
			var/obj/item/device/gps/gps = locate(gps_ref)
			if(!istype(gps) && QDELETED(gps))
				return
			compass.clear_waypoint(gps_ref)
			LAZYREMOVE(tracking_devices, gps_ref)
			LAZYREMOVE(showing_tracked_names, gps_ref)
			update_compass()
			return TRUE
		if("start_track")
			var/gps_ref = params["start_track"]
			var/obj/item/device/gps/gps = locate(gps_ref)
			if(!istype(gps) && QDELETED(gps))
				return
			LAZYSET(tracking_devices, gps_ref, COLOR_SILVER)
			LAZYSET(showing_tracked_names, gps_ref, TRUE)
			update_compass()
			return TRUE
		if("track_color")
			var/obj/item/device/gps/gps = locate(params["track_color"])
			if(!istype(gps) && QDELETED(gps))
				return
			var/new_colour = input("Enter a new tracking color.", "GPS Waypoint Color") as color|null
			if(!new_colour && !istype(gps) && QDELETED(gps) && holder != usr && usr.incapacitated())
				return
			to_chat(usr, SPAN_NOTICE("You adjust the colour \the [src] is using to highlight [gps.gps_tag]."))
			LAZYSET(tracking_devices, params["track_color"], new_colour)
			update_compass()
			return TRUE
		if("tag")
			var/new_tag = uppertext(tgui_input_text(usr, "Please enter desired tag.", "GPS Tag", gps_tag, 11))
			if(!new_tag || !in_range(src, usr))
				return
			gps_tag = new_tag
			name = "[initial(name)] ([gps_tag])"
			return TRUE
		if("range")
			local_mode = !local_mode
			return TRUE
		if("hide")
			hide_signal = !hide_signal
			return TRUE

/obj/item/device/gps/AltClick(mob/user)
	toggle_tracking(user)
	return TRUE
