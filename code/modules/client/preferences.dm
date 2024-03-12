#define SAVE_RESET -1

#define JOB_PRIORITY_HIGH   FLAG(0)
#define JOB_PRIORITY_MEDIUM FLAG(1)
#define JOB_PRIORITY_LOW    FLAG(2)
#define JOB_PRIORITY_LIKELY (JOB_PRIORITY_HIGH | JOB_PRIORITY_MEDIUM)
#define JOB_PRIORITY_PICKED (JOB_PRIORITY_HIGH | JOB_PRIORITY_MEDIUM | JOB_PRIORITY_LOW)

#define MAX_LOAD_TRIES 5

/datum/preferences
	//doohickeys for savefiles
	var/is_guest = FALSE
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/character_slots_count = 0
	// Cache, mapping slot record ids to character names
	// Saves reading all the slot records when listing
	var/list/slot_names = null

	//non-preference stuff
	var/warns = 0
	var/muted = 0
	var/last_ip
	var/last_id

	// Populated with an error message if loading fails.
	var/load_failed = null

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change

	var/client/client = null
	var/client_ckey = null

	var/datum/browser/popup
	var/datum/category_collection/player_setup_collection/player_setup
	var/datum/browser/panel
	var/datum/gear/trying_on_gear
	var/list/trying_on_tweaks = list()

/datum/preferences/New(client/C)
	if(istype(C))
		client = C
		client_ckey = C.ckey
		SScharacter_setup.preferences_datums[C.ckey] = src
		if(SScharacter_setup.initialized)
			setup()
		else
			SScharacter_setup.prefs_awaiting_setup += src
	..()

/datum/preferences/proc/setup()
	if(!length(GLOB.skills))
		GET_SINGLETON(/singleton/hierarchy/skill)
	player_setup = new(src)
	gender = pick(MALE, FEMALE)
	real_name = random_name(gender,species)
	b_type = RANDOM_BLOOD_TYPE

	if(client)
		if(IsGuestKey(client.key))
			is_guest = TRUE
		else
			load_data()

	sanitize_preferences()
	if(client && istype(client.mob, /mob/new_player))
		var/mob/new_player/np = client.mob
		np.new_player_panel(TRUE)

/datum/preferences/proc/load_data()
	load_failed = null
	var/stage = "pre"
	try
		var/pref_path = get_path(client_ckey, "preferences")
		if(!fexists(pref_path))
			stage = "migrate"
			// Try to migrate legacy savefile-based preferences
			if(!migrate_legacy_preferences())
				// If there's no old save, there'll be nothing to load.
				return

		stage = "load"
		load_preferences()
		load_character()
	catch(var/exception/E)
		load_failed = "{[stage]} [E]"
		throw E

/datum/preferences/proc/migrate_legacy_preferences()
	// We make some assumptions here:
	// - all relevant savefiles were version 17, which covers anything saved from 2018+
	// - legacy saves were only made on the "torch" map
	// - a maximum of 40 slots were used

	var/legacy_pref_path = get_path(client.ckey, "preferences", "sav")
	if(!fexists(legacy_pref_path))
		return 0

	var/savefile/S = new(legacy_pref_path)
	if(S["version"] != 17)
		return 0

	// Legacy version 17 ~= new version 1
	var/datum/pref_record_reader/savefile/savefile_reader = new(S, 1)

	player_setup.load_preferences(savefile_reader)
	var/orig_slot = default_slot

	S.cd = "/torch"
	for(var/slot = 1 to 40)
		if(!S.dir.Find("character[slot]"))
			continue
		S.cd = "/torch/character[slot]"
		default_slot = slot
		player_setup.load_character(savefile_reader)
		save_character(override_key="character_torch_[slot]")
		S.cd = "/torch"
	S.cd = "/"

	default_slot = orig_slot
	save_preferences()

	return 1

