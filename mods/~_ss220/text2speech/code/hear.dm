/mob/hear_say(message, verb, datum/language/language, alt_name, italics, mob/speaker, sound/speech_sound, sound_vol)
	. = ..()

	var/effect = isrobot(speaker) ? SOUND_EFFECT_ROBOT : SOUND_EFFECT_NONE
	var/traits = TTS_TRAIT_RATE_FASTER
	invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), speaker, src, message, speaker.tts_seed, TRUE, effect, traits)

/mob/hear_radio(message, verb, datum/language/language, part_a, part_b, part_c, mob/speaker, hard_to_hear, vname)
	. = ..()

	if(src != speaker || isrobot(src) || isAI(src))
		var/effect = isrobot(speaker) ? SOUND_EFFECT_RADIO_ROBOT : SOUND_EFFECT_RADIO
		invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), src, src, message, speaker.tts_seed, FALSE, effect, null, null, 'mods/~_ss220/text2speech/code/sound/radio_chatter.ogg')
