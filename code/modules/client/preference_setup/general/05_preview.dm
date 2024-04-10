#define CHARACTER_PREVIEW_MAP_CONTROL_ID "character_preview_map"

/datum/preferences
	/// Preference which defines whether to equip preview character with job equipment
	var/preview_job = TRUE
	/// Preference which defines whether to equip preview character with selected gear
	var/preview_gear = TRUE
	/// Height of the icon on preview
	var/preview_character_height = WORLD_ICON_SIZE
	/// Preview background currently set. Must be one of the keys from `character_preview_backgrounds` list
	var/background_icon_name = "steel"
	/// List of character preview as: dir => preview
	var/list/character_previews
	/// List of cached background icons, scaled for different sizes as: `size => list(icon_name => /icon)`
	var/static/list/preview_backgrounds_cache = list()
	/// Pool of icons for character preview background
	var/static/list/character_preview_backgrounds = list(
		"steel" = icon('icons/turf/flooring/tiles.dmi', "steel"),
		"tiled_light" = icon('icons/turf/flooring/tiles.dmi', "tiled_light"),
		"reinforced_light" = icon('icons/turf/flooring/tiles.dmi', "reinforced_light"),
	)

/datum/preferences/Destroy()
	QDEL_NULL_ASSOC_LIST(character_previews)
	. = ..()

/datum/preferences/proc/dress_preview_mob_with_gear(mob/living/carbon/human/mannequin, job_preview_type)
	var/datum/gear_slot/picked_slot = get_picked_gear_slot()
	var/list/gears = picked_slot.get_gear_entries()
	if(trying_on_gear)
		gears[trying_on_gear] = trying_on_tweaks.Copy()

	// Equip custom gear loadout, replacing any job items
	var/list/loadout_taken_slots = list()
	var/list/accessories = list()
	for(var/gear_name in gears)
		var/datum/gear/gear_to_try = GLOB.gear_datums[gear_name]
		if(!gear_to_try?.slot)
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

	var/datum/job/job_preview_type = job_preview?.type
	if(preview_job && job_preview && job_preview_type && initial(job_preview_type.display_outfit_on_preview))
		update_icon = dress_preview_mob_with_job_equipment(mannequin, job_preview)

	if(!(mannequin.species.appearance_flags && mannequin.species.appearance_flags & SPECIES_APPEARANCE_HAS_UNDERWEAR))
		if(all_underwear)
			all_underwear.Cut()

	if(preview_gear)
		update_icon = dress_preview_mob_with_gear(mannequin, job_preview_type)

	if(update_icon)
		mannequin.update_icons()

/datum/preferences/proc/update_preview_icon()
	var/mob/living/carbon/human/dummy/mannequin = get_mannequin(client_ckey)
	mannequin.delete_inventory(TRUE)
	dress_preview_mob(mannequin)
	mannequin.ImmediateOverlayUpdate()

	/// Due to how maps work in BYOND, we should have total height of preview icons multiples of `world.icon_size`.
	/// Otherwise part of the map will be empty.
	var/normalized_icon_height = (ceil((mannequin.icon_height * 4 ) / WORLD_ICON_SIZE) * WORLD_ICON_SIZE) / 4
	preview_character_height = normalized_icon_height
	show_character_preview(mannequin)

/datum/preferences/proc/show_character_preview(mutable_appearance/char_appearance)
	PRIVATE_PROC(TRUE)

	var/char_height_ratio = preview_character_height / WORLD_ICON_SIZE
	var/preview_character_index = 0
	var/icon/background_icon = get_scaled_preview_background_icon()
	for(var/dir in GLOB.cardinal)
		var/screen_loc = "[CHARACTER_PREVIEW_MAP_CONTROL_ID]:0,[char_height_ratio * preview_character_index]"
		var/datum/character_preview/preview = LAZYACCESS(character_previews, "[dir]")
		if(!preview)
			var/obj/screen/background_preview = generate_character_preview_background(screen_loc, background_icon)
			var/obj/screen/character_preview = generate_character_preview(dir, char_appearance, screen_loc)
			preview = new(background_preview, character_preview)
			LAZYSET(character_previews, "[dir]", preview)

		preview.update_character(char_appearance, dir, screen_loc)
		preview.update_background(screen_loc, background_icon)
		preview.show_to(client)
		preview_character_index++

/datum/preferences/proc/clear_character_preview()
	PRIVATE_PROC(TRUE)

	for(var/dir in character_previews)
		var/datum/character_preview/preview = character_previews[dir]
		if(!preview)
			continue

		preview.hide_from(client)

		qdel(preview)

	character_previews = null

/datum/preferences/proc/get_scaled_preview_background_icon()
	PRIVATE_PROC(TRUE)
	RETURN_TYPE(/icon)

	var/icon/result_icon = character_preview_backgrounds[background_icon_name]
	if(!result_icon)
		background_icon_name = pick(character_preview_backgrounds)
		result_icon = character_preview_backgrounds[background_icon_name]

	if(preview_character_height == WORLD_ICON_SIZE)
		return result_icon

	var/icon/scaled_icon = LAZYACCESS(preview_backgrounds_cache["[preview_character_height]"], background_icon_name)
	if(!scaled_icon)
		scaled_icon = icon(result_icon)
		scaled_icon.Scale(scaled_icon.Width(), preview_character_height)
		LAZYSET(preview_backgrounds_cache["[preview_character_height]"], background_icon_name, scaled_icon)

	return scaled_icon

