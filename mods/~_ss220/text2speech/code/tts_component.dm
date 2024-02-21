/datum/component/tts_component
	var/datum/tts_seed/tts_seed
	var/list/traits = list()

/datum/component/tts_component/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_TTS_SEED_CHANGE, PROC_REF(tts_seed_change))
	RegisterSignal(parent, COMSIG_ATOM_TTS_CAST, PROC_REF(cast_tts))
	RegisterSignal(parent, COMSIG_ATOM_TTS_TRAIT_ADD, PROC_REF(tts_trait_add))
	RegisterSignal(parent, COMSIG_ATOM_TTS_TRAIT_REMOVE, PROC_REF(tts_trait_remove))

/datum/component/tts_component/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_TTS_SEED_CHANGE)
	UnregisterSignal(parent, COMSIG_ATOM_TTS_CAST)
	UnregisterSignal(parent, COMSIG_ATOM_TTS_TRAIT_ADD)
	UnregisterSignal(parent, COMSIG_ATOM_TTS_TRAIT_REMOVE)

/datum/component/tts_component/Initialize(datum/tts_seed/new_tts_seed, ...)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(ispath(new_tts_seed) && SStts220.tts_seeds[initial(new_tts_seed.name)])
		new_tts_seed = SStts220.tts_seeds[initial(new_tts_seed.name)]
	if(istype(new_tts_seed))
		tts_seed = new_tts_seed
	if(!tts_seed)
		tts_seed = get_random_tts_seed_by_gender()
	if(!tts_seed) // Something went terribly wrong
		return COMPONENT_INCOMPATIBLE
	if(length(args) > 1)
		for(var/trait in 2 to length(args))
			traits += args[trait]
	if(ishuman(parent))
		var/mob/living/carbon/human/owner = parent
		traits += owner.species.tts_trait

/datum/component/tts_component/proc/return_tts_seed()
	SIGNAL_HANDLER
	return tts_seed

/datum/component/tts_component/proc/select_tts_seed(mob/chooser, silent_target = FALSE, override = FALSE, fancy_voice_input_tgui = FALSE, list/new_traits = null)
	if(!chooser)
		if(ismob(parent))
			chooser = parent
		else
			return null

	var/atom/being_changed = parent
	var/static/tts_test_str = "Так звучит мой голос."
	var/datum/tts_seed/new_tts_seed

	if(chooser == being_changed)
		var/datum/preferences/prefs = chooser.client.prefs
		if(being_changed.gender == prefs.gender)
			if(alert(chooser, "Оставляем голос вашего персонажа [prefs.real_name] - [prefs.tts_seed]?", "Выбор голоса", "Нет", "Да") ==  "Да")
				if(!SStts220.tts_seeds[prefs.tts_seed])
					to_chat(chooser, SPAN_WARNING("Отсутствует tts_seed для значения \"[prefs.tts_seed]\". Текущий голос - [tts_seed.name]"))
					return null
				new_tts_seed = SStts220.tts_seeds[prefs.tts_seed]
				if(new_traits)
					traits = new_traits
				invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, chooser, tts_test_str, new_tts_seed, FALSE, get_effect())
				return new_tts_seed

	var/tts_seeds
	var/tts_gender = get_converted_tts_seed_gender()
	var/list/tts_seeds_by_gender = SStts220.tts_seeds_by_gender[tts_gender]
	if(check_rights(R_ADMIN, FALSE, chooser) || override || !ismob(being_changed))
		tts_seeds = tts_seeds_by_gender
	else
		tts_seeds = tts_seeds_by_gender && SStts220.get_available_seeds(being_changed) // && for lists means intersection

	var/new_tts_seed_key
	if(fancy_voice_input_tgui)
		new_tts_seed_key = tgui_input_list(chooser, "Выберите голос персонажа", "Преобразуем голос", tts_seeds)
	else
		new_tts_seed_key = input(chooser, "Выберите голос персонажа", "Преобразуем голос") as null|anything in tts_seed
	if(!new_tts_seed_key || !SStts220.tts_seeds[new_tts_seed_key])
		to_chat(chooser, SPAN_WARNING("Что-то пошло не так с выбором голоса. Текущий голос - [tts_seed.name]"))
		return null

	new_tts_seed = SStts220.tts_seeds[new_tts_seed_key]
	if(new_traits)
		traits = new_traits

	if(!silent_target && being_changed != chooser && ismob(being_changed))
		invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, being_changed, tts_test_str, new_tts_seed, FALSE, get_effect())

	if(chooser)
		invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, chooser, tts_test_str, new_tts_seed, FALSE, get_effect())

	return new_tts_seed

