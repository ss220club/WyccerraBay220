/mob/living/silicon/tts_get_effect(effect, datum/language/language)
	return tts_robotize(effect)

/mob/living/carbon/human/tts_get_effect(effect, datum/language/language)
	return species.tts_get_effect()

/datum/species/proc/tts_get_effect(effect = SOUND_EFFECT_NONE, datum/language/language)
	return effect

/datum/species/nabber/tts_get_effect(effect, datum/language/language)
	if(istype(language, /datum/language/nabber))
		return effect
	return tts_robotize(effect)

/datum/species/machine/tts_get_effect(effect, datum/language/language)
	return tts_robotize(effect)
