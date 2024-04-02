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

/datum/component/tts_component/proc/select_tts_seed(mob/chooser, silent_target = FALSE, override = FALSE, list/new_traits = null)
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
				invoke_async(SStts220, TYPE_PROC_REF(/datum/controller/subsystem/tts220, get_tts), null, chooser, tts_test_str, new_tts_seed, FALSE, get_effect())
				return new_tts_seed

	var/tts_seeds
	var/list/tts_seeds_by_gender = SStts220.get_tts_by_gender(being_changed.gender)
	if(!length(tts_seeds_by_gender))
		to_chat(chooser, SPAN_WARNING("Не удалось найти пол для голоса! Текущий голос - [tts_seed.name]"))
		return null
	if(check_rights(R_ADMIN, FALSE, chooser) || override || !ismob(being_changed))
		tts_seeds = tts_seeds_by_gender
	else
		tts_seeds = tts_seeds_by_gender && SStts220.get_available_seeds(being_changed) // && for lists means intersection

	var/new_tts_seed_key
	new_tts_seed_key = tgui_input_list(chooser, "Выберите голос персонажа", "Преобразуем голос", tts_seeds, tts_seed.name)
	if(!new_tts_seed_key || !SStts220.tts_seeds[new_tts_seed_key])
		to_chat(chooser, SPAN_WARNING("Что-то пошло не так с выбором голоса. Текущий голос - [tts_seed.name]"))
		return null

	new_tts_seed = SStts220.tts_seeds[new_tts_seed_key]
	if(new_traits)
		traits = new_traits

	if(!silent_target && being_changed != chooser && ismob(being_changed))
		invoke_async(SStts220, TYPE_PROC_REF(/datum/controller/subsystem/tts220, get_tts), null, being_changed, tts_test_str, new_tts_seed, FALSE, get_effect())

	if(chooser)
		invoke_async(SStts220, TYPE_PROC_REF(/datum/controller/subsystem/tts220, get_tts), null, chooser, tts_test_str, new_tts_seed, FALSE, get_effect())

	return new_tts_seed

/datum/component/tts_component/proc/tts_seed_change(atom/being_changed, mob/chooser, override = FALSE, list/new_traits = null)
	set waitfor = FALSE
	var/datum/tts_seed/new_tts_seed = select_tts_seed(chooser = chooser, override = override, new_traits = new_traits)
	if(!new_tts_seed)
		return null
	tts_seed = new_tts_seed

/datum/component/tts_component/proc/get_random_tts_seed_by_gender()
	var/atom/being_changed = parent
	var/tts_choice = SStts220.pick_tts_seed_by_gender(being_changed.gender)
	var/datum/tts_seed/seed = SStts220.tts_seeds[tts_choice]
	if(!seed)
		return null
	return seed

/datum/component/tts_component/proc/get_effect(effect)
	. = effect
	switch(.)
		if(null)
			if(TTS_TRAIT_ROBOTIZE in traits)
				return /singleton/sound_effect/robot
		if(/singleton/sound_effect/radio)
			if(TTS_TRAIT_ROBOTIZE in traits)
				return /singleton/sound_effect/radio_robot
		if(/singleton/sound_effect/megaphone)
			if(TTS_TRAIT_ROBOTIZE in traits)
				return /singleton/sound_effect/megaphone_robot
	return .

/datum/component/tts_component/proc/cast_tts(atom/speaker, mob/listener, message, atom/location, is_local = TRUE, effect = null, traits = TTS_TRAIT_RATE_FASTER, preSFX, postSFX)
	SIGNAL_HANDLER

	if(!message)
		return
	if(!(listener?.client) || listener.is_deaf())
		return
	if(!speaker)
		speaker = parent
	if(!location)
		location = parent
	if(effect == /singleton/sound_effect/radio)
		if(listener == speaker && !issilicon(parent)) // don't hear both radio and whisper from yourself
			return

	effect = get_effect(effect)

	invoke_async(SStts220, TYPE_PROC_REF(/datum/controller/subsystem/tts220, get_tts), location, listener, message, tts_seed, is_local, effect, traits, preSFX, postSFX)

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
	change_tts_seed(src, new_traits = list(TTS_TRAIT_ROBOTIZE))
