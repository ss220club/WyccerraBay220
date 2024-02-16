
/datum/preferences
	var/list/background_states = list("000", "FFF", MATERIAL_STEEL, "white")
	var/icon/bgstate = "000"
	/// Preference which defines whether to equip preview character with job equipment
	var/preview_job = TRUE
	/// Preference which defines whether to equip preview character with selected gear
	var/preview_gear = TRUE
	/// Assoc list of character previews as: dir => character_preview
	var/list/character_previews

/datum/preferences/Destroy()
	QDEL_NULL_ASSOC_LIST(character_previews)
	. = ..()


/datum/preferences/VV_static()
	. = ..()
	. += list(
		"background_states"
	)
	return .

/datum/preferences/proc/dress_preview_mob_with_gear(mob/living/carbon/human/mannequin, job_preview_type)
	var/datum/gear_slot/picked_slot = get_picked_gear_slot()
	var/list/gears = picked_slot.get_gear_entries()
	if(trying_on_gear)
		gears[trying_on_gear] = trying_on_tweaks.Copy()

	// Equip custom gear loadout, replacing any job items
	var/list/loadout_taken_slots = list()
	var/list/accessories = list()
	for(var/gear_name in gears)
		var/datum/gear/gear_to_try = gear_datums[gear_name]
		if(!gear_to_try)
			continue

		if(!gear_to_try.slot)
			continue

		if(length(gear_to_try.whitelisted) && !(mannequin.species.name in gear_to_try.whitelisted))
			continue

		if(length(gear_to_try.allowed_roles) && job_preview_type && !(job_preview_type in gear_to_try.allowed_roles))
			continue

		var/gear_equip_slot = gear_to_try.slot
		if(gear_equip_slot == slot_tie)
			accessories += gear_to_try
			continue

		if(gear_equip_slot in loadout_taken_slots)
			continue

		if(gear_to_try.spawn_on_mob(mannequin, picked_slot.get_gear_tweaks(gear_to_try.display_name)))
			loadout_taken_slots |= gear_equip_slot

	// equip accessories after other slots so they don't attach to a suit which will be replaced
	for(var/datum/gear/accessory as anything in accessories)
		accessory.spawn_as_accessory_on_mob(mannequin, gears[accessory.display_name])

	return length(accessories) || length(loadout_taken_slots)

/datum/preferences/proc/dress_preview_mob_with_job_equipment(mob/living/carbon/human/mannequin, datum/job/job_preview)
	mannequin.job = job_preview.title
	var/datum/mil_branch/branch = GLOB.mil_branches.get_branch(branches[job_preview.title])
	var/datum/mil_rank/rank = GLOB.mil_branches.get_rank(branches[job_preview.title], ranks[job_preview.title])
	job_preview.equip_preview(mannequin, player_alt_titles[job_preview.title], branch, rank)
	return TRUE

/datum/preferences/proc/dress_preview_mob(mob/living/carbon/human/mannequin)
	if(!mannequin)
		return

	var/update_icon = FALSE
	copy_to(mannequin, TRUE)
	if(!preview_job && !preview_gear)
		return

	var/datum/job/job_preview
	// Determine what job is marked as 'High' priority, and dress them up as such.
	if(GLOB.using_map.default_assistant_title in job_low)
		job_preview = SSjobs.get_by_title(GLOB.using_map.default_assistant_title)
	else
		job_preview = SSjobs.get_by_title(job_high)

	if(!job_preview && mannequin.icon)
		update_icon = TRUE // So we don't end up stuck with a borg/AI icon after setting their priority to non-high

	if(preview_job && job_preview)
		update_icon = dress_preview_mob_with_job_equipment(mannequin, job_preview)

	if(!(mannequin.species.appearance_flags && mannequin.species.appearance_flags & SPECIES_APPEARANCE_HAS_UNDERWEAR))
		if(all_underwear)
			all_underwear.Cut()

	var/job_preview_type = job_preview?.type
	if(preview_gear && !(job_preview && (job_preview_type == /datum/job/ai || job_preview_type == /datum/job/cyborg)))
		update_icon = dress_preview_mob_with_gear(mannequin, job_preview_type)

	if(update_icon)
		mannequin.update_icons()

/datum/preferences/proc/update_preview_icon()
	var/mob/mannequin = get_mannequin(client_ckey)
	mannequin.delete_inventory(TRUE)
	dress_preview_mob(mannequin)
	mannequin.ImmediateOverlayUpdate()

	if(client.mob)
		mannequin.forceMove(get_turf(client.mob))

	show_character_preview(mannequin)

/datum/preferences/proc/show_character_preview(mutable_appearance/char_appearance)
	var/vertical_position = 0
	for(var/dir in GLOB.cardinal)
		var/obj/screen/preview = LAZYACCESS(character_previews, "[dir]")
		if(!preview)
			preview = new
			LAZYSET(character_previews, "[dir]", preview)

			if(client)
				client.screen |= preview

		preview.appearance = char_appearance
		preview.dir = dir
		preview.screen_loc = "character_preview_map:0,[++vertical_position]"

/datum/category_item/player_setup_item/physical/preview
	name = "Preview"
	sort_order = 5


/datum/category_item/player_setup_item/physical/preview/load_character(datum/pref_record_reader/R)
	pref.bgstate = R.read("bgstate")
	pref.update_preview_icon()


/datum/category_item/player_setup_item/physical/preview/save_character(datum/pref_record_writer/W)
	W.write("bgstate", pref.bgstate)


/datum/category_item/player_setup_item/physical/preview/sanitize_character()
	if(!pref.bgstate || !(pref.bgstate in pref.background_states))
		pref.bgstate = pref.background_states[1]


/datum/category_item/player_setup_item/physical/preview/OnTopic(query_text, list/query, mob/user)
	if (!query)
		return
	else if (query["cyclebg"])
		var/index = pref.background_states.Find(pref.bgstate)
		if (!index || index == length(pref.background_states))
			pref.bgstate = pref.background_states[1]
		else
			pref.bgstate = pref.background_states[index + 1]
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if (query["resize"])
		pref.client?.cycle_preference(/datum/client_preference/preview_scale)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if (query["job_preview"])
		pref.preview_job = !pref.preview_job
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if (query["previewgear"])
		pref.preview_gear = !pref.preview_gear
		return TOPIC_REFRESH_UPDATE_PREVIEW
	return ..()


// /datum/category_item/player_setup_item/physical/preview/content(mob/user)
// 	if(!pref.preview_icon)
// 		pref.update_preview_icon()
// 	send_rsc(user, pref.preview_icon, "previewicon.png")
// 	var/width = pref.preview_icon.Width()
// 	var/height = pref.preview_icon.Height()
// 	. = "<b>Preview:</b>"
// 	. += "<br />[BTN("cyclebg", "Cycle Background")]"
// 	. += " - [BTN("previewgear", "[pref.preview_gear ? "Hide" : "Show"] Loadout")]"
// 	. += " - [BTN("job_preview", "[pref.preview_job ? "Hide" : "Show"] Uniform")]"
// 	. += " - [BTN("resize", "Resize")]"
// 	. += {"<br /><div class="statusDisplay" style="text-align:center"><img src="previewicon.png" width="[width]" height="[height]"></div>"}