/datum/component/tts_component/proc/tts_seed_change(atom/being_changed, mob/chooser, override = FALSE, fancy_voice_input_tgui = FALSE, list/new_traits = null)
	set waitfor = FALSE
	var/datum/tts_seed/new_tts_seed = select_tts_seed(chooser = chooser, override = override, fancy_voice_input_tgui = fancy_voice_input_tgui, new_traits = new_traits)
	if(!new_tts_seed)
		return null
	tts_seed = new_tts_seed

/datum/component/tts_component/proc/get_random_tts_seed_by_gender()
	var/tts_gender = get_converted_tts_seed_gender()
	var/tts_random = pick(SStts220.tts_seeds_by_gender[tts_gender])
	var/datum/tts_seed/seed = SStts220.tts_seeds[tts_random]
	if(!seed)
		return null
	return seed

/datum/component/tts_component/proc/get_converted_tts_seed_gender()
	var/atom/being_changed = parent
	switch(being_changed.gender)
		if(MALE)
			return TTS_GENDER_MALE
		if(FEMALE)
			return TTS_GENDER_FEMALE
		else
			return TTS_GENDER_ANY

/datum/component/tts_component/proc/get_effect(effect)
	. = effect
	switch(.)
		if(SOUND_EFFECT_NONE)
			if(TTS_TRAIT_ROBOTIZE in traits)
				return SOUND_EFFECT_ROBOT
		if(SOUND_EFFECT_RADIO)
			if(TTS_TRAIT_ROBOTIZE in traits)
				return SOUND_EFFECT_RADIO_ROBOT
		if(SOUND_EFFECT_MEGAPHONE)
			if(TTS_TRAIT_ROBOTIZE in traits)
				return SOUND_EFFECT_MEGAPHONE_ROBOT
	return .

/datum/component/tts_component/proc/cast_tts(atom/speaker, mob/listener, message, atom/location, is_local = TRUE, effect = SOUND_EFFECT_NONE, traits = TTS_TRAIT_RATE_FASTER, preSFX, postSFX)
	SIGNAL_HANDLER

	if(!message)
		return
	if(!(listener?.client) || listener.is_deaf())
		return
	if(!speaker)
		speaker = parent
	if(!location)
		location = parent
	if(effect == SOUND_EFFECT_RADIO)
		if(parent == speaker && !(isrobot(parent) || isAI(parent)))
			return

	effect = get_effect(effect)

	invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), location, listener, message, tts_seed, is_local, effect, traits, preSFX, postSFX)

/datum/component/tts_component/proc/tts_trait_add(atom/user, trait)
	SIGNAL_HANDLER

	if(!isnull(trait) && !(trait in traits))
		traits += trait

/datum/component/tts_component/proc/tts_trait_remove(atom/user, trait)
	SIGNAL_HANDLER

	if(!isnull(trait) && (trait in traits))
		traits -= trait

// Component usage

/mob/living/silicon/verb/synth_change_voice()
	set name = "Смена голоса"
	set desc = "Express yourself!"
	set category = "Silicon Commands"
	change_tts_seed(src, fancy_voice_input_tgui = TRUE, new_traits = list(TTS_TRAIT_ROBOTIZE))
