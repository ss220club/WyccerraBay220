/datum/dna
	var/datum/tts_seed/tts_seed_dna

/datum/dna/Clone()
	. = ..()
	var/datum/dna/new_dna = .
	new_dna.tts_seed_dna = tts_seed_dna
	return new_dna

/atom/proc/add_tts_component()
	return

/atom/Initialize(mapload, ...)
	. = ..()
	add_tts_component()

/atom/proc/cast_tts(mob/listener, message, atom/location, is_local = TRUE, effect = null, traits = TTS_TRAIT_RATE_FASTER, preSFX, postSFX)
	SEND_SIGNAL(src, COMSIG_ATOM_TTS_CAST, listener, message, location, is_local, effect, traits, preSFX, postSFX)

// TODO: Do it better?
/atom/proc/get_tts_seed()
	var/datum/component/tts_component/tts_component = GetComponent(/datum/component/tts_component)
	if(tts_component)
		return tts_component.tts_seed

/atom/proc/change_tts_seed(mob/chooser, override, list/new_traits = null)
	if(!get_tts_seed())
		if(alert(chooser, "Отсутствует TTS компонент. Создать?", "Изменение TTS", "Да", "Нет") == "Нет")
			return
		AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/angel)
	SEND_SIGNAL(src, COMSIG_ATOM_TTS_SEED_CHANGE, chooser, override, new_traits)

/atom/proc/tts_trait_add(trait)
	SEND_SIGNAL(src, COMSIG_ATOM_TTS_TRAIT_ADD, trait)

/atom/proc/tts_trait_remove(trait)
	SEND_SIGNAL(src, COMSIG_ATOM_TTS_TRAIT_REMOVE, trait)