/datum/preferences/proc/get_content(mob/user)
	if(!SScharacter_setup.initialized)
		return
	if(!user || !user.client)
		return

	var/dat = "<center>"

	if(is_guest)
		dat += "Please create an account to save your preferences. If you have an account and are seeing this, please adminhelp for assistance."
	else if(load_failed)
		dat += "Loading your savefile failed. Please adminhelp for assistance."
	else
		dat += "Slot - "
		dat += "<a href='?src=[ref(src)];load=1'>Load slot</a> - "
		dat += "<a href='?src=[ref(src)];save=1'>Save slot</a> - "
		dat += "<a href='?src=[ref(src)];resetslot=1'>Reset slot</a> - "
		dat += "<a href='?src=[ref(src)];reload=1'>Reload slot</a>"

	dat += "<br>"
	dat += player_setup.header()
	dat += "<br><HR></center>"
	dat += player_setup.content(user)
	return dat

/datum/preferences/proc/open_setup_window(mob/user)
	if (!SScharacter_setup.initialized)
		return

	popup = new(user, "preference_window", "Character Setup", 1000, 800, src)
	var/content = {"
	<script type='text/javascript'>
		function update_content(data){
			document.getElementById('content').innerHTML = data;
		}
	</script>
	<div id='content'>[get_content(user)]</div>
	"}
	popup.set_content(content)
	popup.open()

	update_preview_icon()

/datum/preferences/proc/update_setup_window(mob/user)
	send_output(user, url_encode(get_content(user)), "preference_window.preference_browser:update_content")

/datum/preferences/proc/process_link(mob/user, list/href_list)

	if(!user)	return
	if(isliving(user)) return

	if(href_list["preference"] == "open_whitelist_forum")
		if(config.forum_url)
			send_link(user, config.forum_url)
		else
			to_chat(user, SPAN_DANGER("The forum URL is not set in the server configuration."))
			return
	update_setup_window(usr)
	return 1

/datum/preferences/Topic(href, list/href_list)
	if(..())
		return TRUE

	if (href_list["close"])
		popup = null
		clear_character_preview()

	else if(href_list["save"])
		save_preferences()
		save_character()

		if(istype(client.mob, /mob/new_player))
			var/mob/new_player/M = client.mob
			M.new_player_panel()

	else if(href_list["reload"])
		load_preferences()
		load_character()
		sanitize_preferences()
		update_preview_icon()

	else if(href_list["load"])
		if(!IsGuestKey(usr.key))
			open_load_dialog(usr, href_list["details"])
			return TRUE

	else if(href_list["changeslot"])
		load_character(text2num(href_list["changeslot"]))
		sanitize_preferences()
		close_load_dialog(usr)
		update_preview_icon()

		if (istype(client.mob, /mob/new_player))
			var/mob/new_player/M = client.mob
			M.new_player_panel()

		if (href_list["details"])
			return TRUE

	else if(href_list["resetslot"])
		if(real_name != input("This will reset the current slot. Enter the character's full name to confirm."))
			return FALSE

		load_character(SAVE_RESET)
		sanitize_preferences()
		update_preview_icon()

	else if (href_list["changeslot_next"])
		character_slots_count += 10
		if(character_slots_count >= config.character_slots)
			character_slots_count = 0
		open_load_dialog(usr, href_list["details"])

	else if (href_list["changeslot_prev"])
		character_slots_count -= 10
		if(character_slots_count < 0)
			character_slots_count = config.character_slots - config.character_slots % 10
		open_load_dialog(usr, href_list["details"])

	else
		return FALSE

	update_setup_window(usr)
	return TRUE

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, is_preview_copy = FALSE)
	// Sanitizing rather than saving as someone might still be editing when copy_to occurs.
	player_setup.sanitize_setup()
	character.set_species(species)

	character.fully_replace_character_name(real_name)

	character.gender = gender
	character.tts_seed = tts_seed
	character.age = age
	character.b_type = b_type

	character.eye_color = eye_color

	character.head_hair_style = head_hair_style
	character.head_hair_color = head_hair_color

	character.facial_hair_style = facial_hair_style
	character.facial_hair_color = facial_hair_color

	character.skin_color = skin_color

	character.skin_tone = skin_tone
	character.base_skin = base_skin

	// Destroy/cyborgize organs and limbs. The order is important for preserving low-level choices for robolimb sprites being overridden.
	for(var/name in BP_BY_DEPTH)
		var/status = organ_data[name]
		var/obj/item/organ/external/external_organ = character.organs_by_name[name]
		if(!external_organ)
			continue

		external_organ.status = 0
		external_organ.model = null
		if(is_preview_copy)
			external_organ.blocks_emissive = EMISSIVE_BLOCK_NONE

		if(status == "amputated")
			character.organs_by_name[external_organ.organ_tag] = null
			character.organs -= external_organ
			if(external_organ.children) // This might need to become recursive.
				for(var/obj/item/organ/external/child in external_organ.children)
					character.organs_by_name[child.organ_tag] = null
					character.organs -= child
					qdel(child)
			qdel(external_organ)

		else if(status == "cyborg")
			if(rlimb_data[name])
				external_organ.robotize(rlimb_data[name])
			else
				external_organ.robotize()
		else //normal organ

			external_organ.force_icon = initial(external_organ.force_icon)
			external_organ.SetName(initial(external_organ.name))
			external_organ.desc = initial(external_organ.desc)

	//For species that don't care about your silly prefs
	character.species.handle_limbs_setup(character)
	if(!is_preview_copy)
		for(var/name in list(BP_HEART,BP_EYES,BP_BRAIN,BP_LUNGS,BP_LIVER,BP_KIDNEYS,BP_STOMACH))
			var/status = organ_data[name]
			if(!status)
				continue
			var/obj/item/organ/I = character.internal_organs_by_name[name]
			if(I)
				if(status == "assisted")
					I.mechassist()
				else if(status == "mechanical")
					I.robotize()

	QDEL_NULL_LIST(character.worn_underwear)
	character.worn_underwear = list()

	for(var/underwear_category_name in all_underwear)
		var/datum/category_group/underwear/underwear_category = LAZYACCESS(GLOB.underwear.categories_by_name, underwear_category_name)
		if(underwear_category)
			var/underwear_item_name = all_underwear[underwear_category_name]
			var/datum/category_item/underwear/UWD = underwear_category.items_by_name[underwear_item_name]
			var/metadata = all_underwear_metadata[underwear_category_name]
			var/obj/item/underwear/UW = UWD.create_underwear(character, metadata)
			if(UW)
				UW.ForceEquipUnderwear(character, FALSE)
		else
			all_underwear -= underwear_category_name

	character.backpack_setup = new(backpack, backpack_metadata["[backpack]"])

	for(var/N in character.organs_by_name)
		var/obj/item/organ/external/external_organ = character.organs_by_name[N]
		external_organ.markings.Cut()

	for(var/M in body_markings)
		var/datum/sprite_accessory/marking/mark_datum = GLOB.body_marking_styles_list[M]
		var/mark_color = "[body_markings[M]]"

		for(var/BP in mark_datum.body_parts)
			var/obj/item/organ/external/external_organ = character.organs_by_name[BP]
			if (external_organ)
				external_organ.markings[mark_datum] = mark_color

	character.force_update_limbs()
	character.update_mutations(FALSE)
	character.update_body(FALSE)
	character.update_underwear(FALSE)
	character.update_hair(FALSE)
	character.update_icons()

	if(is_preview_copy)
		return

	for(var/token in cultural_info)
		character.set_cultural_value(token, cultural_info[token], defer_language_update = TRUE)
	character.update_languages()
	for(var/lang in alternate_languages)
		character.add_language(lang)

	character.flavor_texts["general"] = flavor_texts["general"]
	character.flavor_texts["head"] = flavor_texts["head"]
	character.flavor_texts["face"] = flavor_texts["face"]
	character.flavor_texts["eyes"] = flavor_texts["eyes"]
	character.flavor_texts["torso"] = flavor_texts["torso"]
	character.flavor_texts["arms"] = flavor_texts["arms"]
	character.flavor_texts["hands"] = flavor_texts["hands"]
	character.flavor_texts["legs"] = flavor_texts["legs"]
	character.flavor_texts["feet"] = flavor_texts["feet"]

	character.public_record = public_record
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record
	character.exploit_record = exploit_record

	if(LAZYLEN(character.descriptors))
		for(var/entry in body_descriptors)
			character.descriptors[entry] = body_descriptors[entry]

	if(!character.isSynthetic())
		character.set_nutrition(rand(140,360))
		character.set_hydration(rand(140,360))

