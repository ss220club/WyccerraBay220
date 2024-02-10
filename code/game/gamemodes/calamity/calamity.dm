#define ANTAG_TYPE_RATIO 8

/datum/game_mode/calamity
	name = "Бедствие"
	round_description = "Должно быть, это четверг. Рыбный день. Ты никогда не мог привыкнуть к четвергам..."
	extended_round_description = "Весь ад вот-вот разразится. В этом раунде может появиться буквально каждый тип антагониста. Держись крепче."
	config_tag = "calamity"
	required_players = 1
	votable = 0
	event_delay_mod_moderate = 0.5
	event_delay_mod_major = 0.75

/datum/game_mode/calamity/create_antagonists()
	var/list/antag_candidates = all_random_antag_types()

	var/grab_antags = round(num_players()/ANTAG_TYPE_RATIO)+1
	while(length(antag_candidates) && length(antag_tags) < grab_antags)
		var/antag_id = pick(antag_candidates)
		antag_candidates -= antag_id
		antag_tags |= antag_id

	..()

#undef ANTAG_TYPE_RATIO