/datum/preferences/proc/generate_character_preview(mutable_appearance/char_appearance, dir, screen_loc)
	PRIVATE_PROC(TRUE)
	RETURN_TYPE(/obj/screen)

	var/obj/screen/character_preview = new
	character_preview.appearance = char_appearance
	character_preview.plane = HUD_PLANE
	character_preview.dir = dir
	character_preview.screen_loc = screen_loc

	return character_preview

/datum/preferences/proc/generate_character_preview_background(screen_loc, icon/background_icon)
	PRIVATE_PROC(TRUE)
	RETURN_TYPE(/obj/screen)

	var/obj/screen/background = new
	background.layer = UNDER_HUD_LAYER
	background.icon = background_icon
	background.screen_loc = screen_loc

	return background

/datum/preferences/proc/update_preview_background_icon()
	var/icon/new_icon = get_scaled_preview_background_icon()
	for(var/dir in character_previews)
		var/datum/character_preview/preview = character_previews[dir]
		if(!preview)
			stack_trace("Character preview is missing for dir: `[dir]`")
			continue

		preview.update_background_icon(new_icon)

/datum/category_item/player_setup_item/physical/preview
	name = "Preview"
	sort_order = 5

/datum/category_item/player_setup_item/physical/preview/OnTopic(query_text, list/query, mob/user)
	if (!query)
		return

	if (query["job_preview"])
		pref.preview_job = !pref.preview_job
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if (query["previewgear"])
		pref.preview_gear = !pref.preview_gear
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(query["set_preview_background"])
		var/background_name = query["set_preview_background"]
		if(pref.background_icon_name == background_name || !pref.character_preview_backgrounds[background_name])
			return TOPIC_NOACTION

		pref.background_icon_name = background_name
		return TOPIC_REFRESH_UPDATE_PREVIEW_BACKGROUND_ICON

	return ..()

/datum/category_item/player_setup_item/physical/preview/content(mob/user)
	var/datum/asset/character_preview_asset = get_asset_datum(/datum/asset/simple/character_preview)
	character_preview_asset.send(user)

	. = "<b>Preview Toggles:</b>"
	. += "<br>[BTN("previewgear", "[pref.preview_gear ? "Hide" : "Show"] Loadout")]"
	. += " - [BTN("job_preview", "[pref.preview_job ? "Hide" : "Show"] Uniform")]"
	. += "<br>"
	. += "<b>Preview Background:</b><br>"
	for(var/background_name in pref.character_preview_backgrounds)
		. += VCBTN( \
			"set_preview_background", \
			background_name, \
			"<img style='width: 48px; height: 48px' class='background_tile' src='[SSassets.transport.get_asset_url(background_name)]'>", \
			"image_button [background_name == pref.background_icon_name ? "linkOn" : ""]")

/datum/category_item/player_setup_item/physical/preview/load_preferences(datum/pref_record_reader/R)
	pref.preview_job = R.read("preview_job")
	pref.preview_gear = R.read("preview_gear")
	pref.background_icon_name = R.read("background_icon_name")

/datum/category_item/player_setup_item/physical/preview/save_preferences(datum/pref_record_writer/W)
	W.write("preview_job", pref.preview_job)
	W.write("preview_gear", pref.preview_gear)
	W.write("background_icon_name", pref.background_icon_name)

/datum/character_preview
	/// Background of the character preview image
	VAR_PRIVATE/obj/screen/background
	/// Character preview image
	VAR_PRIVATE/obj/screen/character

/datum/character_preview/New(obj/screen/background, obj/screen/character)
	ASSERT(istype(background))
	ASSERT(istype(character))

	src.background = background
	src.character = character

/datum/character_preview/Destroy()
	QDEL_NULL(background)
	QDEL_NULL(character)
	. = ..()

/datum/character_preview/proc/update_character(mutable_appearance/appearence, dir, screen_loc)
	ASSERT(appearence)
	ASSERT(dir)
	ASSERT(screen_loc)

	character.appearance = appearence
	character.dir = dir
	character.plane = HUD_PLANE
	character.screen_loc = screen_loc

/datum/character_preview/proc/update_background(screen_loc, icon/new_icon)
	background.screen_loc = screen_loc
	update_background_icon(new_icon)

/datum/character_preview/proc/update_background_icon(icon/new_icon)
	background.icon = new_icon

/datum/character_preview/proc/show_to(client/client)
	client = resolve_client(client)
	if(!client)
		return

	client.screen += background
	client.screen += character

/datum/character_preview/proc/hide_from(client/client)
	client = resolve_client(client)
	if(!client)
		return

	client.screen -= background
	client.screen -= character

#undef CHARACTER_PREVIEW_MAP_CONTROL_ID