/datum/preferences/proc/open_load_dialog(mob/user, details)
	var/list/dat  = list()
	dat += "<body>"
	dat += "<center>"

	dat += "<b>Выберите слот для загрузки</b><hr>"
	for(var/i = 1, i <= 10, i++)
		var/name = (slot_names && slot_names[get_slot_key(i + character_slots_count)]) || "Персонаж [i + character_slots_count]"
		if((i + character_slots_count) == default_slot)
			name = "<b>[name]</b>"
		if(i + character_slots_count <= config.character_slots)
			dat += "<a href='?src=\ref[src];changeslot=[i + character_slots_count];[details?"details=1":""]'>[name]</a><br>"
	if(config.character_slots>10)
		dat += "<br><a href='?src=\ref[src];changeslot_prev=1'> <b>&lt;</b> </a>"
		dat += " <b>[character_slots_count + 1]</b> - <b>[character_slots_count + 10]</b> "
		dat += "<a href='?src=\ref[src];changeslot_next=1'> <b>&gt;</b> </a><br>"
	dat += "<hr>"
	dat += "</center>"
	panel = new(user, "character_slots", "Слоты персонажей", 300, 390, src)
	panel.set_content(dat.Join())
	panel.open(FALSE)

/datum/preferences/proc/close_load_dialog(mob/user)
	if(panel)
		panel.close()
		panel = null
	close_browser(user, "window=saves")

