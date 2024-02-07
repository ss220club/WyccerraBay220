/datum/preferences
	var/tts_seed
	var/static/explorer_users = list()

/mob/new_player/proc/check_tts_seed_ready()
	return TRUE

/datum/category_item/player_setup_item/physical/basic/load_character(datum/pref_record_reader/R)
	. = ..()
	pref.tts_seed = R.read("tts_seed")

/datum/category_item/player_setup_item/physical/basic/save_character(datum/pref_record_writer/W)
	. = ..()
	W.write("tts_seed", pref.tts_seed)

/datum/nano_module/tts_seeds_explorer
	name = "Эксплорер TTS голосов"
	var/phrases = TTS_PHRASES

/datum/nano_module/tts_seeds_explorer/ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/nanoui/master_ui, datum/topic_state/state)
	. = ..()
	var/list/data = ui_data(user, ui_key)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "tts_explorer.tmpl", "TTS Expplorer UI", 600, 800)
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/tts_seeds_explorer/ui_data(mob/user, ui_key)
	var/list/data = list()

	data["selected_seed"] = user.client.prefs.tts_seed
	data["donator_level"] = 5

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

/datum/nano_module/tts_seeds_explorer/Topic(href, href_list)
	. = ..()
	if(href["listen"])
		if(!(href["phrase"] in phrases))
			return
		if(!(href["seed"] in SStts220.tts_seeds))
			return

		invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, usr, href["phrase"], href["seed"], FALSE)
	if(href["select"])
		if(!(href["seed"] in SStts220.tts_seeds))
			return
		var/datum/tts_seed/seed = SStts220.tts_seeds[href["seed"]]

		usr.client.prefs.tts_seed = seed

/datum/preferences/get_content(mob/user)
	. = ..()
	. += "<a href='?src=\ref[src];tts_explorer=1'>Выбрать голос</a>"

/datum/preferences/Topic(href, list/href_list)
	. = ..()
	if(href_list["tts_explorer"])
		var/datum/nano_module/tts_seeds_explorer/explorer = explorer_users[usr]
		if(!explorer)
			explorer = new()
			explorer_users[usr] = explorer
		explorer.ui_interact(usr)
		return
