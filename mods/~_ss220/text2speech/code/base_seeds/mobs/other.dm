//Uncategorized mobs

/mob/living/silicon/ai/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/glados, TTS_TRAIT_ROBOTIZE)

/mob/living/simple_animal/shade/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/kelthuzad)

/mob/living/simple_animal/slime/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/chen)

/mob/living/simple_animal/drone/add_tts_component()
	return

/mob/living/bot/add_tts_component()
	return