/datum/preferences/proc/selected_jobs_titles(priority = JOB_PRIORITY_PICKED)
	. = list()
	if (priority & JOB_PRIORITY_HIGH)
		. |= job_high
	if (priority & JOB_PRIORITY_MEDIUM)
		. |= job_medium
	if (priority & JOB_PRIORITY_LOW)
		. |= job_low

/datum/preferences/proc/selected_jobs_list(priority = JOB_PRIORITY_PICKED)
	. = list()
	for (var/title in selected_jobs_titles(priority))
		var/datum/job/job = SSjobs.get_by_title(title)
		if (!job)
			continue
		. += job

/datum/preferences/proc/selected_jobs_assoc(priority = JOB_PRIORITY_PICKED)
	. = list()
	for (var/title in selected_jobs_titles(priority))
		var/datum/job/job = SSjobs.get_by_title(title)
		if (!job)
			continue
		.[title] = job

/datum/preferences/proc/selected_branches_list(priority = JOB_PRIORITY_PICKED)
	. = list()
	for (var/datum/job/job in selected_jobs_list(priority))
		var/name = branches[job.title]
		if (!name)
			continue
		. |= GLOB.mil_branches.get_branch(name)

/datum/preferences/proc/selected_branches_assoc(priority = JOB_PRIORITY_PICKED)
	. = list()
	for (var/datum/job/job in selected_jobs_list(priority))
		var/name = branches[job.title]
		if (!name || .[name])
			continue
		.[name] = GLOB.mil_branches.get_branch(name)

/datum/preferences/proc/for_each_selected_job(datum/callback/callback, priority = JOB_PRIORITY_LIKELY)
	. = list()
	if (!islist(priority))
		priority = selected_jobs_assoc(priority)
	for (var/title in priority)
		var/datum/job/job = priority[title]
		.[title] = invoke(callback, job)

/datum/preferences/proc/for_each_selected_job_multi(list/callbacks, priority = JOB_PRIORITY_LIKELY)
	. = list()
	if (!islist(priority))
		priority = selected_jobs_assoc(priority)
	for (var/callback in callbacks)
		. += for_each_selected_job(callback, priority)

/datum/preferences/proc/for_each_selected_branch(datum/callback/callback, priority = JOB_PRIORITY_LIKELY)
	. = list()
	if (!islist(priority))
		priority = selected_branches_assoc(priority)
	for (var/name in priority)
		var/datum/mil_branch/branch = priority[name]
		.[name] = invoke(callback, branch)

/datum/preferences/proc/for_each_selected_branch_multi(list/callbacks, priority = JOB_PRIORITY_LIKELY)
	. = list()
	if (!islist(priority))
		priority = selected_branches_assoc(priority)
	for (var/callback in callbacks)
		. += for_each_selected_branch(callback, priority)
