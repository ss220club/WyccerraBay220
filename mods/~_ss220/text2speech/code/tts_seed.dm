/atom
	var/tts_seed

/datum/dna
	var/tts_seed_dna

/datum/dna/Clone()
	. = ..()
	var/datum/dna/new_dna = .
	new_dna.tts_seed_dna = tts_seed_dna
	return new_dna

/atom/proc/select_voice(mob/user, silent_target = FALSE, override = FALSE)
	if(!user)
		if(!ismob(src))
			return null
		else
			user = src

	var/static/tts_test_str = "Так звучит мой голос."

	var/tts_seeds
	var/tts_gender = get_converted_tts_seed_gender(gender)
	var/list/tts_seeds_by_gender = SStts220.tts_seeds_by_gender[tts_gender]
	if(user && (check_rights(R_ADMIN, FALSE, user) || override))
		tts_seeds = tts_seeds_by_gender
	else
		tts_seeds = tts_seeds_by_gender && SStts220.get_available_seeds(src) // && for lists means intersection

	var/new_tts_seed
	if(user.client.prefs.tts_seed)
		if(alert(user || src, "Оставляем голос вашего персонажа?", "Выбор голоса", "Нет", "Да") ==  "Да")
			new_tts_seed = user.client.prefs.tts_seed

	if(!new_tts_seed)
		new_tts_seed = input(user, "Выберите голос вашего персонажа", "Преобразуем голос") as null|anything in tts_seeds

		if(!new_tts_seed)
			return null

	if(!silent_target && src != user && ismob(src))
		invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, src, tts_test_str, new_tts_seed, FALSE)

	if(user)
		invoke_async(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, user, tts_test_str, new_tts_seed, FALSE)

	return new_tts_seed

/atom/proc/change_voice(mob/user, override = FALSE, fancy_voice_input_tgui = FALSE)
	set waitfor = FALSE
	var/new_tts_seed = select_voice(user = user, override = override)
	if(!new_tts_seed)
		return null
	return update_tts_seed(new_tts_seed)

/atom/proc/update_tts_seed(new_tts_seed)
	tts_seed = new_tts_seed
	return new_tts_seed

/mob/living/silicon/verb/synth_change_voice()
	set name = "Смена голоса"
	set desc = "Express yourself!"
	set category = "Подсистемы"
	change_voice(fancy_voice_input_tgui = TRUE)

/atom/proc/get_converted_tts_seed_gender(gender_to_convert = gender)
	switch(gender_to_convert)
		if(MALE)
			return TTS_GENDER_MALE
		if(FEMALE)
			return TTS_GENDER_FEMALE
		else
			return TTS_GENDER_ANY

/atom/proc/pick_tts_seed_gender()
	var/tts_gender = get_converted_tts_seed_gender()
	return pick(SStts220.tts_seeds_by_gender[tts_gender])

/atom/proc/get_random_tts_seed_gender()
	var/tts_choice = pick_tts_seed_gender(gender)
	var/datum/tts_seed/seed = SStts220.tts_seeds[tts_choice]
	if(!seed)
		return null
	return seed.name
