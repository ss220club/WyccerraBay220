var/global/list/gear_categories = list()
var/global/list/gear_datums = list()

/hook/startup/proc/populate_gear_list()
	for(var/datum/gear/gear_type as anything in subtypesof(/datum/gear))
		if(is_abstract(gear_type))
			continue

		if(length(GLOB.using_map.loadout_blacklist) && GLOB.using_map.loadout_blacklist[gear_type])
			continue

		var/datum/gear/new_gear = new gear_type
		gear_datums[new_gear.display_name] = new_gear

		var/datum/gear_category/category = gear_categories[new_gear.category]
		if(!category)
			category = new /datum/gear_category(new_gear.category)
			gear_categories[new_gear.category] = category

		category.add_gear(new_gear)

	gear_categories = sortAssoc(gear_categories)

	for(var/gear_category in gear_categories)
		var/datum/gear_category/category = gear_categories[gear_category]
		category.sort_gear()

	return TRUE

/datum/preferences
	var/datum/gear_slots_container/gear_container

/datum/preferences/proc/Gear()
	var/datum/gear_slot/picked_gear_slot = get_picked_gear_slot()
	if(!picked_gear_slot)
		return list()

	return picked_gear_slot.get_gear_entries()

/datum/preferences/proc/get_picked_gear_slot()
	if(!gear_container)
		stack_trace("`gear_container` is null")
		gear_container = new

	return gear_container.get_picked_gear_slot()

/datum/category_item/player_setup_item/loadout
	name = "Loadout"
	sort_order = 1
	var/current_tab = "General"
	var/hide_unavailable_gear = 0
	var/hide_donate_gear = FALSE
	var/datum/gear/selected_gear
	var/list/selected_tweaks = list()
	var/static/list/gear_icons_cache

/datum/category_item/player_setup_item/loadout/load_character(datum/pref_record_reader/R)
	pref.gear_container = new(R.read("gear_container_size"), R.read("picked_gear_slot"), R.read("gear_slots"))

/datum/category_item/player_setup_item/loadout/save_character(datum/pref_record_writer/W)
	var/list/gear_slots = list()
	for(var/datum/gear_slot/slot as anything in pref.gear_container.get_gear_slots())
		gear_slots += list(slot.get_gear_entries())

	W.write("gear_container_size", pref.gear_container.get_size())
	W.write("picked_gear_slot", pref.gear_container.get_picked_gear_slot_number())
	W.write("gear_slots", gear_slots)

/datum/category_item/player_setup_item/loadout/proc/is_gear_valid(gear_name, max_cost)
	var/datum/gear/gear_to_check = gear_name
	if(!istype(gear_to_check))
		gear_to_check = gear_datums[gear_to_check]

	if(!gear_to_check)
		return FALSE

	if(!isnull(max_cost) && gear_to_check.cost > max_cost)
		return FALSE

	if(!gear_to_check.allowed_donation_tier(pref.client))
		return FALSE

	if(!length(gear_to_check.whitelisted))
		return TRUE

	return is_any_alien_whitelisted(preference_mob(), gear_to_check.whitelisted)

/datum/category_item/player_setup_item/loadout/proc/skill_check(list/jobs, list/skills_required)
	for(var/datum/job/J as anything in jobs)
		. = TRUE
		for(var/R in skills_required)
			if(pref.get_total_skill_value(J, R) < skills_required[R])
				. = FALSE
				break
		if(.)
			return

/datum/category_item/player_setup_item/loadout/sanitize_character()
	if(!pref.gear_container)
		pref.gear_container = new

	var/datum/gear_slots_container/gear_container = pref.gear_container
	gear_container.set_size(config.loadout_slots)

	for(var/datum/gear_slot/current_gear_slot as anything in gear_container.get_gear_slots())
		var/list/gear_entries = current_gear_slot.get_gear_entries()
		if(!length(gear_entries))
			continue

		var/gear_budget_left = config.max_gear_cost
		var/list/invalid_gear = list()

		/// Filtering out invalid slots
		for(var/gear_name in gear_entries)
			var/datum/gear/gear_datum = gear_datums[gear_name]
			if(!is_gear_valid(gear_datum, gear_budget_left))
				invalid_gear += gear_datum.display_name
				continue

			gear_budget_left -= gear_datum.cost

		/// Here we just set filtered gear names to slot
		current_gear_slot.remove_gear(invalid_gear)

