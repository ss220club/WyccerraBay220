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

/datum/nano_module/tts_seeds_explorer
	name = "Эксплорер TTS голосов"
	var/phrases = TTS_PHRASES
	var/static/list/static_data

/datum/nano_module/tts_seeds_explorer/proc/init_static_data()
	static_data = list()

	var/list/providers = list()
	for(var/_provider in SStts220.tts_providers)
		var/datum/tts_provider/provider = SStts220.tts_providers[_provider]
		providers += list(list(
			"name" = provider.name,
			"is_enabled" = provider.is_enabled,
		))
	static_data["providers"] = providers

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
	static_data["seeds"] = seeds
	static_data["phrases"] = phrases

/datum/nano_module/tts_seeds_explorer/ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/nanoui/master_ui, datum/topic_state/state)
	. = ..()
	var/list/data = ui_data(user, ui_key)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mods-tts_explorer.tmpl", "TTS Expplorer UI", 400, 800)
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/tts_seeds_explorer/ui_data(mob/user, ui_key)
	var/list/data = list()
	if(!static_data)
		init_static_data()
	data += static_data

	data["selected_seed"] = user.client.prefs.tts_seed
	data["donator_level"] = 5

	return data

/datum/nano_module/tts_seeds_explorer/Topic(href, href_list)
	. = ..()
	if(href_list["listen"])
		if(!(href_list["phrase"] in phrases))
			return
		if(!(href_list["seed"] in SStts220.tts_seeds))
			return

		invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, usr, href_list["phrase"], href_list["seed"], FALSE)
	if(href_list["select"])
		if(!(href_list["seed"] in SStts220.tts_seeds))
			return
		var/datum/tts_seed/seed = SStts220.tts_seeds[href_list["seed"]]

		usr.client.prefs.tts_seed = seed.name
		usr.client.prefs.save_preferences()
		SSnano.update_uis(src)


/datum/preferences/get_content(mob/user)
	. = ..()
	. += "<a href='?src=\ref[src];tts_explorer=1'>Выбрать голос</a>"

/mob/new_player/Topic(href, href_list)
	if(config.tts_enabled && (href_list["lobby_ready"] || href_list["late_join"]))
		if(!usr.client.prefs.tts_seed)
			usr.client.prefs.set_random_gendered_tts_seed()
			to_chat(usr, SPAN_WARNING("У вас не выбран голос. Мы вам зарандомили его, так что не жалуйтесь потом."))
	. = ..()

/datum/preferences/Topic(href, list/href_list)
	if(href_list["tts_explorer"])
		var/datum/nano_module/tts_seeds_explorer/explorer = explorer_users[usr]
		if(!explorer)
			explorer = new(src)
			explorer_users[usr] = explorer
		explorer.ui_interact(usr)
		return
	return ..()

/datum/preferences/CanUseTopic(mob/user, datum/topic_state/state)
	. = ..()
	return STATUS_INTERACTIVE

/datum/preferences/copy_to(mob/living/carbon/human/character, is_preview_copy)
	. = ..()
	character.tts_seed = tts_seed
