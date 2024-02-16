GLOBAL_DATUM_INIT(orbit_menu, /datum/orbit_menu, new)

/datum/orbit_menu

/datum/orbit_menu/tgui_state(mob/user)
	return GLOB.tgui_observer_state

/datum/orbit_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Orbit")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/orbit_menu/tgui_act(action, list/params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("orbit")
			var/datum/follow_holder/follow_holder = locate(params["ref"]) in get_follow_targets()
			var/atom/movable/atom = follow_holder.followed_instance
			var/mob/observer/ghost/ghost = usr
			if(atom != usr)
				ghost.start_following(atom)
			return TRUE
		if("refresh")
			update_tgui_static_data()
			return TRUE

/datum/orbit_menu/tgui_static_data(mob/user)
	var/list/data = list()
	data["misc"] = list()
	data["ghosts"] = list()
	data["dead"] = list()
	data["npcs"] = list()
	data["alive"] = list()
	data["antagonists"] = list()
	for(var/datum/follow_holder/follow_holder in get_follow_targets())
		var/atom/movable/follow_instance = follow_holder.followed_instance
		var/list/serialized = list()
		serialized["name"] = follow_instance.name
		serialized["ref"] = "[REF(follow_holder)]"

		if(!istype(follow_instance, /mob))
			data["misc"] += list(serialized)
			continue
		var/mob/mob = follow_instance
		if(isobserver(mob))
			data["ghosts"] += list(serialized)
			continue

		if(mob.stat == DEAD)
			data["dead"] += list(serialized)
			continue

		if(mob.mind == null)
			data["npcs"] += list(serialized)
			continue

		data["alive"] += list(serialized)

		var/mob/observer/ghost/observer = user
		if(observer.antagHUD && mob.get_antag_info())
			var/antag_serialized = serialized.Copy()
			for(var/antag_category in mob.get_antag_info())
				antag_serialized["antag"] += list(antag_category)
			data["antagonists"] += list(antag_serialized)

	return data

/// Shows the UI to the specified user.
/datum/orbit_menu/proc/show(mob/user)
	tgui_interact(user)