/datum/category_item/player_setup_item/loadout/content(mob/user)
	. = list()

	if(!user.client)
		return .

	var/datum/gear_slot/picked_slot = pref.get_picked_gear_slot()
	if(!picked_slot)
		stack_trace("Something went wrong. `picked_slot` should not be null")
		return .

	var/gear_total_cost = picked_slot.get_total_gear_cost()
	var/gear_points_left = config.max_gear_cost - gear_total_cost
	var/fcolor = gear_total_cost < config.max_gear_cost ? "#e67300" : "#3366cc"

	. += "<table style='width: 100%;'><tr>"
	. += "<table style='white-space: nowrap;'><tr>"
	. += "<td style=\"vertical-align: top;\">"

	. += "<td>"

	. += "<b>Loadout Set: [BTN("prev_slot", "&lt;&lt;")]<b><font color = '[fcolor]'>\[[picked_slot.get_slot_number()]\]</font></b>[BTN("next_slot", "&gt;&gt;")]</b>"
	var/donation_tier = user.client.donator_info.get_full_donation_tier()

	. += "<td>"
	. += "<b>Donation tier:</b> [donation_tier]<br>"
	. += CBTN("donate", "Support us!", "gold")
	. += "</td>"

	. += "</td>"

	if(config.max_gear_cost < INFINITY)
		. += "<font color = '[fcolor]'>[gear_total_cost]/[config.max_gear_cost]</font> loadout points spent.<br>"

	. += BTN("clear_loadout", "Clear Loadout")
	. += BTN("random_loadout", "Random Loadout")
	. += BTN("toggle_hiding", hide_unavailable_gear ? "Show unavailable" : "Hide unavailable")
	. += BTN("toggle_donate", hide_donate_gear ? "Show donate gears" : "Hide donate gears")
	. += "</td>"

	. += "</tr></table>"
	. += "</td>"

	. += "</tr></table>"

	. += "<table style='height: 100%;'>"

	. += "<tr>"
	. += "<td><b>Categories:</b></td>"
	. += "<td><b>Gears:</b></td>"
	if(selected_gear)
		. += "<td><b>Selected Item:</b></td>"
	. += "</tr>"

	. += "<tr style='vertical-align: top;'>"

	// Categories

	. += "<td style='white-space: nowrap; width: 40px;' class='block'><b>"
	for(var/category_name in gear_categories)
		var/datum/gear_category/category = gear_categories[category_name]
		var/category_cost = 0
		for(var/gear_name in category.get_gear_items())
			if(!picked_slot.contains(gear_name))
				continue

			var/datum/gear/gear_datum = gear_datums[gear_name]
			category_cost += gear_datum.cost

		var/category_class = category_cost ? "linkOn" : ""
		if(category_name == current_tab)
			category_class += " selected"

		. += VCBTN("select_category", category_name, "[category_name] - [category_cost || 0]", "[category_class] fluid")

	. += "</b></td>"

	// Gears

	. += "<td style='white-space: nowrap; width: 40px;' class='block'>"
	. += "<table>"

	var/list/purchased_gears = list()
	var/list/paid_gears = list()
	var/list/not_paid_gears = list()
	var/datum/gear_category/current_category = gear_categories[current_tab]

	for(var/gear_name in current_category.get_gear_items())
		if(!is_gear_valid(gear_name))
			continue

		var/datum/gear/gear_datum = gear_datums[gear_name]
		if(!gear_datum?.path)
			continue

		if(hide_donate_gear && gear_datum.donation_tier)
			continue

		var/ticked = picked_slot.contains(gear_name)


		var/display_class = ""
		var/allowed_to_see = gear_allowed_to_see(gear_datum)

		if(ticked)
			display_class = "linkOn"

		else if(!gear_datum.allowed_donation_tier(user) && gear_datum.donation_tier)
			display_class = "gold"

		else if(!allowed_to_see)
			display_class = "gray"

		else if(length(gear_datum.whitelisted))
			display_class = "violet"

		if(gear_datum == selected_gear)
			display_class += " selected"

		if(!hide_unavailable_gear || allowed_to_see || ticked)

			var/entry = {"
				<tr>
				<td width=25%>[VCBTN("select_gear", gear_datum.display_name, gear_datum.display_name, "[display_class] fluid")]</td>
				</td></tr>
			"}

			if(gear_datum.donation_tier && user.client.donator_info.donation_tier_available(gear_datum.donation_tier))
				purchased_gears += entry
				continue

			if(gear_datum.donation_tier)
				paid_gears += entry
				continue

			not_paid_gears += entry

	. += purchased_gears.Join()
	. += paid_gears.Join()
	. += not_paid_gears.Join()

	. += "</table>"
	. += "</td>"

	// Selected gear

	if(selected_gear)
		var/ticked = picked_slot.contains(selected_gear.display_name)

		var/datum/gear_data/gear_data_to_tweak = new(selected_gear.path)
		for(var/datum/gear_tweak/gear_tweak_to_apply as anything in selected_gear.gear_tweaks)
			gear_tweak_to_apply.tweak_gear_data(selected_tweaks["[gear_tweak_to_apply]"], gear_data_to_tweak)

		var/atom/movable/gear_virtual_item = new gear_data_to_tweak.path
		for(var/datum/gear_tweak/gear_tweak_to_apply as anything in selected_gear.gear_tweaks)
			gear_tweak_to_apply.tweak_item(user, gear_virtual_item, selected_tweaks["[gear_tweak_to_apply]"])

		var/gear_image = get_gear_image(gear_virtual_item, user)

		QDEL_NULL(gear_virtual_item)

		. += "<td style='width: 80%;' class='block'>"

		. += "<table><tr>"

		. += "<td>[gear_image]</td>"

		. += "<td style='vertical-align: top;'>"
		. += "<b>[selected_gear.display_name]</b>"

		var/desc = selected_gear.get_description(selected_tweaks)
		if(desc)
			. += "<br>"
			. += desc

		. += "</td>"
		. += "</tr></table>"

		if(selected_gear.slot)
			var/slot_description = GLOB.slot_descriptions["[selected_gear.slot]"]
			if(slot_description)
				. += "<b>Slot:</b> [slot_description]<br>"
		. += "<b>Loadout Points:</b> <font class='[gear_points_left >= selected_gear.cost ? "good" : "bad"]'>[selected_gear.cost]</font><br>"

		var/list/selected_jobs = list()
		for(var/job_title in (pref.job_medium|pref.job_low|pref.job_high))
			var/datum/job/job_datum = SSjobs.get_by_title(job_title)
			if(!job_datum)
				continue

			BINARY_INSERT(job_datum, selected_jobs, /datum/job, job_datum, title, COMPARE_KEY)

		if(length(selected_gear.allowed_roles))
			. += "<b>Has jobs restrictions:</b>"
			. += "<br>"
			. += "<i>"
			var/ind = 0
			for(var/allowed_type in selected_gear.allowed_roles)
				if(!ispath(allowed_type, /datum/job))
					log_warning("There is an object called '[allowed_type]' in the list of whitelisted jobs for a gear '[selected_gear.display_name]'. It's not /datum/job.")
					continue
				var/datum/job/J = SSjobs.get_by_path(allowed_type) || new allowed_type
				++ind
				if(ind > 1)
					. += ", "
				if(length(selected_jobs) && (J in selected_jobs))
					. += SPAN_COLOR("#55cc55", J.title)
				else
					. += SPAN_COLOR("#808080", J.title)
			. += "</i>"
			. += "<br>"

		if(length(selected_gear.allowed_branches))
			. += "<b>Has jobs restrictions:</b>"
			. += "<br>"
			. += "<i>"
			var/list/branches = list()
			for(var/datum/job/J in selected_jobs)
				if(pref.branches[J.title])
					branches |= pref.branches[J.title]

			var/ind = 0
			for(var/branch in branches)
				++ind
				if(ind > 1)
					. += ", "
				var/datum/mil_branch/player_branch = GLOB.mil_branches.get_branch(branch)
				if(player_branch.type in selected_gear.allowed_branches)
					. += SPAN_COLOR("#55cc55", player_branch.name)
				else
					. += SPAN_COLOR("#808080", player_branch.name)

			. += "</i>"
			. += "<br>"

		if(length(selected_gear.required_skills))
			. += "<b>Has skills restrictions:</b>"
			. += "<br>"
			. += "<i>"
			var/list/skills_required = list()//make it into instances? instead of path
			for(var/skill in selected_gear.required_skills)
				var/singleton/hierarchy/skill/instance = GET_SINGLETON(skill)
				skills_required[instance] = selected_gear.required_skills[skill]

			var/allowed = skill_check(selected_jobs, skills_required)//Checks if a single job has all the skills required
			var/ind = 0
			for(var/skill in skills_required)
				var/singleton/hierarchy/skill/S = skill
				++ind
				if(ind > 1)
					. += ", "
				if(allowed)
					. += SPAN_COLOR("#55cc55", "[S.levels[skills_required[skill]]] [skill]")
				else
					. += SPAN_COLOR("#808080", "[S.levels[skills_required[skill]]] [skill]")
			. += "</i>"
			. += "<br>"

		if(length(selected_gear.required_factions))
			. += "<b>Has faction restrictions:</b>"
			. += "<br>"
			. += "<i>"
			var/singleton/cultural_info/faction = SSculture.get_culture(pref.cultural_info[TAG_FACTION])
			var/facname = faction ? faction.name : "Unset"

			if(facname in selected_gear.required_factions)
				. += SPAN_COLOR("#55cc55", facname)
			else
				. += SPAN_COLOR("#808080", facname)

			. += "</i>"
			. += "<br>"

		if(selected_gear.whitelisted)
			. += "<b>Has species restrictions:</b>"
			. += "<br>"
			. += "<i>"

			if(!istype(selected_gear.whitelisted, /list))
				selected_gear.whitelisted = list(selected_gear.whitelisted)

			var/ind = 0
			for(var/allowed_species in selected_gear.whitelisted)
				++ind
				if(ind > 1)
					. += ", "
				if(pref.species && pref.species == allowed_species)
					. += "<font color='#55cc55'>[allowed_species]</font>"
				else
					. += "<font color='#808080'>[allowed_species]</font>"
			. += "</i>"
			. += "<br>"

		if(selected_gear.donation_tier)
			. += "<br>"
			. += "<b>Donation tier required: [donation_tier_decorated(selected_gear.donation_tier)]</b>"
			. += "<br>"

		// Tweaks
		if(length(selected_gear.gear_tweaks))
			. += "<br><b>Options:</b><br>"
			for(var/datum/gear_tweak/tweak in selected_gear.gear_tweaks)
				var/tweak_contents = tweak.get_contents(selected_tweaks["[tweak]"])
				if(tweak_contents)
					. += VBTN("tweak", ref(tweak), tweak_contents)
					. += "<br>"

		. += "<br>"

		. += "<br><b>Actions:</b><br>"
		var/not_available_message = SPAN_NOTICE("This item will never spawn with you, using your current preferences.")
		if(selected_gear.allowed_donation_tier(user))
			var/class = ticked ? "linkOn" : (gear_points_left >= selected_gear.cost ? "" : "linkOff")
			var/label = ticked ? "Drop" : "Take"
			. += VCBTN("toggle_gear", selected_gear.display_name, label, class)
		else
			var/trying_on = (pref.trying_on_gear == selected_gear.display_name)
			if(selected_gear.donation_tier)
				var/class = trying_on ? "class='linkOn' " : ""
				. += CBTN("try_on", "Try On", class)
			else
				. += not_available_message

		if(!gear_allowed_to_see(selected_gear))
			. += "<br>"
			. += not_available_message

		. += "</td>"

	. += "</tr></table>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/loadout/proc/get_gear_metadata(datum/gear/our_gear)
	if(!our_gear)
		stack_trace("`our_gear` should not be null")
		return list()

	var/datum/gear_slot/picked_gear_slot = pref.get_picked_gear_slot()
	return picked_gear_slot.get_gear_tweaks(our_gear.display_name)

/datum/category_item/player_setup_item/loadout/proc/get_tweak_metadata(datum/gear/G, datum/gear_tweak/tweak)
	var/list/metadata = get_gear_metadata(G)
	. = metadata["[tweak]"]
	if(!.)
		. = tweak.get_default()
		metadata["[tweak]"] = .

/datum/category_item/player_setup_item/loadout/proc/set_tweak_metadata(datum/gear/G, datum/gear_tweak/tweak, new_metadata)
	var/list/metadata = get_gear_metadata(G)
	metadata["[tweak]"] = new_metadata

/datum/category_item/player_setup_item/loadout/OnTopic(href, list/href_list, mob/user)
	ASSERT(istype(user))

	if(href_list["toggle_gear"])
		if(toggle_gear(gear_datums[href_list["toggle_gear"]], user))
			return TOPIC_REFRESH_UPDATE_PREVIEW

		return TOPIC_NOACTION

	if(href_list["next_slot"])
		if(pref.gear_container.cycle_slot_right())
			return TOPIC_REFRESH_UPDATE_PREVIEW

		return TOPIC_NOACTION

	if(href_list["prev_slot"])
		if(pref.gear_container.cycle_slot_left())
			return TOPIC_REFRESH_UPDATE_PREVIEW

		return TOPIC_NOACTION

	if(href_list["select_category"])
		var/new_tab = href_list["select_category"]
		if(new_tab == current_tab)
			return TOPIC_NOACTION

		current_tab = new_tab
		return TOPIC_REFRESH

	if(href_list["clear_loadout"])
		var/datum/gear_slot/picked_gear_slot = pref.get_picked_gear_slot()
		if(!picked_gear_slot.size())
			return TOPIC_NOACTION

		picked_gear_slot.clear()
		return TOPIC_REFRESH_UPDATE_PREVIEW

	if(href_list["toggle_hiding"])
		hide_unavailable_gear = !hide_unavailable_gear
		return TOPIC_REFRESH

	if(href_list["select_gear"])
		var/datum/gear/gear_to_select = gear_datums[href_list["select_gear"]]
		if(!gear_to_select)
			return TOPIC_NOACTION

		selected_gear = gear_to_select
		var/datum/gear_slot/picked_gear_slot = pref.get_picked_gear_slot()

		selected_tweaks = picked_gear_slot.get_gear_tweaks(selected_gear.display_name)
		if(!length(selected_tweaks))
			for(var/datum/gear_tweak/tweak as anything in selected_gear.gear_tweaks)
				selected_tweaks["[tweak]"] = tweak.get_default()

		pref.trying_on_gear = null
		pref.trying_on_tweaks.Cut()
		return TOPIC_REFRESH_UPDATE_PREVIEW

	if(href_list["tweak"])
		var/datum/gear_tweak/tweak = locate(href_list["tweak"])
		if(!tweak || !istype(selected_gear) || !(tweak in selected_gear.gear_tweaks))
			return TOPIC_NOACTION

		var/metadata = tweak.get_metadata(user, get_tweak_metadata(selected_gear, tweak))
		if(!metadata || !CanUseTopic(user))
			return TOPIC_NOACTION

		selected_tweaks["[tweak]"] = metadata

		var/datum/gear_slot/picked_slot = pref.get_picked_gear_slot()
		var/ticked = picked_slot.contains(selected_gear.display_name)
		if(ticked)
			set_tweak_metadata(selected_gear, tweak, metadata)

		var/trying_on = (selected_gear.display_name == pref.trying_on_gear)
		if(trying_on)
			pref.trying_on_tweaks["[tweak]"] = metadata

		return TOPIC_REFRESH_UPDATE_PREVIEW

	if(href_list["try_on"])
		if(!istype(selected_gear))
			return TOPIC_NOACTION

		if(selected_gear.display_name == pref.trying_on_gear)
			pref.trying_on_gear = null
			pref.trying_on_tweaks.Cut()
		else
			pref.trying_on_gear = selected_gear.display_name
			pref.trying_on_tweaks = selected_tweaks.Copy()

		return TOPIC_REFRESH_UPDATE_PREVIEW

	if(href_list["random_loadout"])
		randomize(user)
		return TOPIC_REFRESH_UPDATE_PREVIEW

	if(href_list["toggle_donate"])
		hide_donate_gear = !hide_donate_gear
		return TOPIC_REFRESH

	if(href_list["donate"])
		var/singleton/modpack/don_loadout/donations = GET_SINGLETON(/singleton/modpack/don_loadout)
		donations.show_donations_info(user)
		return TOPIC_NOACTION

	return ..()

/datum/category_item/player_setup_item/loadout/proc/randomize(mob/user)
	ASSERT(user)

	pref.trying_on_gear = null
	pref.trying_on_tweaks.Cut()

	var/datum/gear_slot/current_slot = pref.get_picked_gear_slot()
	current_slot.clear()

	var/list/pool = list()
	for(var/gear_name in gear_datums)
		var/datum/gear/gear_datum = gear_datums[gear_name]
		if(gear_allowed_to_see(gear_datum) && is_gear_valid(gear_datum))
			pool += gear_datum

	var/points_left = config.max_gear_cost

	while (points_left > 0 && length(pool))
		var/datum/gear/chosen = pick(pool)
		var/list/chosen_tweaks = list()

		for(var/datum/gear_tweak/tweak in chosen.gear_tweaks)
			chosen_tweaks["[tweak]"] = tweak.get_random()

		current_slot.add_gear(chosen.display_name, chosen_tweaks)
		points_left -= chosen.cost

		for(var/datum/gear/gear_datum as anything in pool)
			if(gear_datum.cost <= points_left && gear_datum.slot != chosen.slot)
				continue

			pool -= gear_datum

/datum/category_item/player_setup_item/loadout/proc/gear_allowed_to_see(datum/gear/G)
	ASSERT(G)
	if(!G.path)
		return FALSE

	if(length(G.allowed_roles) || length(G.required_skills) || length(G.allowed_branches))
		// Branches are dependent on jobs so here it is
		ASSERT(SSjobs.initialized)
		var/list/jobs = new
		for(var/job_title in (pref.job_medium|pref.job_low|pref.job_high))
			if(SSjobs.get_by_title(job_title))
				jobs += SSjobs.get_by_title(job_title)

		// No jobs = Fail
		// No jobs = No skills = No branches = Fail
		if(!jobs || !length(jobs))
			return FALSE

		if (length(G.allowed_roles))
			var/job_ok = FALSE
			for(var/datum/job/J in jobs)
				if(J.type in G.allowed_roles)
					job_ok = TRUE
					break
			if(!job_ok)
				return FALSE

		if (length(G.required_skills))
			var/list/skills_required = list()
			for(var/skill in G.required_skills)
				var/singleton/hierarchy/skill/instance = GET_SINGLETON(skill)
				skills_required[instance] = G.required_skills[skill]
			if (!skill_check(jobs, skills_required))
				return FALSE

		// It is nesting hell, but it should work fine
		if (length(G.allowed_branches))
			var/list/branches = list()
			for(var/datum/job/J in jobs)
				if(pref.branches[J.title])
					branches |= pref.branches[J.title]
			if (!branches || !length(branches))
				return FALSE
			var/branch_ok = FALSE
			for(var/branch in branches)
				var/datum/mil_branch/player_branch = GLOB.mil_branches.get_branch(branch)
				if(player_branch.type in G.allowed_branches)
					branch_ok = TRUE
					break

			if (!branch_ok)
				return FALSE

	if (length(G.required_factions))
		var/singleton/cultural_info/faction = SSculture.get_culture(pref.cultural_info[TAG_FACTION])
		var/facname = faction ? faction.name : "Unset"
		if(!(facname in G.required_factions))
			return FALSE


	if(G.whitelisted && !(pref.species in G.whitelisted))
		return FALSE

	return TRUE

/// Adds or removes gear from picked gear slot.
/// Returns `true` if gear successfully added or removed. `False` otherwise
/datum/category_item/player_setup_item/loadout/proc/toggle_gear(datum/gear/gear_to_toggle, mob/user)
	// Check if someone trying to tricking us. However, it's may be just a bug
	ASSERT(gear_to_toggle?.allowed_donation_tier(user))

	var/datum/gear_slot/picked_slot = pref.get_picked_gear_slot()

	var/gear_name = gear_to_toggle.display_name
	if(picked_slot.contains(gear_name))
		picked_slot.remove_gear(gear_name)
		return TRUE

	var/total_gear_cost = picked_slot.get_total_gear_cost()
	if(total_gear_cost + gear_to_toggle.cost > config.max_gear_cost)
		return FALSE

	picked_slot.add_gear(gear_name, selected_tweaks)
	return TRUE


/datum/category_item/player_setup_item/loadout/proc/get_gear_image(atom/movable/gear_item_prototype, mob/user)
	ASSERT(istype(gear_item_prototype))
	ASSERT(user)

	var/list/icon_cache_key_components = list("[gear_item_prototype.icon]", "[gear_item_prototype.icon_state]")
	if(islist(gear_item_prototype.color))
		for(var/color in gear_item_prototype.color)
			icon_cache_key_components += color
	else
		icon_cache_key_components += gear_item_prototype.color

	var/cache_key = icon_cache_key_components.Join(":")
	var/asset_name = LAZYACCESS(gear_icons_cache, cache_key)
	if(!asset_name)
		var/icon/gear_icon = icon(gear_item_prototype.icon, gear_item_prototype.icon_state)
		if(gear_item_prototype.color)
			if(islist(gear_item_prototype.color))
				gear_icon.MapColors(arglist(gear_item_prototype.color))
			else
				gear_icon.Blend(gear_item_prototype.color, ICON_MULTIPLY)

		asset_name = register_icon_asset(gear_icon)
		LAZYSET(gear_icons_cache, cache_key, asset_name)

	SSassets.transport.send_assets(user, asset_name)
	return "<img class='icon' style='width:64px;height:64px;min-height:64px' src='[SSassets.transport.get_asset_url(asset_name)]'>"
