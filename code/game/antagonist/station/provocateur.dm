GLOBAL_DATUM_INIT(provocateurs, /datum/antagonist/provocateur, new)

/datum/antagonist/provocateur
	id = MODE_MISC_AGITATOR
	role_text = "Дейтерагонист"
	role_text_plural = "Дейтерагонисты"
	antaghud_indicator = "hud_traitor"
	flags = ANTAG_RANDOM_EXCEPTED
	antag_text = "Эта роль означает, что вы можете свободно добиваться своих целей, даже если они противоречат целям %WORLD_NAME%, но вы не являетесь антагонистом и не должны вести себя как антагонист. Постарайтесь быть разумными и избегать убийств и взрывов!"
	welcome_text = "Вы персонаж второстепенной истории!"
	blacklisted_jobs = list()
	skill_setter = null
	min_player_age = 0

	var/antag_text_updated
	no_prior_faction = TRUE

/datum/antagonist/provocateur/get_antag_text(mob/recipient)
	if (!antag_text_updated)
		antag_text = replacetext(antag_text, "%WORLD_NAME%", station_name())
		antag_text_updated = TRUE
	return antag_text
