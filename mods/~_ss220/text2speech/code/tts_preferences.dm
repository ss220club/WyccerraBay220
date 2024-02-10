/datum/preferences
	var/tts_seed
	var/static/explorer_users = list()

/datum/client_preference/tts_enabled
	default_value = GLOB.PREF_YES
	description = "Toggle TTS"
	key = "TTS_ENABLED"

/datum/preferences/proc/set_random_gendered_tts_seed()
	var/converted_gender = SStts220.gender_table[gender]
	tts_seed = pick(SStts220.tts_seeds_by_gender[converted_gender])

/mob/new_player/proc/check_tts_seed_ready()
	return TRUE

/datum/category_item/player_setup_item/physical/basic/load_character(datum/pref_record_reader/R)
	. = ..()
	pref.tts_seed = R.read("tts_seed")

/datum/category_item/player_setup_item/physical/basic/save_character(datum/pref_record_writer/W)
	. = ..()
	W.write("tts_seed", pref.tts_seed)

/datum/tgui_module/tts_seeds_explorer
	name = "Эксплорер TTS голосов"
	var/phrases = TTS_PHRASES

/datum/tgui_module/tts_seeds_explorer/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/tgui_module/tts_seeds_explorer/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TTSSeedsExplorer", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/tgui_module/tts_seeds_explorer/tgui_data(mob/user)
	var/list/data = list()
	data["selected_seed"] = user.client.prefs.tts_seed
	data["donator_level"] = 5
	data["character_gender"] = user.client.prefs.gender

	return data

/datum/tgui_module/tts_seeds_explorer/tgui_static_data(mob/user)
	var/list/data = list()

	var/list/providers = list()
	for(var/_provider in SStts220.tts_providers)
		var/datum/tts_provider/provider = SStts220.tts_providers[_provider]
		providers += list(list(
			"name" = provider.name,
			"is_enabled" = provider.is_enabled,
		))
	data["providers"] = providers

	var/list/seeds = list()
	for(var/_seed in SStts220.tts_seeds)
		var/datum/tts_seed/seed = SStts220.tts_seeds[_seed]
		seeds += list(list(
			"name" = seed.name,
			"value" = seed.value,
			"category" = seed.category,
			"gender" = seed.gender,
			"provider" = initial(seed.provider.name),
			"required_donator_level" = seed.required_donator_level,
		))
	data["seeds"] = seeds
	data["phrases"] = phrases

	return data

/datum/tgui_module/tts_seeds_explorer/tgui_act(action, list/params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("listen")
			var/phrase = params["phrase"]
			var/seed_name = params["seed"]

			if(!(phrase in phrases))
				return
			if(!(seed_name in SStts220.tts_seeds))
				return

			invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, usr, phrase, seed_name, FALSE)
		if("select")
			var/seed_name = params["seed"]

			if(!(seed_name in SStts220.tts_seeds))
				return
			//var/datum/tts_seed/seed = SStts220.tts_seeds[seed_name]
			//if(usr.client.donator_level < seed.required_donator_level)
			//	return

			usr.client.prefs.tts_seed = seed_name
		else
			return FALSE

/datum/category_item/player_setup_item/physical/body/content(mob/user)
	. = ..()
	. += "<br><a href='?src=\ref[src];tts_explorer=1'>Выбрать голос</a>"

/datum/category_item/player_setup_item/physical/body/Topic(href, list/href_list)
	if(href_list["tts_explorer"])
		var/datum/tgui_module/tts_seeds_explorer/explorer = explorer_users[usr]
		if(!explorer)
			explorer = new(src)
			explorer_users[usr] = explorer
		explorer.tgui_interact(usr)
		return
	return ..()

/mob/new_player/Topic(href, href_list)
	if(config.tts_enabled && (href_list["lobby_ready"] || href_list["late_join"]))
		if(!usr.client.prefs.tts_seed)
			usr.client.prefs.set_random_gendered_tts_seed()
			to_chat(usr, SPAN_WARNING("У вас не выбран голос. Мы вам зарандомили его, так что не жалуйтесь потом."))
	. = ..()

/datum/preferences/CanUseTopic(mob/user, datum/topic_state/state)
	. = ..()
	return STATUS_INTERACTIVE

/datum/preferences/copy_to(mob/living/carbon/human/character, is_preview_copy)
	. = ..()
	character.tts_seed = tts_seed
